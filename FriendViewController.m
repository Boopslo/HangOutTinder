//
//  FriendViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/30/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "FriendViewController.h"
#import "MyAnnotation.h"

#define METER_TO_KM 1000.0f
#define KM_TO_MILE 1.6
#define START_LAT 37.32
#define START_LONG -122.12
#define SPAN_VALUE 0.01f

@interface FriendViewController () 

@property CLLocation *currentLocation;
@property Firebase *userRef;
@property GeoFire *geofire;
@property Firebase *locationRef;
@property NSDictionary *userData;
@property NSMutableArray *users;
@property NSMutableArray *images;
@property NSMutableArray *categoryUser;
@property Users *whatever;

@end


@implementation FriendViewController {
    Users *userToDisplay;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.currentCategory.length == 0) {
        self.currentCategory = @"none";
    }
    
    _userData = [[NSDictionary alloc] init];
    _users = [[NSMutableArray alloc] init];
    _images = [[NSMutableArray alloc] init];
    self.categoryUser = [[NSMutableArray alloc] init];
    [_textView setText:@"Search friends"];
    //[Firebase defaultConfig].persistenceEnabled = YES;

    // Firebase setup and initialize with my account
    _firebase = [[Firebase alloc] initWithUrl:@"https://hangouttinder.firebaseio.com"];
    // insert user data into Firebase when first loaded
    _userRef = [_firebase childByAppendingPath:@"user"];
    _locationRef = [_firebase childByAppendingPath:@"location"];
    // initialize geofire object
    _geofire = [[GeoFire alloc] initWithFirebaseRef:_locationRef];
//
    // set the map type
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    
    // MKCoordinateRegion, CLLocationCoordinate2D, MKCoordinateSpan?
    if (self.locationManager == nil) {
        self.locationManager = [CLLocationManager new];
    }
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // init the location
    self.currentLocation = [[CLLocation alloc] init];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //  check Firebase and Geofire objects
    if (_firebase == nil) {
        _firebase = [[Firebase alloc] initWithUrl:@"https://hangouttinder.firebaseio.com"];
    }
    if (_userRef == nil) {
        _userRef = [[Firebase alloc] initWithUrl:@"https://hangouttinder.firebaseio.com/user"];
    }
    if (_locationRef == nil) {
        _locationRef = [[Firebase alloc] initWithUrl:@"https://hangouttinder.firebaseio.com/location"];
    }
    if (_geofire == nil) {
        _geofire = [[GeoFire alloc] initWithFirebaseRef:_locationRef];
    }

    /* update user data every time */
    // make sure NSDictionary has data not "nil"
    _userData = @{
        @"name": (self.currentUser.username.length > 0) ? self.currentUser.username : @"",
        @"email": (self.currentUser.email.length > 0) ? self.currentUser.email : @"",
        @"todo": (self.currentUser.todo.length > 0) ? self.currentUser.todo : @"",
        @"phone": (self.currentUser.phone.length > 0) ? self.currentUser.phone : @"",
        @"facebook": (self.currentUser.facebook.length > 0) ? self.currentUser.facebook : @"",
        @"image": (self.currentImage.userImageString.length > 0) ? self.currentImage.userImageString : @"",
        @"category" : (![self.currentCategory isEqualToString:@"none"]) ? self.currentCategory : @"none"
    };
    
    // get whole copy of data, check if the username already exists in that copy
    // if not exists, you set a new child value
    [_userRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (![snapshot hasChild:self.currentUser.username]) {
            NSDictionary *registerUser = @{
                self.currentUser.username: _userData
            };
            // set new key
            [_userRef updateChildValues:registerUser withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error) {
                    NSLog(@"Add new user failed.");
                }
            }];
        }
    }];
    
    // every time the view appears you update the values
    Firebase *currentUserRef = [_userRef childByAppendingPath:self.currentUser.username];
    // this will overwrite the data under the key: username, but it is fine
    [currentUserRef setValue:_userData withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            NSLog(@"Update user data Failed: %@", self.currentUser.username);
        } else {
            NSLog(@"User data updated.");
        }
    }];

    self.locationManager.delegate = self;
    MKCoordinateRegion myRegion;
    self.mapView.delegate = self;
    // set the map center to the current location and add a region
    myRegion.center.latitude = self.currentLocation.coordinate.latitude;
    myRegion.center.longitude = self.currentLocation.coordinate.longitude;
    myRegion.span.latitudeDelta = SPAN_VALUE;
    myRegion.span.longitudeDelta = SPAN_VALUE;
    // move to the current region
    [self.mapView setRegion:myRegion animated:YES];
    
    // make a circle
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:myRegion.center radius:800];
    [self.mapView addOverlay:circle];
    
    // start updating location if everything is well set
    [self.locationManager startUpdatingLocation];
}

// remember to delete data after use
-(void)viewDidDisappear:(BOOL)animated {
    [self removeFirebaseAccount];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) removeFirebaseAccount {
    self.locationManager.delegate = nil;
    //[self setMapView:nil];
    /* remove data in User and Location Firebase */
    // remove from geofire
    [self.geofire removeKey:self.currentUser.username withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"remove geo key failed.");
        } else {
            NSLog(@"remove geo key successfully");
        }
    }];
    // remove all observers
    [self.locationRef removeAllObservers];
    
    // remove current user data in firebase
    NSString *tempUrl = @"https://hangouttinder.firebaseio.com/user/";
    NSString *refUrl = [tempUrl stringByAppendingString:self.currentUser.username];
    // set the temporary firebase ref to your user
    Firebase *removeUser = [[Firebase alloc] initWithUrl:refUrl];
    [removeUser removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            NSLog(@"remove user data failed.");
        } else {
            NSLog(@"remove user data successfully");
        }
    }];
    [self.userRef removeAllObservers];
    [self.users removeAllObjects];
    [self.images removeAllObjects];
    [self.categoryUser removeAllObjects];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray/*<CLLocation *>*/ *)locations {
    [self.mapView removeAnnotations:[self.mapView annotations]];
    //[self.mapView setCenterCoordinate:self.mapView.region.center animated:NO];
    // get the last updated location
    self.currentLocation = [locations lastObject];
    [self.mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
    // set selector and update location every minute
   
    NSLog(@"update location: %@", self.currentLocation);

    // update and upload location of current user into Geofire object in Firebase
    [_geofire setLocation:[[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude] forKey:self.currentUser.username withCompletionBlock:^(NSError *error) {
        if (error != nil) {
            NSLog(@"update location failed: %@", error);
        } else {
            NSLog(@"update location successful.");
        }
    }];
    /******  query location data every time you updated your own location  ******/
    [self updateFriendsLocation:self.currentLocation];
    
    [self.locationManager stopUpdatingLocation];
}

// function to get other users location and display them as annotations in the map
-(void) updateFriendsLocation:(CLLocation *)myLocation {
    // set the center and range for querying the location of your data (in 1 kilometer)
    CLLocation *center = [[CLLocation alloc] initWithLatitude:myLocation.coordinate.latitude longitude:myLocation.coordinate.longitude];
    GFCircleQuery *circleQuery = [_geofire queryAtLocation:center withRadius:1];
    // handle the query: make annotations appear in the map
    FirebaseHandle queryHandle = [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        //NSLog(@"Key '%@' entered area and is at: '%@'", key, location);
        // the NSString is the key to find the user information from Firebase
        // get the responded value from the database and use Annotation to display it
        [self getFirebaseData:key];
    }];
    [_firebase removeObserverWithHandle:queryHandle];
}

 // this function : get all the geolocation data and display it on the map
-(void) getFirebaseData:(NSString *)key {
    Firebase *fireRef = [[Firebase alloc] initWithUrl:@"https://hangouttinder.firebaseio.com/user"];
    [fireRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        Firebase *otherUserRef = [_userRef childByAppendingPath:key];
        [otherUserRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            // get the data out now
            if (![self.currentUser.username isEqualToString:snapshot.key]) {
                NSLog(@"Key %@ and value %@", snapshot.key, snapshot.value);
                // get location with key
                [_geofire getLocationForKey:snapshot.key withCallback:^(CLLocation *location, NSError *error) {
                    if (error) {
                        NSLog(@"Error occurred when getting locaion for \"firebase-hq\": %@", [error localizedDescription]);
                    } else if (location) {
                        CLLocationCoordinate2D otherLocation = [location coordinate];
                        MyAnnotation *otherNotation = [[MyAnnotation alloc] initWithPosition:otherLocation];
                        // set the title and subtitle for the notation
                        otherNotation.title = snapshot.value[@"name"];
                        otherNotation.subtitle = snapshot.value[@"todo"];
                        UserImage *tempImage = [[UserImage alloc] init];
                        // add annotation to map view
                        NSLog(@"User:\n%@ \n%@ \n%@ \n%@ \n%@\n \n", otherNotation.showUser.username, otherNotation.showUser.email, otherNotation.showUser.todo, otherNotation.showUser.phone, otherNotation.showUser.facebook);
                        
                        if (![self.currentCategory isEqualToString:@"none"]) {
                            if ([self.currentCategory isEqualToString:snapshot.value[@"category"]]) {
                                Users *chosen = [[Users alloc] init];
                                chosen.username = snapshot.value[@"name"];
                                chosen.email = snapshot.value[@"email"];
                                chosen.todo = snapshot.value[@"todo"];
                                chosen.phone = snapshot.value[@"phone"];
                                chosen.facebook = snapshot.value[@"facebook"];
                                otherNotation.showUser = chosen;
                                [self.categoryUser addObject:chosen];
                                //UserImage *image = [[UserImage alloc] init];
                                tempImage.imageName = chosen.name;
                                [self.mapView addAnnotation:otherNotation];
                            }
                        } else {
                            Users *tempUser = [[Users alloc] init];
                            tempUser.username = snapshot.value[@"name"];
                            tempUser.phone = snapshot.value[@"phone"];
                            tempUser.todo = snapshot.value[@"todo"];
                            tempUser.email = snapshot.value[@"email"];
                            tempUser.facebook = snapshot.value[@"facebook"];
                            //UserImage *tempImage = [[UserImage alloc] init];
                            tempImage.imageName = tempUser.username;
                            [self.mapView addAnnotation:otherNotation];
                            otherNotation.showUser = tempUser;
                            [self.users addObject:tempUser];
                        }
                        tempImage.userImageString = snapshot.value[@"image"];
                        
                        [self.images addObject:tempImage];

                        // add annotation to the mutable array
                    } else {
                        NSLog(@"GeoFire does not contain location.");
                    }
                }];
            }
        } withCancelBlock:^(NSError *error) {
            if (error) {
                NSLog(@"Error occurred when getting Firebase data.");
            }
        }];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Get user data failed.");
    }];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Error" message:@"cannot update location" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKCircleView *view = [[MKCircleView alloc] initWithCircle:(MKCircle*)overlay];
    view.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    view.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    view.lineWidth = 1;
    return view;
}

// this is what your annotation will appear when you clicked it
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
//    annotationView.pinTintColor = [UIColor redColor];
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = rightButton;
    
    return annotationView;
}

// if the annoation is tapped, display the tapped data in the textview
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    // get reference to the annotation to get data
    NSString *compare = @"";
    NSString *string = @"";
    if ([self.currentCategory isEqualToString:@"none"]) {
//        // search whatever thing
        for (Users *user in self.users) {
            if ([user.username isEqualToString:view.annotation.title]) {
                NSString *temp = [NSString stringWithFormat:@"User:\nname: %@ \nemail: %@ \nin mind: %@ \nphone: %@ \nfacebook: %@\n \n", user.username, user.email, user.todo, user.phone, user.facebook];
                string = [string stringByAppendingString:temp];
                // keep a copy of user, you will update data every time if you tapped different pin
                userToDisplay = user;
                compare = user.username;
                [self.textView setText:string];
                break;
            }
        }
    } else {
        // you specified the categories that you wnat to search
        for (Users *cats in self.categoryUser) {
            if ([cats.username isEqualToString:view.annotation.title]) {
                NSString *temp = [NSString stringWithFormat:@"Search for:%@ \nUser:\n%@ \n%@ \n%@ \n%@ \n%@\n \n", self.currentCategory, cats.username, cats.email, cats.todo, cats.phone, cats.facebook];
                string = [string stringByAppendingString:temp];
                userToDisplay = cats;
                compare = cats.username;
                //[self.textView setText:@"fgdsfsdgiuhsdfgiuhgdfapouhagjhbdfsphouadfgiophu"];
                [self.textView setText:string];
                break;
            }
        }
    }
    for (UserImage *image in self.images) {
        if ([image.imageName isEqualToString:compare]) {
            NSData *dataFromBase64 = [NSData base64DataFromString:image.userImageString];
            self.userProfilePicture.image = [[UIImage alloc] initWithData:dataFromBase64];
            break;
        }
    }
}

- (IBAction)displayFriendData:(id)sender {
    // clean all the user data first
    [self.users removeAllObjects];
    [self.images removeAllObjects];
    [self.categoryUser removeAllObjects];
    // restart updating user location
    [self.locationManager startUpdatingLocation];
    MKCoordinateRegion myRegion;
    // set the map center to the current location and add a region
    myRegion.center.latitude = self.currentLocation.coordinate.latitude;
    myRegion.center.longitude = self.currentLocation.coordinate.longitude;
    myRegion.span.latitudeDelta = SPAN_VALUE;
    myRegion.span.longitudeDelta = SPAN_VALUE;
    // move to the current region
    [self.mapView setRegion:myRegion animated:YES];
}

// make text field hold placeholder text
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

-(void)touchesBegan:(NSSet/*<UITouch *>*/ *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// responsive method when choosing segmented control
- (IBAction)connectFriend:(id)sender {
    NSString *messageTo = @"sms:+";
    if (userToDisplay.phone.length != 0) {
        messageTo = [messageTo stringByAppendingString:userToDisplay.phone];
    }
    NSString *userEmail  = @"mailto:";
    if (userToDisplay.email.length != 0) {
        userEmail = [userEmail stringByAppendingString:userToDisplay.email];
    }
    NSURL *url = [NSURL URLWithString:userEmail];
    
    switch (self.contactOption.selectedSegmentIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com"]];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:messageTo]];
            break;
        case 2:
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        default:
            NSLog(@"No this segmented option!");
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

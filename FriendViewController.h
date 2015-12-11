//
//  FriendViewController.h
//  WeMakeFriends
//
//  Created by Oslo on 10/30/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "Users.h"
#import "ListTableViewController.h"
#import "DatabaseManager.h"
#import "UserImage.h"
#import "NSStrinAdditions.h"

#import <Firebase/Firebase.h>
#import <Firebase/FDataSnapshot.h>
#import <Firebase/FQuery.h>
#import <Firebase/FEventType.h>

#import <GeoFire/GeoFire.h>
#import <GeoFire/GFQuery.h>
#import <GeoFire/GFCircleQuery.h>
#import <GeoFire/GFRegionQuery.h>

@interface FriendViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property Users *currentUser;
@property UserImage *currentImage;
///// todo: maybe need database property
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property Firebase *firebase;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *contactOption;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePicture;
@property NSString *currentCategory;

@end

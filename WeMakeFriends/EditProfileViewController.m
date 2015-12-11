//
//  EditProfileViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

/*
 
 1. make username mandatory before saving data
 
 */


#import "EditProfileViewController.h"
#import "NSStrinAdditions.h"

#define kOFFSET_FOR_KEYBOARD 80.0
#define namePattern @"^\\b[a-zA-Z0-9\\s]+\\b$"
#define emailPattern @"^\\b[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$"
#define phonePattern @"^\\b[0-9]+$"

@interface EditProfileViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *phone;
@property (strong, nonatomic) IBOutlet UITextField *facebook;
@property (strong, nonatomic) IBOutlet UITextView *something;

@property DatabaseManager *dbManager;
@property NSArray *queryResult;
@property int checkLaunch;

@end

@implementation EditProfileViewController
@synthesize myDelegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        // initialize the database manager
    self.dbManager = [[DatabaseManager alloc] initWithDatabaseFilename:@"hottinder.sql"];
    
    // load the user data if you inserted it before and come back to this view controller again
    if (self.currentUser.name.length != 0) {
        [self loadUser];
    } else {
        [self checkIfExists];
    }
    self.checkLaunch = 1;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.something setText:@"I want to ..."];
    self.something.textColor = [UIColor lightGrayColor];

    if (self.checkLaunch != 1) {
        if (self.currentUser.name.length != 0) {
            // load the user data from the database
            [self loadUser];
        } else {
            [self checkIfExists];
        }
    }
}
- (IBAction)choosePhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary/*<NSString *,id>*/ *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.currentImage.userImage = chosenImage;
    NSData *imageData = UIImagePNGRepresentation(self.currentImage.userImage);
    self.currentImage.userImageString = [NSString base64StringFromData:imageData length:(int)[imageData length]];
    NSLog(@"Image picked.");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) loadUser {
    // load the data out again
    NSString *query = [NSString stringWithFormat:@"select * from Users where name='%@'", self.currentUser.name];
    if (self.queryResult == nil) {
        self.queryResult = [[NSArray alloc] initWithArray:[self.dbManager loadDatafromDB:query]];
    }
    // set the textfields with values if there are any
    if (self.queryResult.count > 0) {
        self.username.text = [[self.queryResult objectAtIndex:0] objectAtIndex:[self.dbManager.columnNames indexOfObject:@"username"]];
        NSLog(@"%@", self.username.text);
        self.email.text = [[self.queryResult objectAtIndex:0] objectAtIndex:[self.dbManager.columnNames indexOfObject:@"email"]];
        self.something.text = [[self.queryResult objectAtIndex:0] objectAtIndex:[self.dbManager.columnNames indexOfObject:@"todo"]];
        self.phone.text = [[self.queryResult objectAtIndex:0] objectAtIndex:[self.dbManager.columnNames indexOfObject:@"phone"]];
        self.facebook.text = [[self.queryResult objectAtIndex:0] objectAtIndex:[self.dbManager.columnNames indexOfObject:@"facebook"]];
    }
    if (self.username.text.length == 0 || [self.username.text isEqualToString:@"(null)"]) {
        self.username.text = @"";
    }
    if (self.email.text.length == 0 || [self.email.text isEqualToString:@"(null)"]) {
        self.email.text = @"";
    }
    if (self.phone.text.length == 0 || [self.phone.text isEqualToString:@"(null)"]) {
        self.phone.text = @"";
    }
    if (self.facebook.text.length == 0 || [self.facebook.text isEqualToString:@"(null)"]) {
        self.facebook.text = @"";
    }
    if (self.something.text.length == 0 || [self.something.text isEqualToString:@"(null)"]) {
        self.something.text = @"I want to ...";
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.checkLaunch++;
}

//  save button will crash when using database
- (IBAction)saveInfo:(id)sender {
    // get the value from the textfields and textview, store them in the Users object
    self.currentUser.username = [self.username text];
    self.currentUser.phone = [self.phone text];
    // when try to access the UITextView, some problem is happening
    self.currentUser.email = [self.email text];
    if (self.facebook.text.length == 0) {
        self.currentUser.facebook = @"None";
    } else {
        self.currentUser.facebook = [self.facebook text];
    }
    self.currentUser.todo = [self.something text];
    
    // check if input matches regular expression
    if ([RX(namePattern) isMatch:[self.username text]] && [RX(emailPattern) isMatch:[self.email text]] && [RX(phonePattern) isMatch:[self.phone text]]) {
        if (self.currentUser.name.length != 0) {
            // if user logged into sqlite3 database we have to check textfields validation
            if (self.username.text.length != 0 && self.email.text.length != 0 && self.something.text.length != 0) {
                // store data in database manager
                
                NSString *queryUpdate = [NSString stringWithFormat:@"update Users set username='%@', email='%@', todo='%@', phone='%@', facebook='%@' where name='%@'", self.currentUser.username, self.currentUser.email, self.currentUser.todo, self.currentUser.phone, self.currentUser.facebook, self.currentUser.name];
                [self.dbManager executeQuery:queryUpdate];
                
                if (self.dbManager.updatedRows != 0) {
                    NSLog(@"Query executed and updated, affected rows = %d", self.dbManager.updatedRows);
                    NSString *query = [NSString stringWithFormat:@"select * from Users where name='%@'", self.currentUser.name];
                    self.queryResult = [[NSArray alloc] initWithArray:[self.dbManager loadDatafromDB:query]];
                } else {
                    NSLog(@"query failed to execute.");
                }
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                // alert message that textfields cannot be empty
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Watch out!" message:@"name, email, your things are mandatory" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else {
            // user didn't login to sqlite3
            [self.myDelegate sendBackUserData:self.currentUser withImage:self.currentImage];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid input" message:@"retype textfields" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) checkIfExists {
    if (self.currentUser.username.length != 0) {
        [self.username setText:self.currentUser.username];
    } else {
        [self.username setText:@""];
    }
    
    if (self.currentUser.email.length != 0) {
        [self.email setText:self.currentUser.email];
    } else {
        [self.email setText:@""];
    }
    
    if (self.currentUser.facebook.length != 0) {
        [self.facebook setText:self.currentUser.facebook];
    } else {
        [self.facebook setText:@""];
    }
    
    if ( self.currentUser.phone.length != 0) {
        [self.phone setText:self.currentUser.phone];
    } else {
        [self.phone setText:@""];
    }
    
    if (self.currentUser.todo.length != 0) {
        [self.something setText:self.currentUser.todo];
    } else {
        [self.something setText:@"I want to ..."];
    }
}

-(void)touchesBegan:(NSSet/*<UITouch *>*/ *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *temp = [NSString stringWithFormat:@"%@", self.something.text];
    if (self.something != nil) {
        if ([temp isEqualToString:@"I want to ..."]) {
            [self.something setText:@""];
            self.something.textColor = [UIColor blackColor];
        }
    }
    [self animateTextView:textView up:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    NSString *temp = [NSString stringWithFormat:@"%@", self.something.text];
    if (self.something != nil) {
        if ([temp isEqualToString:@""]) {
            [self.something setText:@"I want to ..."];
            self.something.textColor = [UIColor lightGrayColor];
        }
    }
    [self animateTextView:textView up:NO];
}

// method to make the view move up a little bit
- (void) animateTextView:(UITextView *)textView up:(BOOL)up {
    
    const int movementDistance = 140; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

// make text field hold placeholder text
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

// if textView is should begin editing we register for keyboard notification
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //    if (![_username isFirstResponder]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(animateTextField:up:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    //    }
    return YES;
}

// if textView is should end editing we unregister for keyboard notification
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //if (![_username isFirstResponder]) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    //}
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

-(void) animateTextField:(UITextField *)textField up:(BOOL)up {
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    if (textField == _facebook) {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    } else if (textField == _phone) {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    } else if (textField == _email) {
        [UIView beginAnimations:nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
}

// dismiss keyboard when not at textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
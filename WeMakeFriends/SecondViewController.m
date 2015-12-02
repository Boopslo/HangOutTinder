//
//  SecondViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

/* 
 
 todo :
 check if the login name already exists in the database, then we will not insert new data but 
 edit the old data
 
 */


#import "SecondViewController.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (strong, nonatomic) DatabaseManager *dbManager;
@property NSArray *dataArray;
@property BOOL checkIfExists;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // initialize the Users object after successfully loading the screen
    self.currentUser = [[Users alloc] init];
    // initialize the database manager object
    self.dbManager = [[DatabaseManager alloc] initWithDatabaseFilename:@"hottinder.sql"];
    self.checkIfExists = NO;
    
}

- (IBAction)deleteRecord:(id)sender {
    [self.dbManager executeQuery:@"delete from Users"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// check if the username is having any value, set it as username and register it in database
- (IBAction)generateUser:(id)sender {
    BOOL check = NO;
    // make a connection to database if choose to login
    
    // check textfield and grab the username out and get the data
    if (self.userTextField.text.length != 0) {
        self.currentUser.name = self.userTextField.text;
        check = YES;
    }

    // dismiss the keyboard
    [self.userTextField resignFirstResponder];
    ///// if yes, we will edit the data; if no, we create a new data in the database

    // initialize the array
    if (self.dataArray != nil) {
        self.dataArray = nil;
    }

    // create query statement and load it into the array
    NSString *select = [NSString stringWithFormat:@"select name from Users"];
    self.dataArray = [[NSArray alloc] initWithArray:[self.dbManager loadDatafromDB:select]];

    //NSMutableArray *temp2 = [self.dataArray copy];
    NSArray *temp3 = self.dataArray;
    NSString *longData = [temp3 componentsJoinedByString:@""];
    if ([longData rangeOfString:self.userTextField.text].location != NSNotFound) {
        NSLog(@"a data is equal to login name");
        self.checkIfExists = YES;
    }

    // user did enter any kind of login name
    if (check == YES) {
        //self.currentUser.isLoggedIn = YES;
        // if the login name not exists exists
        if (self.checkIfExists == NO) {
            
            // create query string to insert data into db
            NSString *queryInsert = [NSString stringWithFormat:@"insert into Users values(null, '%@', '%@', '%@', '%@', '%@', '%@')", self.currentUser.name, self.currentUser.username, self.currentUser.email, self.currentUser.todo, self.currentUser.phone, self.currentUser.facebook];
            [self.dbManager executeQuery:queryInsert];
            //NSLog(@"%@", self.dataArray);
            // check if the query is successfully executed
            if (self.dbManager.updatedRows != 0) {
                NSLog(@"query executed. %d rows updated.", self.dbManager.updatedRows);
            } else {
                NSLog(@"database update failed.");
            }
            // dismiss the keyboard
            [self.userTextField resignFirstResponder];
        }
        // login alert message
        [self logInMessage];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please insert log in name!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) logInMessage {
    NSString *message = @"";
    if (self.checkIfExists == YES) {
        message = @"Log in with user: ";
        message = [message stringByAppendingString:self.userTextField.text];
    } else {
        message = @"New user log in: ";
        message = [message stringByAppendingString:self.userTextField.text];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log in message" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action1){}];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // if user enters data, then pass the inserted data
    ListTableViewController *listView = [segue destinationViewController];
    // pass the data to next controller
    listView.currentUser = self.currentUser;
    ///// todo: pass the database property to the next view controller?
}

@end

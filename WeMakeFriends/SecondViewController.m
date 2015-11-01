//
//  SecondViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userTextField;

@end

@implementation SecondViewController

// check if the username is having any value, set it as username and register it in database
- (IBAction)generateUser:(id)sender {
    // make a connection to database if choose to login
    
    // check textfield and grab the username out and get the data
    if (_userTextField.text != nil) {
        self.currentUser.username = self.userTextField.text;
    }
    ///// todo: write the database related code here
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // initialize the Users object after successfully loading the screen
    self.currentUser = [[Users alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

@end

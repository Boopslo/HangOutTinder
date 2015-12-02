//
//  FirstViewController.m
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationItem setTitle:@"HOTinder"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // call the second view controller and set as destinationViewController
    // pass to second view controller
    //SecondViewController *secondView = [segue destinationViewController];
    ///// todo: connect to sqlite database here ?
    
}


@end

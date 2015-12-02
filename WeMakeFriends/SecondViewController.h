//
//  SecondViewController.h
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Users.h"
#import <sqlite3.h>
#import "ListTableViewController.h"
#import "DatabaseManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SecondViewController : UIViewController

@property Users *currentUser;
// might need the database variable(property)

@end

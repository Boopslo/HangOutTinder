//
//  ListTableViewController.h
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Users.h"
#import <sqlite3.h>
#import "FriendViewController.h"
#import "EditProfileViewController.h"
#import "DatabaseManager.h"
#import "UserImage.h"
#import "CategoryTableViewController.h"

// this view controller declare itself as the delegate of the EditProfileViewController
@interface ListTableViewController : UITableViewController 

@property Users *currentUser;
@property UserImage *currentImage;
///// todo: need a database property?





@end

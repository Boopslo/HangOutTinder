//
//  EditProfileViewController.h
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


@protocol UserProtocol <NSObject>

-(void) sendBackUserData:(Users *)receivedUser;

@end
//@class ListTableViewController;

@interface EditProfileViewController : UIViewController


// EditProfileViewController --> second view controller
@property (weak, nonatomic) id<UserProtocol> myDelegate;
@property (strong, nonatomic) Users *currentUser;


@end

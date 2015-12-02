//
//  Users.h
//  WeMakeFriends
//
//  Created by Oslo on 10/27/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Users : NSObject

// name is used to login sqlite3, username is used for displaying to friends
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *todo;

// gender, school and age should be optional
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *facebook;
@property BOOL isLoggedIn;

@end

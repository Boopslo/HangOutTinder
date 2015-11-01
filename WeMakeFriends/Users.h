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

@property (weak, nonatomic) NSString *username;
@property (weak, nonatomic) NSString *phone;
@property (weak, nonatomic) NSString *todo;

// gender, school and age should be optional
@property (weak, nonatomic) NSString *gender;
@property (weak, nonatomic) NSString *school;
@property (weak, nonatomic) NSString *age;

@end

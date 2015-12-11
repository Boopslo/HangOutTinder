//
//  CategoryTableViewController.h
//  WeMakeFriends
//
//  Created by Shih Chi Lin on 12/3/15.
//  Copyright (c) 2015 Shih Chi Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"

@protocol CategoryProtocol <NSObject>

-(void) getCategory:(NSString *)category;

@end


@interface CategoryTableViewController : UITableViewController

@property (weak, nonatomic) id<CategoryProtocol> myDelegate;

@end

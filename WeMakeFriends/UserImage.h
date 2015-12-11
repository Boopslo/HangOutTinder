//
//  UserImage.h
//  WeMakeFriends
//
//  Created by Oslo on 12/2/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserImage : NSObject

@property NSString *userImageString;
@property UIImage *userImage;
// should be same as username
@property NSString *imageName;

-(NSString *) getImageString;

@end

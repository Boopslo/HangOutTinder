//
//  MyAnnotation.h
//  WeMakeFriends
//
//  Created by Oslo on 11/19/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Users.h"
#import "UserImage.h"

@interface MyAnnotation : NSObject <MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property Users *showUser;
@property UserImage *showImage;

- initWithPosition: (CLLocationCoordinate2D)coords;


@end

//
//  MyAnnotation.m
//  WeMakeFriends
//
//  Created by Oslo on 11/19/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (id)initWithPosition:(CLLocationCoordinate2D)coords {
    if (self = [super init]) {
        self.coordinate = coords;
    }
    return self;
}

@end

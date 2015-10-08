//
//  CARMobileAppTrackingAdapter.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CARMobileAppTrackingAdapter.h"
#import <MobileAppTracker/MobileAppTracker.h>


@implementation CARMobileAppTrackingAdapter

-(void) setEnableDebug:(id)value {
    bool enableDebug = [value boolValue];
    [Tune setDebugMode:enableDebug];
}

@end
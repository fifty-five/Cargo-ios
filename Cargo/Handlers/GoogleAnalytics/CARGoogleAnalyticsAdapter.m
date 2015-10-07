//
//  FAAdapter.m
//  FIFTagHandler
//
//  Created by Med on 22/08/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARGoogleAnalyticsAdapter.h"

#if GA_v3_10_0
#import "GAI.h"
#import "Cargo.h"
#import "TAGManager.h"
#import "TAGDataLayer.h"


@implementation CARGoogleAnalyticsAdapter



- (void)setDryRun:(id)dryRun {
    bool val = [dryRun boolValue];
    [[GAI sharedInstance] setDryRun:val];
    [logger logParamSetWithSuccess:@"dryRun" withValue:dryRun];
}



- (void)setDispatchInterval:(id)dispatchInterval {
    
    NSNumber *val = [CARUtils castToNSNumber:dispatchInterval];
    [[GAI sharedInstance] setDispatchInterval:[val integerValue]];
    [logger logParamSetWithSuccess:@"dispatchInterval"
                         withValue:val];
    
}

- (void)setOptOut:(id)optOut {
    
    bool val = [optOut boolValue];
    [[GAI sharedInstance] setOptOut:val];
    [logger logParamSetWithSuccess:@"optOut"
                         withValue:optOut];
    
}

- (void)setAllowIDFACollection:(id)allowIDFACollection {
    
    bool val = [allowIDFACollection boolValue];
    [[GAI sharedInstance] defaultTracker].allowIDFACollection = val;
    [logger logParamSetWithSuccess:@"allowIDFACollection"
                         withValue:allowIDFACollection];
    
}

- (void)setTrackUncaughtExceptions:(id)trackExceptions {
    
    bool val = [trackExceptions boolValue];
    [[GAI sharedInstance] setTrackUncaughtExceptions:val];
    [logger logParamSetWithSuccess:@"trackUncaughtExceptions"
                         withValue:trackExceptions];
}







@end
#endif

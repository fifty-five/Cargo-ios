//
//  GAFunctionCallTagHandler_v3.0.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARGoogleAnalyticsTagHandler.h"


#import "GAI.h"
#import "GAIFields.h"
#import "CARGoogleAnalyticsAdapter.h"
#import "FIFLogger.h"


@interface CARGoogleAnalyticsTagHandler()

@property (nonatomic, assign) id<GAITracker> tracker;

@end


@implementation CARGoogleAnalyticsTagHandler


+(void)load{
    CARGoogleAnalyticsTagHandler *handler = [[CARGoogleAnalyticsTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"GA_set"];
    [Cargo registerTagHandler:handler withKey:@"GA_upload"];
}



-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"GA_set"]){
        [self set:parameters];
    }
    else if ([tagName isEqualToString:@"GA_upload"]){
        [self upload:parameters];
    }
}


- (id)init
{
    if (self = [super init]) {
        self.key = @"GA";
        self.name = @"Google Analytics";
        self.valid = NO;
        self.initialized = NO;
    }
    return self;
}




- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}



- (void)set:(NSDictionary *)parameters {

    
    
    CARGoogleAnalyticsAdapter *adapter = [[CARGoogleAnalyticsAdapter alloc] init];
    [adapter setAttributesFromParameters:parameters];

    
}

- (void)upload:(NSDictionary *)parameters {
    (void)parameters;

    //Upload
    [[GAI sharedInstance] dispatch];
    FIFLog(kTAGLoggerLogLevelInfo, @"%@ upload success.",
           self.name);
    
}

@end

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
#import "FIFLogger.h"


@interface CARGoogleAnalyticsTagHandler()


@end


@implementation CARGoogleAnalyticsTagHandler


+(void)load{
    CARGoogleAnalyticsTagHandler *handler = [[CARGoogleAnalyticsTagHandler alloc] init];
    
    [Cargo registerTagHandler:handler withKey:@"GA_init"];
    [Cargo registerTagHandler:handler withKey:@"GA_set"];
    [Cargo registerTagHandler:handler withKey:@"GA_upload"];
}



-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"GA_set"]){
        [self set:parameters];
    }
    else if ([tagName isEqualToString:@"GA_init"]){
        [self init:parameters];
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
        self.tracker = [[GAI sharedInstance] defaultTracker];
        self.instance = [GAI sharedInstance];
        
    }
    return self;
}




- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}

-(void)init:(NSDictionary*)parameters{
    NSString* trackingId = [parameters objectForKey:@"trackingId"];
    if(trackingId){
        [self.instance trackerWithTrackingId:trackingId];
    }
    [self set:parameters];
}

- (void)set:(NSDictionary *)parameters {

    NSString * trackUncaughtException = [parameters objectForKey:@"trackUncaughtExceptions"];
    if([trackUncaughtException boolValue]){
        [self.instance trackUncaughtExceptions];
    }
    
    NSString * allowIdfaCollection = [parameters objectForKey:@"allowIdfaCollection"];
    if([allowIdfaCollection boolValue]){
        [self.tracker allowIDFACollection];
    }
    
    NSString * dispatchInterval = [parameters objectForKey:@"dispatchInterval"];
    if(dispatchInterval){
        NSNumber *interval = [CARUtils castToNSNumber:dispatchInterval];
        [self.instance setDispatchInterval:[interval integerValue]];
    }
    
    

    
}

- (void)upload:(NSDictionary *)parameters {
    (void)parameters;

    //Upload
    [self.instance dispatch];
    FIFLog(kTAGLoggerLogLevelInfo, @"%@ upload success.",
           self.name);
    
}

@end

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
#import "Cargo.h"


@interface CARGoogleAnalyticsTagHandler()


@end

/**
 *  The class handle all interaction and event calls shipped to Google Analytics.
 */
@implementation CARGoogleAnalyticsTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* GA_init = @"GA_init";
NSString* GA_set = @"GA_set";
NSString* GA_upload = @"GA_upload";

NSString* TRACKING_ID = @"trackingId";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARGoogleAnalyticsTagHandler *handler = [[CARGoogleAnalyticsTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:GA_init];
    [Cargo registerTagHandler:handler withKey:GA_set];
    [Cargo registerTagHandler:handler withKey:GA_upload];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the Googla Analytics handler
 */
- (id)init{
    if (self = [super initWithKey:@"GA" andName:@"Google Analytics"]) {

        self.tracker = [[GAI sharedInstance] defaultTracker];
        self.instance = [GAI sharedInstance];
    }
    return self;
}

/**
 Call back from GTM container to call a specific method
 after a function tag and associated parameters are received
 
 @param tagName The tag name of the aimed method
 @param parameters Dictionary of parameters
 */
-(void) execute:(NSString*)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];

    if ([tagName isEqualToString:GA_init]){
        [self init:parameters];
    }
    else if (self.initialized) {
        if([tagName isEqualToString:GA_set]){
            [self set:parameters];
        }
        else if ([tagName isEqualToString:GA_upload]){
            [self upload:parameters];
        }
    }
    else
        [self.logger logUninitializedFramework:self.name];
}

/**
 Called in registerHandlers to validate a handler and check for its initialization.
 */
- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Google Analytics SDK
 Register the tracking ID to the Google Analytics SDK.
 
 @param parameters :
  - trackingId: UAID Google Analytics gives when you register your app
 */
-(void)init:(NSDictionary*)parameters{
    NSString* trackingId = [CARUtils castToNSString:[parameters objectForKey:TRACKING_ID]];

    if(trackingId){
        [self.instance trackerWithTrackingId:trackingId];
        self.initialized = TRUE;
    }
    else
        [self.logger logMissingParam:TRACKING_ID inMethod:GA_init];
}


/* ****************************************** Tracking ****************************************** */

/**
 Called to set optional parameters. If a parameter is not defined, its value will be set to default

 @param parameters :
  - trackUncaughtExceptions: boolean set to true by default
  - allowIdfaCollection: boolean set to true by default
  - dispatchInterval: Double set to 30 by default. Time interval before sending pending hits
 */
- (void)set:(NSDictionary *)parameters {
    /** default values for the optional parameters */
    BOOL    trackException = TRUE;
    BOOL    idfaCollection = TRUE;
    double  dispInterval = 30;

    // retrieve the trackUncaughtExceptions value if existant, or set to the default value
    NSString* trackUncaughtException = [CARUtils castToNSString:
                                         [parameters objectForKey:@"trackUncaughtExceptions"]];
    if(trackUncaughtException)
        trackException = [trackUncaughtException boolValue];
    [self.instance setTrackUncaughtExceptions:trackException];
    [self.logger logParamSetWithSuccess:@"trackUncaughtExceptions"
                              withValue:[NSNumber numberWithBool:trackException]];

    // retrieve the allowIdfaCollection value if existant, or set to the default value
    NSString* allowIdfaCollection = [CARUtils castToNSString:
                                         [parameters objectForKey:@"allowIdfaCollection"]];
    if(allowIdfaCollection)
        idfaCollection = [allowIdfaCollection boolValue];
    [self.tracker setAllowIDFACollection:idfaCollection];
    [self.logger logParamSetWithSuccess:@"allowIdfaCollection"
                              withValue: [NSNumber numberWithBool:idfaCollection]];

    // retrieve the dispatchInterval value if existant, or set to the default value
    NSNumber* dispatchInterval = [CARUtils castToNSNumber:
                                      [parameters objectForKey:@"dispatchInterval"]];
    if(dispatchInterval)
        dispInterval = [dispatchInterval integerValue];
    [self.instance  setDispatchInterval:dispInterval];
    [self.logger logParamSetWithSuccess:@"dispatchInterval"
                              withValue:[NSNumber numberWithInteger:dispInterval]];
}


/**
 Call it in order to force a dispatch

 @param parameters none are required
 */
- (void)upload:(NSDictionary *)parameters {
    (void)parameters;

    //Upload
    [self.instance dispatch];
    [self.logger FIFLog:kTAGLoggerLogLevelInfo withMessage:@"%@ upload success.", self.name];
    
}

@end

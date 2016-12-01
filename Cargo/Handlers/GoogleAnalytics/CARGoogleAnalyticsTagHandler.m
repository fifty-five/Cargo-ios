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
#import "GAIDictionaryBuilder.h"
#import "FIFLogger.h"
#import "CARConstants.h"
#import "Cargo.h"


@interface CARGoogleAnalyticsTagHandler()


@end

/**
 *  The class handle all interaction and event calls shipped to Google Analytics.
 */
@implementation CARGoogleAnalyticsTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* GA_INIT = @"GA_init";
NSString* GA_SET = @"GA_set";
NSString* GA_IDENTIFY = @"GA_identify";
NSString* GA_TAG_SCREEN = @"GA_tagScreen";
NSString* GA_TAG_EVENT = @"GA_tagEvent";

NSString *TRACK_UNCAUGHT_EXCEPTIONS = @"trackUncaughtExceptions";
NSString *ALLOW_IDFA_COLLECTION = @"allowIdfaCollection";
NSString *EVENT_ACTION = @"eventAction";
NSString *EVENT_CATEGORY = @"eventCategory";
NSString *EVENT_LABEL = @"eventLabel";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARGoogleAnalyticsTagHandler *handler = [[CARGoogleAnalyticsTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:GA_INIT];
    [Cargo registerTagHandler:handler withKey:GA_SET];
    [Cargo registerTagHandler:handler withKey:GA_IDENTIFY];
    [Cargo registerTagHandler:handler withKey:GA_TAG_SCREEN];
    [Cargo registerTagHandler:handler withKey:GA_TAG_EVENT];
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

    if ([tagName isEqualToString:GA_INIT]){
        [self init:parameters];
    }
    else if (self.initialized) {
        if([tagName isEqualToString:GA_SET]){
            [self set:parameters];
        }
        else if([tagName isEqualToString:GA_IDENTIFY]){
            [self identify:parameters];
        }
        else if([tagName isEqualToString:GA_TAG_SCREEN]){
            [self tagScreen:parameters];
        }
        else if([tagName isEqualToString:GA_TAG_EVENT]){
            [self tagEvent:parameters];
        }
        else
            [self.logger logUnknownFunctionTag:tagName];
    }
    else
        [self.logger logUninitializedFramework];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Google Analytics SDK
 Register the tracking ID to the Google Analytics SDK.
 
 @param parameters :
  - trackingId: UAID Google Analytics gives when you register your app
 */
-(void)init:(NSDictionary *)parameters{
    NSString* applicationId = [CARUtils castToNSString:[parameters objectForKey:APPLICATION_ID]];

    if(applicationId){
        [self.instance trackerWithTrackingId:applicationId];
        [self.logger logParamSetWithSuccess:APPLICATION_ID withValue:applicationId];
        self.initialized = TRUE;
    }
    else
        [self.logger logMissingParam:APPLICATION_ID inMethod:GA_INIT];
}


/* ****************************************** Tracking ****************************************** */

/**
 Called to set optional parameters. If a parameter is not defined, its value will be set to default

 @param parameters :
  - trackUncaughtExceptions: boolean set to true by default
  - allowIdfaCollection: boolean set to true by default
  - dispatchInterval: Double set to 30 by default. Time interval before sending pending hits
  - enableOptOut: When this is set to true, no tracking information will be sent.
  - disableTracking: boolean disabling the tracking in the entire app when set to true
 */
- (void)set:(NSDictionary *)parameters {
    /** default values for the optional parameters */
    BOOL    trackException = TRUE;
    BOOL    idfaCollection = TRUE;
    BOOL    enableOptOut = FALSE;
    BOOL    setDryRun = FALSE;
    double  dispInterval = 30;

    // retrieve the trackUncaughtExceptions value if existant, or set to the default value
    NSString* trackUncaughtException = [CARUtils castToNSString:
                                         [parameters objectForKey:TRACK_UNCAUGHT_EXCEPTIONS]];
    if(trackUncaughtException)
        trackException = [trackUncaughtException boolValue];
    [self.instance setTrackUncaughtExceptions:trackException];
    [self.logger logParamSetWithSuccess:TRACK_UNCAUGHT_EXCEPTIONS
                              withValue:[NSNumber numberWithBool:trackException]];


    // retrieve the allowIdfaCollection value if existant, or set to the default value
    NSString* allowIdfaCollection = [CARUtils castToNSString:
                                         [parameters objectForKey:ALLOW_IDFA_COLLECTION]];
    if(allowIdfaCollection)
        idfaCollection = [allowIdfaCollection boolValue];
    [self.tracker setAllowIDFACollection:idfaCollection];
    [self.logger logParamSetWithSuccess:ALLOW_IDFA_COLLECTION
                              withValue: [NSNumber numberWithBool:idfaCollection]];


    // retrieve the dispatchInterval value if existant, or set to the default value
    NSNumber* dispatchInterval = [CARUtils castToNSNumber:
                                      [parameters objectForKey:DISPATCH_INTERVAL]];
    if(dispatchInterval)
        dispInterval = [dispatchInterval integerValue];
    [self.instance  setDispatchInterval:dispInterval];
    [self.logger logParamSetWithSuccess:DISPATCH_INTERVAL
                              withValue:[NSNumber numberWithInteger:dispInterval]];


    // retrieve the enableOptOut value if existant, or set to the default value
    NSString* optOut = [CARUtils castToNSString:[parameters objectForKey:ENABLE_OPTOUT]];
    if([parameters objectForKey:ENABLE_OPTOUT] != nil)
        enableOptOut = [optOut boolValue];
    [self.instance setOptOut:enableOptOut];
    [self.logger logParamSetWithSuccess:ENABLE_OPTOUT
                              withValue:[NSNumber numberWithBool:enableOptOut]];


    // retrieve the disableTracking value if existant, or set to the default value
    NSString* dryRun = [CARUtils castToNSString:[parameters objectForKey:DISABLE_TRACKING]];
    if([parameters objectForKey:DISABLE_TRACKING] != nil)
        setDryRun = [dryRun boolValue];
    [self.instance setDryRun:setDryRun];
    [self.logger logParamSetWithSuccess:DISABLE_TRACKING
                              withValue:[NSNumber numberWithBool:setDryRun]];
}


/**
 Used to setup the userId when the user logs in
 Requires a userId parameter.

 @param parameters: -userId: the google user id
 */
-(void)identify:(NSDictionary *)parameters {
    NSString* userId = [CARUtils castToNSString:[parameters objectForKey:USER_ID]];

    if (userId) {
        [self.tracker set:kGAIUserId value:userId];
        [self.logger logParamSetWithSuccess:USER_ID withValue:userId];
    }
    else
        [self.logger logMissingParam:USER_ID inMethod:GA_IDENTIFY];
}


/**
 Used to build and send a screen event to Google Analytics.
 Requires a screenName parameter.

 @param parameters: -screenName: the name of the screen you want to be reported
 */
-(void)tagScreen:(NSDictionary *)parameters {
    NSString* screenName = [CARUtils castToNSString:[parameters objectForKey:SCREEN_NAME]];

    if (screenName) {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        [self.logger logParamSetWithSuccess:SCREEN_NAME withValue:screenName];
    }
    else {
        [self.logger logMissingParam:SCREEN_NAME inMethod:GA_TAG_SCREEN];
    }
}

-(void)tagEvent:(NSDictionary *)parameters {
    NSString* eventAction = [CARUtils castToNSString:[parameters objectForKey:EVENT_ACTION]];
    NSString* eventCategory = [CARUtils castToNSString:[parameters objectForKey:EVENT_CATEGORY]];
    NSString* eventLabel = [CARUtils castToNSString:[parameters objectForKey:EVENT_LABEL]];
    NSNumber* eventValue = [CARUtils castToNSNumber:[parameters objectForKey:EVENT_VALUE]];

    if (eventAction && eventCategory) {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventAction
                                                              action:eventCategory
                                                               label:eventLabel
                                                               value:eventValue] build]];
        [self.logger logParamSetWithSuccess:EVENT_ACTION withValue:eventAction];
        [self.logger logParamSetWithSuccess:EVENT_CATEGORY withValue:eventCategory];

        if (eventLabel)
            [self.logger logParamSetWithSuccess:EVENT_LABEL withValue:eventLabel];
        if (eventValue)
            [self.logger logParamSetWithSuccess:EVENT_VALUE withValue:eventValue];
    }
    else {
        [self.logger logMissingParam:@"eventAction and/or eventCategory" inMethod:GA_TAG_EVENT];
    }
}

@end

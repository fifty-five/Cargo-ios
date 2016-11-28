//
//  CARFirebaseTagHandler.m
//  Cargo
//
//  Created by Med on 19/07/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARFirebaseTagHandler.h"
#import "CARConstants.h"


/**
 The class which handles interactions with the Firebase SDK.
 */
@implementation CARFirebaseTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString *FIR_INIT = @"FIR_init";
NSString *FIR_IDENTIFY = @"FIR_identify";
NSString *FIR_TAG_EVENT = @"FIR_tagEvent";
NSString *FIR_TAG_SCREEN = @"FIR_tagScreen";

NSString *const ENABLE_COLLECTION = @"enableCollection";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARFirebaseTagHandler *handler = [[CARFirebaseTagHandler alloc] init];
    [FIRApp configure];
    
    [Cargo registerTagHandler:handler withKey:FIR_INIT];
    [Cargo registerTagHandler:handler withKey:FIR_IDENTIFY];
    [Cargo registerTagHandler:handler withKey:FIR_TAG_EVENT];
    [Cargo registerTagHandler:handler withKey:FIR_TAG_SCREEN];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the Firebase handler
 */
- (id)init
{
    if (self = [super initWithKey:@"FIR" andName:@"Firebase"]) {

        self.fireAnalyticsClass = [FIRAnalytics class];
        self.fireConfClass = [FIRAnalyticsConfiguration class];
    }
    return self;
}

/**
 Call back from GTM container to call a specific method
 after a function tag and associated parameters are received
 
 @param tagName The tag name of the aimed method
 @param parameters Dictionary of parameters
 */
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];

    if([tagName isEqualToString:FIR_INIT]){
        [self init:parameters];
    }
    else if([tagName isEqualToString:FIR_IDENTIFY]){
        [self identify:parameters];
    }
    else if([tagName isEqualToString:FIR_TAG_EVENT]){
        [self tagEvent:parameters];
    }
    else if([tagName isEqualToString:FIR_TAG_SCREEN]){
        [self tagEvent:parameters];
    }
    else
        [self.logger logUnknownFunctionTag:tagName];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you may call first if you want to disable the Firebase analytics collection
 The parameter requested is a boolean true/false for collection enabled/disabled
 This setting is persisted across app sessions. By default it is enabled.
 A call on this method without any parameter will enable the collection.

 @param parameters :
  - enableCollection : a boolean set to false to disable the data collection
 */
-(void) init:(NSDictionary *)parameters{
    if ([parameters valueForKey:ENABLE_COLLECTION]) {
        id value = [parameters valueForKey:ENABLE_COLLECTION];

        Boolean enabled = value ? [value boolValue] : YES;
        [[self.fireConfClass sharedInstance] setAnalyticsCollectionEnabled:enabled];
        [self.logger logParamSetWithSuccess:ENABLE_COLLECTION
                                  withValue:[NSNumber numberWithBool:enabled]];
        if (!enabled) {
            [self.logger FIFLog:kTAGLoggerLogLevelWarning
                    withMessage:@"The analytics collection has been disabled, \
             you won't be able to send anything to the Firebase console. \
             Call on the %@ method with the %@ parameter set to true \
             to enable the collection again.", FIR_INIT, ENABLE_COLLECTION];
        }
    }
    else {
        [self.logger logMissingParam:ENABLE_COLLECTION inMethod:FIR_INIT];
    }
}


/* ****************************************** Tracking ****************************************** */

/**
 Allow you to identify the user and to define the segment it belongs to.
 All the other parameters will be considered as user properties.

 @param parameters :
  - userId : an unique ID for this specific user
  - other parameters : as a dictionary, the key is used as a category, the value as is.
 */
-(void) identify:(NSDictionary *)parameters{
    NSMutableDictionary *params = [parameters mutableCopy];
    NSString *userId = [CARUtils castToNSString:[params objectForKey:USER_ID]];

    if (userId) {
        [self.fireAnalyticsClass setUserID:userId];
        [self.logger logParamSetWithSuccess:USER_ID withValue:userId];
        [params removeObjectForKey:USER_ID];
    }
    if ([params count] > 0) {
        for(id key in params) {
            NSString *value = [CARUtils castToNSString:[params valueForKey:key]];
            NSString *keyString = [CARUtils castToNSString:[params valueForKey:key]];

            if (value) {
                [self.fireAnalyticsClass setUserPropertyString:value forName:keyString];
                [self.logger logParamSetWithSuccess:keyString withValue:value];
            }
            else
                [self.logger logUncastableParam:keyString toType:@"NSString"];
        }
    }
}

/**
 Method used to create and fire an event to the Firebase Console
 The mandatory parameters is eventName
 Without this parameter, the event won't be built.
 After the creation of the event object, some attributes can be added,
 using the dictionary obtained from the gtm container.
 
 For the format to apply to the name and the parameters, check http://tinyurl.com/j7ppm6b
 
 @param parameters :
  - eventName : the name of the event
  - other parameters : as a dictionary, used as event parameters .
 */
-(void) tagEvent:(NSDictionary *)parameters{
    NSString *eventName = [CARUtils castToNSString:[parameters valueForKey:EVENT_NAME]];

    if (eventName) {
        NSMutableDictionary *params = [parameters mutableCopy];
        [params removeObjectForKey:EVENT_NAME];

        if (params.count > 0) {
            [self.fireAnalyticsClass logEventWithName:eventName parameters:params];
            [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
            [self.logger logParamSetWithSuccess:@"params" withValue:params];
            return ;
        }
        [self.fireAnalyticsClass logEventWithName:eventName parameters:nil];
        [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
        [self.logger logParamSetWithSuccess:@"params" withValue:@"nil"];
    }
    else
        [self.logger logMissingParam:EVENT_NAME inMethod:FIR_TAG_EVENT];
}

@end

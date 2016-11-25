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
NSString *Firebase_init = @"Firebase_init";
NSString *Firebase_identify = @"Firebase_identify";
NSString *Firebase_tagEvent = @"Firebase_tagEvent";

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
    
    [Cargo registerTagHandler:handler withKey:Firebase_init];
    [Cargo registerTagHandler:handler withKey:Firebase_identify];
    [Cargo registerTagHandler:handler withKey:Firebase_tagEvent];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the Firebase handler
 */
- (id)init
{
    if (self = [super initWithKey:@"Firebase" andName:@"Firebase"]) {

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

    if([tagName isEqualToString:Firebase_init]){
        [self init:parameters];
    }
    else if([tagName isEqualToString:Firebase_identify]){
        [self identify:parameters];
    }
    else if([tagName isEqualToString:Firebase_tagEvent]){
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
-(void) init:(NSDictionary*) parameters{
    id value = [parameters valueForKey:ENABLE_COLLECTION];
    Boolean enabled = value ? [value boolValue] : YES;
    [[self.fireConfClass sharedInstance] setAnalyticsCollectionEnabled:enabled];
}


/* ****************************************** Tracking ****************************************** */

/**
 Allow you to identify the user and to define the segment it belongs to.
 All the other parameters will be considered as user properties.

 @param parameters :
  - userId : an unique ID for this specific user
  - other parameters : as a dictionary, the key is used as a category, the value as is.
 */
-(void) identify:(NSDictionary*) parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* userId = [CARUtils castToNSString:[parameters objectForKey:USER_ID]];

    if (userId) {
        [self.fireAnalyticsClass setUserID:userId];
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
-(void) tagEvent:(NSDictionary*) parameters{
    NSString* eventName = [CARUtils castToNSString:[parameters valueForKey:EVENT_NAME]];

    if (eventName) {
        NSMutableDictionary* params = [parameters mutableCopy];
        [params removeObjectForKey:EVENT_NAME];

        if (params.count > 0) {
            [self.fireAnalyticsClass logEventWithName:eventName parameters:params];
            return ;
        }
        [self.fireAnalyticsClass logEventWithName:eventName parameters:nil];
    }
    else
        [self.logger logMissingParam:EVENT_NAME inMethod:Firebase_tagEvent];
}

@end

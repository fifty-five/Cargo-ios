//
//  CARAdobeTagHandler.m
//  Cargo
//
//  Created by Julien Gil on 21/03/2018.
//  Copyright © 2018 55 SAS. All rights reserved.
//

#import "CARAdobeTagHandler.h"
#import "CARConstants.h"

#import "FIFLogger.h"


@interface CARAdobeTagHandler()


@end

/**
 The class which handles interactions with the Adobe SDK.
 */
@implementation CARAdobeTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* ADB_INIT = @"ADB_init";
NSString* ADB_SET_PRIVACY = @"ADB_setPrivacy";
NSString* ADB_TAG_SCREEN = @"ADB_tagScreen";
NSString* ADB_TAG_EVENT = @"ADB_tagEvent";
NSString* ADB_TRACK_LOCATION = @"ADB_trackLocation";
NSString* ADB_SEND_QUEUE_HITS = @"ADB_sendQueueHits";
NSString* ADB_CLEAR_QUEUE = @"ADB_clearQueue";
NSString* ADB_TRACK_PUSH_MESSAGE = @"ADB_trackPushMessage";
NSString* ADB_COLLECT_LIFE_CYCLE = @"ADB_collectLyfeCycle";
NSString* ADB_TRACK_TIME_START = @"ADB_trackTimeStart";
NSString* ADB_TRACK_TIME_END = @"ADB_trackTimeEnd";
NSString* ADB_TRACK_TIME_UPDATE = @"ADB_trackTimeUpdate";
NSString* ADB_INCREASE_LIFETIME_VALUE = @"ADB_increaseLifeTimeValue";

NSString* ACTION_NAME = @"actionName";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARAdobeTagHandler* handler = nil;
    handler = [[CARAdobeTagHandler alloc] init];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the AT Internet handler
 */
- (id)init{
    if (self = [super initWithKey:@"ADB" andName:@"Adobe"]) {
        self.adobe = [ADBMobile class];
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
    
    if([tagName isEqualToString:ADB_INIT]){
        [self init:parameters];
    }
    // check whether the SDK has been initialized before calling any method
    else if (self.initialized) {
        if ([tagName isEqualToString:ADB_TAG_SCREEN]){
            [self tagScreen:parameters];
        }
        else if ([tagName isEqualToString:ADB_TAG_EVENT]){
            [self tagEvent:parameters];
        }
        else if ([tagName isEqualToString:ADB_SET_PRIVACY]){
            [self setPrivacy:parameters];
        }
        else if ([tagName isEqualToString:ADB_TRACK_PUSH_MESSAGE]){
            [self trackPushMessage:parameters];
        }
        else if ([tagName isEqualToString:ADB_TRACK_TIME_START]){
            [self trackTimedActionStart:parameters];
        }
        else if ([tagName isEqualToString:ADB_TRACK_TIME_UPDATE]){
            [self trackTimedActionUpdate:parameters];
        }
        else if ([tagName isEqualToString:ADB_TRACK_TIME_END]){
            [self trackTimedActionEnd:parameters];
        }
        else if ([tagName isEqualToString:ADB_COLLECT_LIFE_CYCLE]){
            [self collectLifeCycle:parameters];
        }
        else if ([tagName isEqualToString:ADB_TRACK_LOCATION]){
            [self trackLocation:parameters];
        }
        else if ([tagName isEqualToString:ADB_INCREASE_LIFETIME_VALUE]){
            [self increaseLifetimeValue:parameters];
        }
        else if ([tagName isEqualToString:ADB_SEND_QUEUE_HITS]){
            [self sendQueueHits];
        }
        else if ([tagName isEqualToString:ADB_CLEAR_QUEUE]){
            [self clearQueue];
        }
        else
            [self.logger logUnknownFunctionTag:tagName];
    }
    else
        [self.logger logUninitializedFramework];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Adobe SDK
 You can give a path to override the default one for the config file.
 
 @param parameters :
 - bundleIdentifier: the identifier of your app, you can retrieve it with [[NSBundle mainBundle] bundleIdentifier]
 - overrideConfigPath: the path to override the default one for the config file location
 */
-(void)init:(NSDictionary *)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* overrideConfigPath = @"overrideConfigPath";
    NSString* bundleIdentifier = @"bundleIdentifier";
    NSString* overrideConfig = [CARUtils castToNSString:[params objectForKey:overrideConfigPath]];
    NSString* bundleId = [CARUtils castToNSString:[params objectForKey:bundleIdentifier]];
    self.initialized = true;
    
    if (bundleId) {
        [params removeObjectForKey:bundleIdentifier];
        [params removeObjectForKey:overrideConfigPath];

        if (overrideConfig) {
            NSString* configPath = [[NSBundle bundleWithIdentifier:bundleId] pathForResource:overrideConfig ofType:@"json"];

            if (configPath) {
                [self.adobe overrideConfigPath:configPath];
                [self.logger logParamSetWithSuccess:overrideConfigPath withValue:configPath];
            }
            else {
                [self.logger FIFLog:error withMessage:[overrideConfig stringByAppendingString:@".json not found."]];
                // set the handler as uninitialized.
                self.initialized = false;
                return;
            }
        }
        else {
            NSString* configPath = [[NSBundle bundleWithIdentifier:bundleId] pathForResource:@"ADBMobileConfig" ofType:@"json"];

            if (configPath) {
                [self.adobe overrideConfigPath:configPath];
                [self.logger logParamSetWithSuccess:overrideConfigPath withValue:configPath];
            }
            else {
                [self.logger FIFLog:error withMessage:@"ADBMobileConfig.json not found."];
                // set the handler as uninitialized.
                self.initialized = false;
                return;
            }
        }
        [self collectLifeCycle:params];
        self.initialized = true;
    }
    
    if (self.logger.level <= debug) {
        [self.adobe setDebugLogging:true];
    }
    else {
        [self.adobe setDebugLogging:false];
    }
}

/**
 Indicates to the SDK that lifecycle data should be collected for use across all solutions in the SDK.
 Tip: The preferred location to invoke this method is in application:didFinishLaunchingWithOptions:
 
 @param parameters :
 - all the parameters are used as additional data
 */
-(void)collectLifeCycle:(NSDictionary *)parameters {
    // if there is any parameter, these are given to the appropriate SDK function
    if ([parameters count] > 0) {
        [self.adobe collectLifecycleDataWithAdditionalData:parameters];
        [self.logger logParamSetWithSuccess:@"collectLifeCycle parameters" withValue:parameters];
    }
    // otherwise, the SDK function without any parameter is called
    else {
        [self.adobe collectLifecycleData];
    }
    [self.logger FIFLog:verbose withMessage:@"Lifecycle data is now collected"];
}


/* ****************************************** Tracking ****************************************** */

/**
 Method used to create and send a screen view event to the Adobe interface
 The mandatory parameter is screenName which is a necessity to build the event.
 
 @param parameters :
 - screenName : the name of the screen tagged
 - all the other parameters left are used as context data
 */
- (void)tagScreen:(NSDictionary*)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* screenName = [CARUtils castToNSString:[params objectForKey:SCREEN_NAME]];
    
    if (screenName) {
        [params removeObjectForKey:SCREEN_NAME];
        [self.adobe trackState:screenName data:params];
        [self.logger logParamSetWithSuccess:SCREEN_NAME withValue:screenName];
        if ([params count] > 0) {
            [self.logger logParamSetWithSuccess:@"screenParameters" withValue:params];
        }
    }
    else
        [self.logger logMissingParam:SCREEN_NAME inMethod:ADB_TAG_SCREEN];
}

/**
 Method used to create and fire an event to the Adobe interface
 The mandatory parameter is eventName and eventType which are a necessity to build the event.
 Possibility to attach up to 3 chapters and a second level to the event
 
 @param parameters :
 - eventName : the name given to this event
 - all the other parameters left are used as context data
 */
- (void)tagEvent:(NSDictionary*)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* eventName = [CARUtils castToNSString:[params objectForKey:EVENT_NAME]];
    
    if (eventName) {
        [params removeObjectForKey:EVENT_NAME];
        [self.adobe trackAction:eventName data:params];
        [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
        if ([params count] > 0) {
            [self.logger logParamSetWithSuccess:@"eventParameters" withValue:params];
        }
    }
    else {
        [self.logger logMissingParam:@"eventName" inMethod:ADB_TAG_EVENT];
    }
}

/**
 Tracks a push message click-through.
 
 @param parameters :
 - all the parameters are used as user infos.
 */
- (void)trackPushMessage:(NSDictionary *)parameters{
    // send the hit only when there is parameters.
    if ([parameters count] > 0) {
        [self.adobe trackPushMessageClickThrough:parameters];
        [self.logger logParamSetWithSuccess:@"Push Message" withValue:parameters];
    }
    else {
        [self.logger logMissingParam:@"Push Message parameters" inMethod:ADB_TRACK_PUSH_MESSAGE];
    }
}

/**
 Start a timed action with name action.
 If you call this method for an action that has already started, the previous timed action is overwritten.
 Tip: This call does not send a hit.
 
 @param parameters :
 - actionName : the name of the action to track
 - all the other parameters left are used as context data
 */
- (void)trackTimedActionStart:(NSDictionary *)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* actionName = [CARUtils castToNSString:[params objectForKey:ACTION_NAME]];
    
    if (actionName) {
        [params removeObjectForKey:ACTION_NAME];
        [self.adobe trackTimedActionStart:actionName data:params];
        [self.logger logParamSetWithSuccess:ACTION_NAME withValue:actionName];
        if ([params count] > 0) {
            [self.logger logParamSetWithSuccess:@"trackTimeStart parameters" withValue:params];
        }
    }
    else {
        [self.logger logMissingParam:ACTION_NAME inMethod:ADB_TRACK_TIME_START];
    }
}

/**
 Pass in data to update the context data associated with the given action.
 The data that is passed in is appended to the existing data for the action, and if the same key is already defined for action, overwrites the data.
 Tip: This call does not send a hit.
 
 @param parameters :
 - actionName : the name of the action to update
 - all the other parameters left are used as context data updating the actionName
 */
- (void)trackTimedActionUpdate:(NSDictionary *)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* actionName = [CARUtils castToNSString:[params objectForKey:ACTION_NAME]];
    
    if (actionName) {
        [params removeObjectForKey:ACTION_NAME];
        if ([params count] > 0) {
            [self.adobe trackTimedActionUpdate:actionName data:params];
            [self.logger logParamSetWithSuccess:ACTION_NAME withValue:actionName];
            [self.logger logParamSetWithSuccess:@"trackTimeUpdate parameters" withValue:params];
        }
        else {
            [self.logger logMissingParam:@"trackTimeUpdate parameters" inMethod:ADB_TRACK_TIME_UPDATE];
        }
    }
    else {
        [self.logger logMissingParam:ACTION_NAME inMethod:ADB_TRACK_TIME_UPDATE];
    }
}

/**
 End a timed action.
 If you provide block, you will have access to the final time values and be able to manipulate data prior to sending the final hit.
 Tip: If you provide block, you must return YES to send a hit. Passing in nil for block sends the final hit.
 
 @param parameters :
 - actionName : the name of the action to end
 - successfulAction: defines whether the hit should be send or not (default true)
 - all the other parameters left are used as context data updating the actionName
 */
- (void)trackTimedActionEnd:(NSDictionary *)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* successfulAction = @"successfulAction";
    BOOL sendHit = YES;
    NSString* actionName = [CARUtils castToNSString:[params objectForKey:ACTION_NAME]];
    
    if (actionName) {
        [params removeObjectForKey:ACTION_NAME];

        if ([params objectForKey:successfulAction]) {
            sendHit = [[CARUtils castToNSNumber:[params objectForKey:successfulAction]] boolValue];
            [params removeObjectForKey:successfulAction];
        }

        [self.adobe trackTimedActionEnd:actionName logic:^(NSTimeInterval inApp,
                                                           NSTimeInterval total,
                                                           NSMutableDictionary *data) {
            [data addEntriesFromDictionary:params];
            return sendHit;
        }];

        // logs depending on the circumstances
        if (sendHit == NO) {
            [self.logger FIFLog:verbose withMessage:@"The %@ Timed Action wasn't sent because the %i boolean has been set to false", ACTION_NAME, successfulAction];
        }
        else {
            [self.logger FIFLog:verbose withMessage:@"The %@ Timed Action has been sent with the following additional data : %@", ACTION_NAME, params];
        }
    }
    else {
        [self.logger logMissingParam:ACTION_NAME inMethod:ADB_TRACK_TIME_END];
    }
}

/**
 Sends the current x y coordinates.
 Also uses points of interest that are defined in the ADBMobileConfig.json file to determine
 if the location provided as a parameter is in any of your POIs.
 If the current coordinates are in a defined POI,
 a context data variable is populated and sent with the trackLocation call.
 
 @param parameters :
 none is required, but you'll have to create a CLLocation and set it in the CargoLocation object for this method to work.
 - all the parameters are given as context data
 */
- (void)trackLocation:(NSDictionary *)parameters{
    CLLocation* location = [CargoLocation getLocation];
    // if there is a location to retrieve, it is set, along with the additional data
    if (location) {
        [self.adobe trackLocation:location data:parameters];
        [self.logger logParamSetWithSuccess:@"location" withValue: location];
        if ([parameters count] > 0) {
            [self.logger logParamSetWithSuccess:@"location parameters" withValue:parameters];
        }
    }
    else {
        [self.logger logMissingParam:@"location" inMethod:ADB_TRACK_LOCATION];
    }
}

/**
 Adds amount to the user's lifetime value.
 
 @param parameters :
 - increaseVisitorLifetimeValue: the amount to add to the user's lifetime value.
 - all the parameters left are given as context data
 */
- (void)increaseLifetimeValue:(NSDictionary *)parameters{
    NSString* LT_VALUE = @"increaseVisitorLifetimeValue";
    NSMutableDictionary* params = [parameters mutableCopy];
    NSNumber* amountTemp = [CARUtils castToNSNumber:[parameters objectForKey:LT_VALUE]];
    NSDecimalNumber* amount = [NSDecimalNumber decimalNumberWithDecimal:[amountTemp decimalValue]];
    
    // retrieve the increaseVisitorLifetimeValue parameter value, removes it from the parameters,
    // set it and set the parameters left as additional data.
    if (amount != nil) {
        [params removeObjectForKey:LT_VALUE];
        [self.adobe trackLifetimeValueIncrease:amount data:params];
        [self.logger logParamSetWithSuccess:LT_VALUE withValue:amount];
        
        if ([params count] > 0) {
            [self.logger logParamSetWithSuccess:@"LifetimeValue parameters" withValue:params];
        }
    }
    else {
        [self.logger logMissingParam:LT_VALUE inMethod:ADB_INCREASE_LIFETIME_VALUE];
    }
}

/**
 Sets the privacy status for the current user to status.
 
 Set to one of the following values:
 
 OPT_IN - hits are sent immediately.
 OPT_OUT - hits are discarded.
 UNKNOWN - If offline tracking is enabled, hits are saved
 until the privacy status changes to opt-in (then hits are sent)
 or opt-out (then hits are discarded). If offline tracking is not enabled,
 hits are discarded until the privacy status changes to opt in.
 
 @param parameters :
 - privacyStatus: can have 3 possible values OPT_IN / OPT_OUT / UNKNOWN
 */
- (void)setPrivacy:(NSDictionary *)parameters{
    NSString* STATUS = @"privacyStatus";
    NSString* OPT_IN = @"OPT_IN";
    NSString* OPT_OUT = @"OPT_OUT";
    NSString* UNKNOWN = @"UNKNOWN";
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* privacyStatus = [CARUtils castToNSString:[params objectForKey:STATUS]];
    
    if (privacyStatus) {
        if ([privacyStatus isEqualToString:OPT_IN]) {
            [self.adobe setPrivacyStatus:ADBMobilePrivacyStatusOptIn];
            [self.logger logParamSetWithSuccess:STATUS withValue:privacyStatus];
        }
        else if ([privacyStatus isEqualToString:OPT_OUT]) {
            [self.adobe setPrivacyStatus:ADBMobilePrivacyStatusOptOut];
            [self.logger logParamSetWithSuccess:STATUS withValue:privacyStatus];
        }
        else if ([privacyStatus isEqualToString:UNKNOWN]) {
            [self.adobe setPrivacyStatus:ADBMobilePrivacyStatusUnknown];
            [self.logger logParamSetWithSuccess:STATUS withValue:privacyStatus];
        }
        else {
            [self.logger logNotFoundValue:privacyStatus forKey:STATUS inValueSet:@[OPT_IN, OPT_OUT, UNKNOWN]];
        }
    }
    else {
        [self.logger logMissingParam:STATUS inMethod:ADB_SET_PRIVACY];
    }
}

/**
 Regardless of how many hits are currently queued, forces the library to send all hits in the offline queue.
 */
- (void)sendQueueHits{
    NSUInteger queueHits = [self.adobe trackingGetQueueSize];
    
    [self.adobe trackingSendQueuedHits];
    [self.logger FIFLog:verbose withMessage:@"Forced to send %tu hits from queue", queueHits];
}

/**
 Clears all hits from the offline queue.
 */
- (void)clearQueue{
    NSUInteger queueHits = [self.adobe trackingGetQueueSize];
    
    [self.adobe trackingClearQueue];
    [self.logger FIFLog:verbose withMessage:@"Cleared %tu hits from queue", queueHits];
}

@end

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
 The method you need to call first. Allow you to initialize AT Internet SDK
 Register the domain and the siteId to the AT Internet SDK.
 
 @param parameters :
 - domain: domain AT Internet gives when you register your app
 - siteId: site ID AT Internet gives when you register your app
 */
-(void)init:(NSDictionary *)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    NSString* overrideConfigPath = @"overrideConfigPath";
    NSString* overrideConfig = [CARUtils castToNSString:[params objectForKey:overrideConfigPath]];
    self.initialized = true;
    
    if (overrideConfig) {
        NSString* configPath = [[NSBundle mainBundle] pathForResource:overrideConfig ofType:@"json"];
        if (configPath) {
            [self.adobe overrideConfigPath:configPath];
            [self.logger logParamSetWithSuccess:overrideConfig withValue:configPath];
        }
        else {
            [self.logger FIFLog:error withMessage:[overrideConfig stringByAppendingString:@".json not found."]];
            // set the handler as uninitialized.
            self.initialized = false;
            return;
        }
        [params removeObjectForKey:overrideConfigPath];
    }
    
    if (self.logger.level <= debug) {
        [self.adobe setDebugLogging:true];
    }
    else {
        [self.adobe setDebugLogging:false];
    }

    [self collectLifeCycle:params];
    self.initialized = true;
    
}

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
 Method used to create and fire an event to the AT Internet interface
 The mandatory parameter is screenName which is a necessity to build the event.
 
 @param parameters :
 - screenName : the name of the screen tagged
 - chapter1/2/3 : use them to add more context (optional)
 - level2 : an int describing a second level of your screen (optional)
 - isBasketView (bool) : set to true if the screen view is a basket one
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
 Method used to create and fire an event to the AT Internet interface
 The mandatory parameter is eventName and eventType which are a necessity to build the event.
 Possibility to attach up to 3 chapters and a second level to the event
 
 @param parameters :
 - eventName : the name given to this event
 - eventType : the type of the event (sendTouch/sendNavigation/sendDownload/sendExit/sendSearch)
 - chapter1/2/3 : add some more context with up to 3 chapters
 - level2 : an int describing a second level of your screen (optional) (-1 turn this option off)
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
        [self.logger logMissingParam:@"eventName and/or eventType" inMethod:ADB_TAG_EVENT];
    }
}

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

- (void)sendQueueHits{
    NSUInteger queueHits = [self.adobe trackingGetQueueSize];
    
    [self.adobe trackingSendQueuedHits];
    [self.logger FIFLog:verbose withMessage:@"Forced to send %tu hits from queue", queueHits];
}

- (void)clearQueue{
    NSUInteger queueHits = [self.adobe trackingGetQueueSize];
    
    [self.adobe trackingClearQueue];
    [self.logger FIFLog:verbose withMessage:@"Cleared %tu hits from queue", queueHits];
}

@end

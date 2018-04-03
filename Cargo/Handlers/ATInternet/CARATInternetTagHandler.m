//
//  GAFunctionCallTagHandler_v3.0.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARATInternetTagHandler.h"
#import "CARConstants.h"

#import "FIFLogger.h"


@interface CARATInternetTagHandler()


@end

/**
 The class which handles interactions with the AT Internet SDK.
 */
@implementation CARATInternetTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* AT_INIT = @"AT_init";
NSString* AT_SET_CONFIG = @"AT_setConfig";
NSString* AT_IDENTIFY = @"AT_identify";
NSString* AT_TAG_SCREEN = @"AT_tagScreen";
NSString* AT_TAG_EVENT = @"AT_tagEvent";

NSString* LOG = @"log";
NSString* LOG_SSL = @"logSSL";
NSString* SITE = @"site";
NSString* OVERRIDE = @"override";
NSString* BASKET = @"isBasketView";
NSString* CHAPTER1 = @"chapter1";
NSString* CHAPTER2 = @"chapter2";
NSString* CHAPTER3 = @"chapter3";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARATInternetTagHandler* handler = nil;
    handler = [[CARATInternetTagHandler alloc] init];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the AT Internet handler
 */
- (id)init{
    if (self = [super initWithKey:@"AT" andName:@"AT Internet"]) {

        self.tracker = [[ATInternet sharedInstance] defaultTracker];
        self.instance = [ATInternet sharedInstance];
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

    if([tagName isEqualToString:AT_INIT]){
        [self init:parameters];
    }
    // check whether the SDK has been initialized before calling any method
    else if (self.initialized) {
        if ([tagName isEqualToString:AT_SET_CONFIG]){
            [self setConfig:parameters];
        }
        else if ([tagName isEqualToString:AT_TAG_SCREEN]){
            [self tagScreen:parameters];
        }
        else if ([tagName isEqualToString:AT_IDENTIFY]){
            [self identify:parameters];
        }
        else if ([tagName isEqualToString:AT_TAG_EVENT]){
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
 The method you need to call first. Allow you to initialize AT Internet SDK
 Register the domain and the siteId to the AT Internet SDK.
 
 @param parameters :
  - domain: domain AT Internet gives when you register your app
  - siteId: site ID AT Internet gives when you register your app
 */
-(void)init:(NSDictionary *)parameters{
    NSString* log = [CARUtils castToNSString:[parameters objectForKey:LOG]];
    NSString* logSSL = [CARUtils castToNSString:[parameters objectForKey:LOG_SSL]];
    NSString* siteId = [CARUtils castToNSString:[parameters objectForKey:SITE]];
    // weakSelf is used because of a warning about leaks in the async setConfig method
    __unsafe_unretained typeof(self) weakSelf = self;

    if(siteId && log && logSSL){
        [self.tracker setConfig:AT_CONF_LOG value:log completionHandler:^(BOOL isSet) {
            [weakSelf.logger logParamSetWithSuccess:LOG withValue:log];
        }];
        [self.tracker setConfig:AT_CONF_LOGSSL value:logSSL completionHandler:^(BOOL isSet) {
            [weakSelf.logger logParamSetWithSuccess:LOG_SSL withValue:logSSL];
        }];
        [self.tracker setConfig:AT_CONF_SITE value:siteId completionHandler:^(BOOL isSet) {
            [weakSelf.logger logParamSetWithSuccess:SITE withValue:siteId];
        }];

        self.initialized = TRUE;
    }
    else
        [self.logger logMissingParam:@"log and/or logSSL and/or site" inMethod:AT_INIT];
}


/**
 The method you may call if you want to reconfigure your tracker configuration

 @param parameters :
  - override (boolean) : if you want your values set to override ALL the existant data
                        (set to false by default)
  - rest of parameters : your setup for the tracker
 */
-(void)setConfig:(NSDictionary*)parameters{
    NSMutableDictionary* params = [parameters mutableCopy];
    BOOL override = false;
    __unsafe_unretained typeof(self) weakSelf = self;

    if ([params objectForKey:OVERRIDE]) {
        override = [[CARUtils castToNSNumber:[params objectForKey:OVERRIDE]] boolValue];
        [params removeObjectForKey:OVERRIDE];
    }
    [self.tracker setConfig:params override: override completionHandler:^(BOOL isSet) {
        [weakSelf.logger logParamSetWithSuccess:@"config" withValue:params];
        [weakSelf.logger logParamSetWithSuccess:OVERRIDE withValue:(override ? @YES : @NO)];
    }];
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
    NSString* screenName = [CARUtils castToNSString:[parameters objectForKey:SCREEN_NAME]];
    NSString* chapter1 = [CARUtils castToNSString:[parameters objectForKey:CHAPTER1]];
    NSString* chapter2 = [CARUtils castToNSString:[parameters objectForKey:CHAPTER2]];
    NSString* chapter3 = [CARUtils castToNSString:[parameters objectForKey:CHAPTER3]];
    BOOL isBasketView = false;

    if (screenName) {
        ATScreen *screen = [self.tracker.screens addWithName:screenName];

        if (chapter1) {
            [screen setChapter1:chapter1];
            [self.logger logParamSetWithSuccess:CHAPTER1 withValue:chapter1];
            if (chapter2) {
                [screen setChapter2:chapter2];
                [self.logger logParamSetWithSuccess:CHAPTER2 withValue:chapter2];
                if (chapter3) {
                    [screen setChapter3:chapter3];
                    [self.logger logParamSetWithSuccess:CHAPTER3 withValue:chapter3];
                }
            }
        }
        if ([parameters objectForKey:LEVEL2]){
            int level2 = [CARUtils castToNSInteger:[parameters objectForKey:LEVEL2] withDefault:-1];
            [screen setLevel2:level2];
            [self.logger logParamSetWithSuccess:LEVEL2 withValue:[NSNumber numberWithInt:level2]];
        }
        if ([parameters objectForKey:BASKET]) {
            isBasketView = [[CARUtils castToNSNumber:[parameters objectForKey:BASKET]] boolValue];
            [screen setIsBasketScreen:isBasketView];
            [self.logger logParamSetWithSuccess:BASKET
                                      withValue:[NSNumber numberWithBool:isBasketView]];
        }

        [screen sendView];
    }
    else
        [self.logger logMissingParam:SCREEN_NAME inMethod:AT_TAG_SCREEN];
}

/**
 Identify an user through an unique ID

 @param parameters :
  - userId : the id which will be logged for this user
 */
- (void)identify:(NSDictionary*)parameters{
    NSString* userId = [CARUtils castToNSString:[parameters objectForKey:USER_ID]];

    if (userId) {
        [self.tracker setStringParam:USER_ID value:userId];
        [self.logger logParamSetWithSuccess:USER_ID withValue:userId];
    }
    else
        [self.logger logMissingParam:USER_ID inMethod:AT_IDENTIFY];
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
    NSString* eventName = [CARUtils castToNSString:[parameters objectForKey:EVENT_NAME]];
    NSString* eventType = [CARUtils castToNSString:[parameters objectForKey:EVENT_TYPE]];

    if (eventName && eventType) {
        ATGesture *gesture = [self.tracker.gestures addWithName:eventName];
        int level2 = [CARUtils castToNSInteger:[parameters objectForKey:LEVEL2] withDefault:-1];
        NSString* chapter1 = [CARUtils castToNSString:[parameters objectForKey:@"chapter1"]];

        if (chapter1) {
            NSString* chapter2 = [CARUtils castToNSString:[parameters objectForKey:@"chapter2"]];
            [gesture setChapter1:chapter1];

            if (chapter2) {
                NSString* chapter3 = [CARUtils castToNSString:[parameters objectForKey:@"chapter3"]];
                [gesture setChapter2:chapter2];

                if (chapter3) {
                    [gesture setChapter3:chapter3];
                }
            }
        }

        if (level2 != -1)
            [gesture setLevel2:level2];

        [self sendEvent:gesture withType:eventType];
    }
    else
        [self.logger logMissingParam:@"eventName and/or eventType" inMethod:AT_TAG_EVENT];
}


/* ****************************************** Utility ******************************************* */

/**
 Send the event, depending on which eventType was given in AT_TAG_EVENT method
 This method is exclusively called by the tagEvent method (AT_TAG_EVENT)

 @param event an ATGesture typed event
 @param eventType the eventType, as a NSString
 */
- (void)sendEvent:(ATGesture*)event withType:(NSString*)eventType {
    if ([eventType isEqualToString:@"sendTouch"]) {
        [event sendTouch];
    }
    else if ([eventType isEqualToString:@"sendNavigation"]){
        [event sendNavigation];
    }
    else if ([eventType isEqualToString:@"sendDownload"]){
        [event sendDownload];
    }
    else if ([eventType isEqualToString:@"sendExit"]){
        [event sendExit];
    }
    else if ([eventType isEqualToString:@"sendSearch"]){
        [event sendSearch];
    }
    else{
        NSArray* possibleValues = @[@"sendTouch", @"sendNavigation", @"sendDownload",
                                    @"sendExit", @"sendSearch"];
        [self.logger logNotFoundValue:eventType forKey:EVENT_TYPE inValueSet:possibleValues];
    }

}


@end

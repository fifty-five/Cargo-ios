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
NSString *AT_init = @"AT_init";
NSString *AT_identify = @"AT_identify";
NSString *AT_tagScreen = @"AT_tagScreen";
NSString *AT_tagEvent = @"AT_tagEvent";

NSString *LOG = @"domain";
NSString *SITE_ID = @"siteId";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARATInternetTagHandler *handler = [[CARATInternetTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:AT_init];
    [Cargo registerTagHandler:handler withKey:AT_identify];
    [Cargo registerTagHandler:handler withKey:AT_tagScreen];
    [Cargo registerTagHandler:handler withKey:AT_tagEvent];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the AT Internet handler
 */
- (id)init{
    if (self = [super init]) {
        self.key = @"AT";
        self.name = @"AT Internet";
        self.valid = NO;
        self.initialized = NO;

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

    if([tagName isEqualToString:AT_init]){
        [self init:parameters];
    }
    // check whether the SDK has been initialized before calling any method
    else if (self.initialized) {
        if ([tagName isEqualToString:AT_tagScreen]){
            [self tagScreen:parameters];
        }
        else if ([tagName isEqualToString:AT_identify]){
            [self identify:parameters];
        }
        else if ([tagName isEqualToString:AT_tagEvent]){
            [self tagEvent:parameters];
        }
        else
            NSLog(@"Function %@ is not registered in the AT Internet handler of Cargo", tagName);
    }
    else
        [self.logger logUninitializedFramework];
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
 The method you need to call first. Allow you to initialize AT Internet SDK
 Register the domain and the siteId to the AT Internet SDK.
 
 @param parameters :
  - domain: domain AT Internet gives when you register your app
  - siteId: site ID AT Internet gives when you register your app
 */
-(void)init:(NSDictionary*)parameters{
    NSString* domain = [CARUtils castToNSString:[parameters objectForKey:LOG]];
    NSString* siteId = [CARUtils castToNSString:[parameters objectForKey:SITE_ID]];
    // weakSelf is used because of a warning about leaks in the async setConfig method
    __unsafe_unretained typeof(self) weakSelf = self;

    if(domain && siteId){
        [self.tracker setConfig:LOG value:domain completionHandler:^(BOOL isSet) {
            [weakSelf.logger logParamSetWithSuccess:LOG withValue:domain];
        }];
        [self.tracker setConfig:SITE_ID value:siteId completionHandler:^(BOOL isSet) {
            [weakSelf.logger logParamSetWithSuccess:SITE_ID withValue:siteId];
        }];

        self.initialized = TRUE;
    }
    else
        [self.logger logMissingParam:@"domain and/or siteId" inMethod:AT_init];
}


/* ****************************************** Tracking ****************************************** */

/**
 Method used to create and fire an event to the AT Internet interface
 The mandatory parameter is screenName which is a necessity to build the event.

 @param parameters :
  - screenName : the name of the screen tagged
  - customDim1/2 : custom dimensions (optional)
  - level2 : an int describing a second level of your screen (optional) (-1 turn this option off)
 */
- (void)tagScreen:(NSDictionary*)parameters{
    NSString* screenName = [CARUtils castToNSString:[parameters objectForKey:SCREEN_NAME]];
    int level2 = [CARUtils castToNSInteger:[parameters objectForKey:LEVEL2] withDefault:-1];
    
    if (screenName) {
        ATScreen *screen = [self.tracker.screens addWithName:screenName];

        if ([parameters valueForKey:CUSTOM_DIM1] && [parameters valueForKey:CUSTOM_DIM2]){
            NSString *customDim1 = [parameters valueForKey:CUSTOM_DIM1];
            NSString *customDim2 = [parameters valueForKey:CUSTOM_DIM2];
            
            [self.tracker.customObjects addWithDictionary:@{CUSTOM_DIM1: customDim1, CUSTOM_DIM2: customDim2}];
        }
        if (level2 != -1)
            screen.level2 = (int)[[parameters valueForKey:LEVEL2] integerValue];
        [screen sendView];
    }
    else
        [self.logger logMissingParam:SCREEN_NAME inMethod:AT_tagScreen];
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
        [self.logger logMissingParam:USER_ID inMethod:AT_identify];
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
        [self.logger logMissingParam:@"eventName and/or eventType" inMethod:AT_tagEvent];
}


/* ****************************************** Tracking ****************************************** */

/**
 Send the event, depending on which eventType was given in AT_tagEvent method
 This method is exclusively called by the tagEvent method (AT_tagEvent)

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

//
//  CARMobileAppTrackingTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARFacebookTagHandler.h"


/**
 The class which handles interactions with the Facebook SDK.
 */
@implementation CARFacebookTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString *FB_INIT = @"FB_init";
NSString *FB_ACTIVATE_APP = @"FB_activateApp";
NSString *FB_TAG_EVENT = @"FB_tagEvent";
NSString *FB_TAG_PURCHASE = @"FB_tagPurchase";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARFacebookTagHandler *handler = [[CARFacebookTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:FB_INIT];
    [Cargo registerTagHandler:handler withKey:FB_ACTIVATE_APP];
    [Cargo registerTagHandler:handler withKey:FB_TAG_EVENT];
    [Cargo registerTagHandler:handler withKey:FB_TAG_PURCHASE];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the Facebook handler
 */
- (id)init
{
    if (self = [super initWithKey:@"FB" andName:@"Facebook"]) {
        self.fbAppEvents = [FBSDKAppEvents class];
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

    if([tagName isEqualToString:FB_INIT]){
        [self init:parameters];
    }
    else if (self.initialized) {
        if([tagName isEqualToString:FB_ACTIVATE_APP]){
            [self activateApp];
        }
        else if([tagName isEqualToString:FB_TAG_EVENT]){
            [self tagEvent:parameters];
        }
        else if([tagName isEqualToString:FB_TAG_PURCHASE]){
            [self purchase:parameters];
        }
        else
            [self.logger logUnknownFunctionTag:tagName];
    }
    else
        [self.logger logUninitializedFramework];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Facebook SDK
 Register the application ID to the Facebook SDK.
 
 @param parameters :
 - applicationId: an app ID Facebook gives when you register your app
 */
-(void) init:(NSDictionary*) parameters{
    NSString* APP_ID = @"applicationId";
    NSString* applicationId = [CARUtils castToNSString:[parameters objectForKey:APP_ID]];
    
    // setup the app id to the fb SDK
    if (applicationId){
        [self.fbAppEvents setLoggingOverrideAppID:applicationId];
        [self.logger logParamSetWithSuccess:APP_ID withValue:applicationId];
        self.initialized = TRUE;
        [self activateApp];
    }
    else
        [self.logger logMissingParam:APP_ID inMethod:FB_INIT];
}


/* ****************************************** Tracking ****************************************** */

/**
 Let the Facebook SDK know that your app has been launched in order to measure sessions
 Call it in app delegate's applicationDidBecomeActive method once the handler has been initialized
 */
-(void) activateApp{
    [self.fbAppEvents activateApp];
    [self.logger FIFLog:kTAGLoggerLogLevelInfo withMessage:@"Application activation hit sent."];
}

/**
 Send an event to facebook SDK. eventName parameter is required.
 Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
 When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
 that can represent any value (e.g., a price or a quantity).
 Note that both the valueToSum and parameters arguments are optional.

 @param parameters :
 - eventName: the name of the event, which is mandatory
 - valueToSum: the value to sum
 - parameters: other parameters you would like to link to the event
 */
-(void) tagEvent:(NSDictionary*) parameters{
    NSString* VALUE_TO_SUM = @"valueToSum";
    NSString* eventName = [CARUtils castToNSString:[parameters objectForKey:EVENT_NAME]];
    NSNumber* valueToSum = [CARUtils castToNSNumber:[parameters objectForKey:VALUE_TO_SUM]];

    if (eventName) {
        NSMutableDictionary *params = [parameters mutableCopy];
        [params removeObjectForKey:EVENT_NAME];
        
        if (valueToSum != nil){
            [params removeObjectForKey:VALUE_TO_SUM];
            double value = [valueToSum doubleValue];
            
            if (params.count > 0){
                [self.fbAppEvents logEvent:eventName valueToSum:value parameters:params];
                [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
                [self.logger logParamSetWithSuccess:VALUE_TO_SUM withValue:valueToSum];
                [self.logger logParamSetWithSuccess:@"params" withValue:params];
                return ;
            }
            [self.fbAppEvents logEvent:eventName valueToSum:value];
            [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
            [self.logger logParamSetWithSuccess:VALUE_TO_SUM withValue:valueToSum];
            return ;
        }
        else if (params.count > 0) {
            [self.fbAppEvents logEvent:eventName parameters:params];
            [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
            [self.logger logParamSetWithSuccess:@"params" withValue:params];
        }
        else {
            [self.fbAppEvents logEvent:eventName];
            [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
        }
    }
    else
        [self.logger logMissingParam:EVENT_NAME inMethod:FB_TAG_EVENT];
}

/**
 Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
 The currency specification is expected to be an ISO 4217 currency code (EUR, USD, ...)

 @param parameters :
  - transactionTotal: the amount of the purchase, which is mandatory
  - transactionCurrencyCode: the currency of the purchase, which is mandatory
 */
-(void) purchase:(NSDictionary*) parameters{
    NSNumber* total = [CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]];
    NSString* currencyCode = [CARUtils castToNSString:
                              [parameters objectForKey:TRANSACTION_CURRENCY_CODE]];

    if (total != nil && currencyCode) {
        double purchaseAmount = [total doubleValue];
        [self.fbAppEvents logPurchase:purchaseAmount currency:currencyCode];
    }
    else
        [self.logger logMissingParam:@"transactionTotal and/or transactionCurrencyCode"
                            inMethod:FB_TAG_PURCHASE];
}

@end

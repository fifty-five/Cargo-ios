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
NSString *FB_init = @"FB_init";
NSString *FB_activateApp = @"FB_activateApp";
NSString *FB_tagEvent = @"FB_tagEvent";
NSString *FB_purchase = @"FB_purchase";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARFacebookTagHandler *handler = [[CARFacebookTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:FB_init];
    [Cargo registerTagHandler:handler withKey:FB_activateApp];
    [Cargo registerTagHandler:handler withKey:FB_tagEvent];
    [Cargo registerTagHandler:handler withKey:FB_purchase];
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

    if([tagName isEqualToString:FB_init]){
        [self init:parameters];
    }
    else if (self.initialized) {
        if([tagName isEqualToString:FB_activateApp]){
            [self activateApp];
        }
        else if([tagName isEqualToString:FB_tagEvent]){
            [self tagEvent:parameters];
        }
        else if([tagName isEqualToString:FB_purchase]){
            [self purchase:parameters];
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
        [self.logger logMissingParam:APP_ID inMethod:FB_init];
}


/* ****************************************** Tracking ****************************************** */

/**
 Let the Facebook SDK know that your app has been launched in order to measure sessions
 Call it in app delegate's applicationDidBecomeActive method once the handler has been initialized
 */
-(void) activateApp{
    [self.fbAppEvents activateApp];
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
                return ;
            }
            [self.fbAppEvents logEvent:eventName valueToSum:value];
        }
        else if (params.count > 0) {
            [self.fbAppEvents logEvent:eventName parameters:params];
        }
        else
            [self.fbAppEvents logEvent:eventName];
    }
    else
        [self.logger logMissingParam:EVENT_NAME inMethod:FB_tagEvent];
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

    if (total && currencyCode) {
        double purchaseAmount = [total doubleValue];
        [self.fbAppEvents logPurchase:purchaseAmount currency:currencyCode];
    }
    else
        [self.logger logMissingParam:@"transactionTotal and/or transactionCurrencyCode"
                            inMethod:FB_purchase];
}


/**
 Check wheter the SDK has been initialized

 @return true for an initialized SDK, false otherwise
 */
- (BOOL)isInitialized{
    return self.initialized;
}

@end

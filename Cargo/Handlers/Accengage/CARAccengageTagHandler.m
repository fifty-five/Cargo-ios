//
//  CARAccengageTagHandler.m
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARAccengageTagHandler.h"


@interface CARAccengageTagHandler()


@end


/**
 The class which handles interactions with the Accengage SDK.
 */
@implementation CARAccengageTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* const ACC_INIT = @"ACC_init";
NSString* const ACC_TAG_EVENT = @"ACC_tagEvent";
NSString* const ACC_TAG_PURCHASE = @"ACC_tagPurchase";
NSString* const ACC_TAG_ADD_TO_CART = @"ACC_tagAddToCart";
NSString* const ACC_TAG_LEAD = @"ACC_tagLead";
NSString* const ACC_UPDATE_DEVICE_INFO = @"ACC_updateDeviceInfo";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARAccengageTagHandler *handler = [[CARAccengageTagHandler alloc] init];

    [Cargo registerTagHandler:handler withKey:ACC_INIT];
    [Cargo registerTagHandler:handler withKey:ACC_TAG_EVENT];
    [Cargo registerTagHandler:handler withKey:ACC_TAG_PURCHASE];
    [Cargo registerTagHandler:handler withKey:ACC_TAG_ADD_TO_CART];
    [Cargo registerTagHandler:handler withKey:ACC_TAG_LEAD];
    [Cargo registerTagHandler:handler withKey:ACC_UPDATE_DEVICE_INFO];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.

 @return the instance of the Accengage handler
 */
- (id)init{
    if (self = [super initWithKey:@"ACC" andName:@"Accengage"]) {

        self.cargo = [Cargo sharedHelper];
        self.tracker = [Accengage class];
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

    if([tagName isEqualToString:ACC_INIT]){
        [self init:parameters];
    }
    // check whether the SDK has been initialized before calling any method
    else if (self.initialized) {
        if([tagName isEqualToString:ACC_TAG_EVENT]){
            [self tagEvent:parameters];
        }
        else if([tagName isEqualToString:ACC_TAG_PURCHASE]){
            [self tagEventPurchase:parameters];
        }
        else if([tagName isEqualToString:ACC_TAG_ADD_TO_CART]){
            [self tagCartEvent:parameters];
        }
        else if([tagName isEqualToString:ACC_TAG_LEAD]){
            [self tagLead:parameters];
        }
        else if([tagName isEqualToString:ACC_UPDATE_DEVICE_INFO]){
            [self updateDeviceInfo:parameters];
        }
        else
            [self.logger logUnknownFunctionTag:tagName];
    }
    else
        [self.logger logUninitializedFramework];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Accengage SDK
 Register the private key and the partner ID to the Accengage SDK.

 @param privateKey: private key Accengage gives when you register your app
 @param partnerId: partner ID Accengage gives when you register your app
 */
-(void)init:(NSDictionary*)parameters{
    NSString* partnerId = [CARUtils castToNSString:[parameters objectForKey:@"partnerId"]];
    NSString* privateKey = [CARUtils castToNSString:[parameters objectForKey:@"privateKey"]];

    if(partnerId && privateKey){
        ACCConfiguration *config = [ACCConfiguration defaultConfig];
        config.appId = partnerId;
        config.appPrivateKey = privateKey;

        [self.tracker startWithConfig:config];
        // now the handler is initialized
        self.initialized = TRUE;
    }
    else {
        [self.logger logMissingParam:@"partnerId and/or privateKey" inMethod: ACC_INIT];
    }
}


/* ****************************************** Tracking ****************************************** */

/**
 Method used to create and fire an event to the Accengage interface
 The mandatory parameter is EVENT_ID which is a necessity to build the event.

 @param parameters :
    - eventId: an integer defining the type of event.
               The values below 1000 are reserved for Accengage usage.
               You can use custom event types starting from 1001.
    - other parameters: will be changed into an array of strings build from key + value.
                        All the strings in the array will be sent.
 */
-(void)tagEvent:(NSDictionary*)parameters{
    // change the parameters as a mutable dictionary
    NSMutableDictionary *params = [parameters mutableCopy];
    NSMutableArray *eventParams = [[NSMutableArray alloc] init];
    NSInteger eventType = [CARUtils castToNSInteger:[params objectForKey:EVENT_TYPE] withDefault:-1];
    // remove the entry for EVENT_TYPE in order to avoid finding it in the array of parameters
    [params removeObjectForKey:EVENT_TYPE];
    if (eventType > 1000) {
        for (NSMutableString *key in params) {
            // rebuilding the dictionary as an array of strings
            [eventParams addObject:[key stringByAppendingString:
                                    [@": " stringByAppendingString:params[key]]
                                    ]];
        }
        // send the event
        [self.tracker trackEvent:eventType withParameters:eventParams];
    }
    else {
        [self.logger logMissingParam:EVENT_TYPE inMethod: ACC_TAG_EVENT];
    }
}

/**
 The method used to report a purchase in your app in Accengage.
 TRANSACTION_ID, TRANSACTION_CURRENCY_CODE are required.
 TRANSACTION_TOTAL and/or TRANSACTION_PRODUCTS is required.

 @param parameters :
    - transactionId : the ID linked to the purchase.
    - transactionCurrencyCode : the currency used for the transaction.
    - transactionTotal : the total amount of the purchase.
    - transactionProducts : an array of AccengageItem objects, the items purchased.
 */
-(void)tagEventPurchase:(NSDictionary*)parameters{
    NSString *purchaseId = [CARUtils castToNSString:[parameters objectForKey:TRANSACTION_ID]];
    NSString *currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];

    // check for the two mandatory variables
    if (currencyCode && purchaseId) {
        // check for TRANSACTION_PRODUCTS, creation of an array of accengage items
        NSArray *itemArray = [CARUtils castToNSArray:[parameters objectForKey:TRANSACTION_PRODUCTS]];
        if (itemArray && [itemArray[0] class] == [AccengageItem class]) {
            NSMutableArray *finalArray = [NSMutableArray array];
            for (AccengageItem* item in itemArray) {
                [finalArray addObject:[item toA4SItem]];
            }
            // if TRANSACTION_TOTAL is set, send a hit with it. Otherwise, send a hit without total.
            NSNumber* total = [CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]];
            if (total)
               [self.tracker trackPurchase:purchaseId currency:currencyCode items:finalArray amount: total];
            else
                [self.tracker trackPurchase:purchaseId currency:currencyCode items:finalArray amount:nil];
        }
        // if TRANSACTION_PRODUCTS isn't set, check for TRANSACTION_TOTAL
        else if ([parameters objectForKey:TRANSACTION_TOTAL]) {
            NSNumber* total = [CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]];
            [self.tracker trackPurchase:purchaseId currency:currencyCode items:nil amount: total];
        }
        else
            [self.logger logMissingParam:@"transactionTotal and/or transactionProducts" inMethod: ACC_TAG_PURCHASE];
    }
    else {
        [self.logger logMissingParam:@"transactionId or currencyCode" inMethod: ACC_TAG_PURCHASE];
    }
}

/**
 The method used to report an "add to cart" event to Accengage. It logs the id of the cart,
 the currency code and the item which has been added. All the parameters are mandatory.

 @param parameters :
    - transactionId : the id associated to this cart.
    - transactionCurrencyCode : the currency used for the transaction.
    - item (AccengageItem) : the item which is added to the cart.
 */
-(void)tagCartEvent:(NSDictionary*)parameters{
    NSString *cartId = [CARUtils castToNSString:[parameters objectForKey:@"cartId"]];
    NSString *currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];
    AccengageItem* item = [parameters objectForKey:@"product"];

    // if all the mandatory parameters are set, send the hit
    if (cartId && currencyCode && item) {
        [self.tracker trackCart:cartId currency:currencyCode item:[item toA4SItem]];
    }
    else
        [self.logger logMissingParam:@"cartId or currencyCode or product" inMethod: ACC_TAG_ADD_TO_CART];
}

/**
 The method used to create and fire a custom lead to Accengage.
 Both parameters are mandatory.

 @param parameters :
    - leadLabel : label of the lead
    - leadValue : value of the lead
 */
-(void)tagLead:(NSDictionary*)parameters{
    NSString *leadLabel = [CARUtils castToNSString:[parameters objectForKey:@"leadLabel"]];
    NSString *leadValue = [CARUtils castToNSString:[parameters objectForKey:@"leadValue"]];
    if (leadLabel && leadValue)
        [self.tracker trackLead:leadLabel value:leadValue];
    else
        [self.logger logMissingParam:@"leadLabel or leadValue" inMethod: ACC_TAG_LEAD];
}

/**
 A device profile is a set of key/value that are uploaded to Accengage server.
 You can create a device profile for each device in order to qualify the profile
 (for example, registering whether the user is opt in for or
 out of some categories of notifications).
 In order to update information about a device profile, use this method.
 If you want to send a date, be sure it is formatted as it follows : "yyyy-MM-dd HH:mm:ss zzz"

 @param parameters a dictionary of parameters to update the profile with.
 */
-(void)updateDeviceInfo:(NSDictionary*)parameters{
    [self.tracker updateDeviceInfo:parameters];
}

@end

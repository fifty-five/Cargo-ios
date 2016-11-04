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

@implementation CARAccengageTagHandler

NSString *ACC_init = @"ACC_init";
NSString *ACC_tagEvent = @"ACC_tagEvent";
NSString *ACC_tagPurchaseEvent = @"ACC_tagPurchaseEvent";
NSString *ACC_tagCartEvent = @"ACC_tagCartEvent";
NSString *ACC_tagLead = @"ACC_tagLead";
NSString *ACC_updateDeviceInfo = @"ACC_updateDeviceInfo";

+(void)load{
    CARAccengageTagHandler *handler = [[CARAccengageTagHandler alloc] init];
    
    [Cargo registerTagHandler:handler withKey:ACC_init];
    [Cargo registerTagHandler:handler withKey:ACC_tagEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagPurchaseEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagCartEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagLead];
    [Cargo registerTagHandler:handler withKey:ACC_updateDeviceInfo];
}

//Call back from GTM container to execute a specific action
//after tag and parameters are received
//
//@param tagName  The tag name
//@param parameters   Dictionary of parameters
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:ACC_init]){
        [self init:parameters];
    }
    else if (self.initialized) {
        if([tagName isEqualToString:ACC_tagEvent]){
            [self tagEvent:parameters];
        }
        else if([tagName isEqualToString:ACC_tagPurchaseEvent]){
            [self tagEventPurchase:parameters];
        }
        else if([tagName isEqualToString:ACC_tagCartEvent]){
            [self tagCartEvent:parameters];
        }
        else if([tagName isEqualToString:ACC_tagLead]){
            [self tagLead:parameters];
        }
        else if([tagName isEqualToString:ACC_updateDeviceInfo]){
            [self updateDeviceInfo:parameters];
        }
        else
            NSLog(@"Function %@ is not registered in the Accengage handler of Cargo", tagName);
    }
    else
        [[self.cargo logger] logUninitializedFramework];
}

- (id)init{
    if (self = [super init]) {
        self.key = @"ACC";
        self.name = @"Accengage";
        self.valid = NO;
        self.initialized = NO;
        self.cargo = [Cargo sharedHelper];
        self.tracker = [BMA4STracker class];
    }
    return self;
}

- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}

//Is called to set the tracking ID
//
//@param parameters   Dictionary of parameters which should contain the partner_id and the private_key
-(void)init:(NSDictionary*)parameters{
    NSString* partnerId = [CARUtils castToNSString:[parameters objectForKey:@"partnerId"]];
    NSString* privateKey = [CARUtils castToNSString:[parameters objectForKey:@"privateKey"]];
    NSURL* url = [parameters objectForKey:@"url"];

    if(partnerId && privateKey){
        if ([self.cargo isLaunchOptionsSet]) {
            [self.tracker trackWithPartnerId:partnerId privateKey:privateKey options:[self.cargo launchOptions]];
            self.initialized = TRUE;
        }
        else {
            [[self.cargo logger] logMissingParam:@"launchOptions has to be set and" inMethod:@"Accengage/init"];
        }
    }
    else {
        [[self.cargo logger] logMissingParam:@"partnerId or privateKey" inMethod: @"Accengage/init"];
    }

    if (url){
        [[BMA4SNotification sharedBMA4S] applicationHandleOpenUrl:url];
        [[self.cargo logger] logParamSetWithSuccess:@"url" withValue:url];
    }
}

//The method used to send events to Accengage
//
//@param parameters Dictionary of parameters which should contain at least the eventType
//
//The event type is an integer defining the type of event. The values below 1000 are reserved for Accengage usage.
//You can use custom event types starting from 1001.
//
//The left content of parameters will be changed into an array of strings. All the strings in the array will be sent.
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
            [eventParams addObject:[key stringByAppendingString:[@": " stringByAppendingString:params[key]]]];
        }
        // send the event
        [self.tracker trackEventWithType:(NSInteger) eventType parameters:(NSArray *) eventParams];
    }
    else {
        [[self.cargo logger] logMissingParam:EVENT_TYPE inMethod: ACC_tagEvent];
    }
}

//The method used to send purchase events to Accengage
//
//@param parameters Dictionary of parameters which should contain at least TRANSACTION_ID, currencyCode,
//and TRANSACTION_TOTAL or TRANSACTION_PRODUCTS
//
//                * TRANSACTION_ID : the ID linked to the purchase.
//                * currencyCode : the currency used for the transaction.
//                * TRANSACTION_TOTAL : the total amount of the purchase.
//                * TRANSACTION_PRODUCTS : an array of AccengageItem objects, the items purchased.
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
            double total = [[CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]] doubleValue];
            if (total)
                [self.tracker trackPurchaseWithId:purchaseId currency:currencyCode items:finalArray totalPrice: total];
            else
                [self.tracker trackPurchaseWithId:purchaseId currency:currencyCode items:finalArray];
        }
        // if TRANSACTION_PRODUCTS isn't set, check for TRANSACTION_TOTAL
        else if ([parameters objectForKey:TRANSACTION_TOTAL]) {
            double total = [[CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]] doubleValue];
            [self.tracker trackPurchaseWithId:purchaseId currency:currencyCode totalPrice: total];
        }
        else
            [[self.cargo logger] logMissingParam:@"transactionTotal and/or transactionProducts" inMethod: ACC_tagPurchaseEvent];
    }
    else {
        [[self.cargo logger] logMissingParam:@"transactionId or currencyCode" inMethod: ACC_tagPurchaseEvent];
    }
}

//The method used to report add-to-cart events to Accengage
//
//@param parameters Dictionary of parameters
//
//                * cartId : the ID linked to the add to cart event.
//                * currencyCode : the currency used for the pricing.
//                * product : an AccengageItem object, the one added to cart.
-(void)tagCartEvent:(NSDictionary*)parameters{
    NSString *cartId = [CARUtils castToNSString:[parameters objectForKey:@"cartId"]];
    NSString *currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];
    AccengageItem* item = [parameters objectForKey:@"product"];
    if (cartId && currencyCode && item) {
        [self.tracker trackCartWithId:cartId forArticleWithId:item.ID andLabel:item.label category:item.category price:item.price currency:currencyCode quantity:item.quantity];
    }
    else
        [[self.cargo logger] logMissingParam:@"cartId or currencyCode or product" inMethod: ACC_tagCartEvent];
}

//The method used to track a lead in Accengage
//
//@param parameters Dictionary of parameters
//
//                * leadLabel : the label.
//                * leadValue : the value.
-(void)tagLead:(NSDictionary*)parameters{
    NSString *leadLabel = [CARUtils castToNSString:[parameters objectForKey:@"leadLabel"]];
    NSString *leadValue = [CARUtils castToNSString:[parameters objectForKey:@"leadValue"]];
    if (leadLabel && leadValue)
        [self.tracker trackLeadWithLabel:leadLabel value:leadValue];
    else
        [[self.cargo logger] logMissingParam:@"leadLabel or leadValue" inMethod: ACC_tagLead];
}


//Method used in order to update the device infos, like the device id or name...
//If you want to send a date, be sure it is formatted as it follows : "yyyy-MM-dd HH:mm:ss zzz"
//
//@param parameters Dictionary of parameters you want to be set for this device.
-(void)updateDeviceInfo:(NSDictionary*)parameters{
    [self.tracker updateDeviceInfo:parameters];
}

@end

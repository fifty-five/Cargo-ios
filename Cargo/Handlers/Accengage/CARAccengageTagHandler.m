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

+(void)load{
    CARAccengageTagHandler *handler = [[CARAccengageTagHandler alloc] init];
    
    [Cargo registerTagHandler:handler withKey:ACC_init];
    [Cargo registerTagHandler:handler withKey:ACC_tagEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagPurchaseEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagCartEvent];
    [Cargo registerTagHandler:handler withKey:ACC_tagLead];
}


-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:ACC_init]){
        [self init:parameters];
    }
    else if([tagName isEqualToString:ACC_tagEvent]){
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
}

- (id)init{
    if (self = [super init]) {
        self.key = @"ACC";
        self.name = @"Accengage";
        self.valid = NO;
        self.initialized = NO;
        self.cargo = [Cargo sharedHelper];
    }
    return self;
}

- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}

-(void)init:(NSDictionary*)parameters{
    NSString* partnerId = [CARUtils castToNSString:[parameters objectForKey:@"partnerId"]];
    NSString* privateKey = [CARUtils castToNSString:[parameters objectForKey:@"privateKey"]];
    NSURL* url = [parameters objectForKey:@"url"];

    if(partnerId && privateKey){
        if ([self.cargo isLaunchOptionsSet])
            [BMA4STracker trackWithPartnerId:partnerId privateKey:privateKey options:[self.cargo launchOptions]];
    }
    else {
        [[self.cargo logger] logMissingParam:@"partnerId or privateKey" inMethod: @"Accengage/init"];
    }

    if (url){
        [[BMA4SNotification sharedBMA4S] applicationHandleOpenUrl:url];
    }
    else {
         [[self.cargo logger] logMissingParam:@"url" inMethod: ACC_init];
    }
}


-(void)tagEvent:(NSDictionary*)parameters{
    NSMutableDictionary *params = [parameters mutableCopy];
    NSMutableArray *eventParams = [[NSMutableArray init] alloc];
    NSInteger eventType = [CARUtils castToNSInteger:[params objectForKey:EVENT_TYPE] withDefault:-1];
    [params removeObjectForKey:EVENT_TYPE];
    if (eventType != -1) {
        for (NSMutableString *key in params) {
            [eventParams addObject:[key stringByAppendingString:params[key]]];
        }
        [BMA4STracker trackEventWithType:(NSInteger) eventType parameters:(NSArray *) eventParams];
    }
    else {
        [[self.cargo logger] logMissingParam:EVENT_TYPE inMethod: ACC_tagEvent];
    }
}

-(void)tagEventPurchase:(NSDictionary*)parameters{
    NSString *purchaseId = [CARUtils castToNSString:[parameters objectForKey:TRANSACTION_ID]];
    NSString *currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];
    if (currencyCode && purchaseId) {
        NSArray *itemArray = [CARUtils castToNSArray:[parameters objectForKey:TRANSACTION_PRODUCTS]];
        if (itemArray) {
            NSMutableArray *finalArray = [NSMutableArray array];
            for (AccengageItem* item in itemArray) {
                [finalArray addObject:[BMA4SPurchasedItem itemWithId:item.ID
                                                               label:item.label
                                                            category:item.category
                                                               price:item.price
                                                            quantity:item.quantity]];
            }

            double total = [[CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]] doubleValue];
            if (total)
                [BMA4STracker trackPurchaseWithId:purchaseId currency:currencyCode items:finalArray totalPrice: total];
            else
                [BMA4STracker trackPurchaseWithId:purchaseId currency:currencyCode items:finalArray];
        }
        else if ([parameters objectForKey:TRANSACTION_TOTAL]) {
            double total = [[CARUtils castToNSNumber:[parameters objectForKey:TRANSACTION_TOTAL]] doubleValue];
            [BMA4STracker trackPurchaseWithId:purchaseId currency:currencyCode totalPrice: total];
        }
        else
            [[self.cargo logger] logMissingParam:@"transactionTotal and/or transactionProducts" inMethod: ACC_tagPurchaseEvent];
    }
    else {
        [[self.cargo logger] logMissingParam:@"transactionId or currencyCode" inMethod: ACC_tagPurchaseEvent];
    }
}

-(void)tagCartEvent:(NSDictionary*)parameters{
    NSString *cartId = [CARUtils castToNSString:[parameters objectForKey:@"cartId"]];
    NSString *currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];
    AccengageItem* item = [parameters objectForKey:@"product"];
    if (cartId && currencyCode && item) {
        [BMA4STracker trackCartWithId:cartId forArticleWithId:item.ID andLabel:item.label category:item.category price:item.price currency:currencyCode quantity:item.quantity];
    }
    else
        [[self.cargo logger] logMissingParam:@"cartId or currencyCode or product" inMethod: ACC_tagCartEvent];
}

-(void)tagLead:(NSDictionary*)parameters{
    NSString *leadLabel = [CARUtils castToNSString:[parameters objectForKey:@"leadLabel"]];
    NSString *leadValue = [CARUtils castToNSString:[parameters objectForKey:@"leadValue"]];
    if (leadLabel && leadValue)
        [BMA4STracker trackLeadWithLabel:leadLabel value:leadValue];
    else
        [[self.cargo logger] logMissingParam:@"leadLabel or leadValue" inMethod: ACC_tagLead];
}


@end

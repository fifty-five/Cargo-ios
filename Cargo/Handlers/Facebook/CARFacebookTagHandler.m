//
//  CARMobileAppTrackingTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARFacebookTagHandler.h"



@implementation CARFacebookTagHandler


// The runtime sends the load message very soon after the class object
// is loaded in the process's address space. (http://stackoverflow.com/a/13326633)
//
// Instanciate the handler, and register its callback methods to GTM through a Cargo method
+(void)load{
    CARFacebookTagHandler *handler = [[CARFacebookTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"FB_init"];
    [Cargo registerTagHandler:handler withKey:@"FB_activateApp"];
    [Cargo registerTagHandler:handler withKey:@"FB_tagEvent"];
    [Cargo registerTagHandler:handler withKey:@"FB_purchase"];
}


// This one will be called after a tag has been sent
//
// @param tagName       The method you aime to call (this should be define in GTM interface)
// @param parameters    A dictionary key-object used as a way to give parameters to the class method aimed here
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"FB_init"]){
        [self init:parameters];
    }
    else if([tagName isEqualToString:@"FB_activateApp"]){
        [self activateApp];
    }
    else if([tagName isEqualToString:@"FB_tagEvent"]){
        [self tagEvent:parameters];
    }
    else if([tagName isEqualToString:@"FB_purchase"]){
        [self purchase:parameters];
    }

}


// Called in +load method, setup what is needed for Cargo and the facebook SDK
- (id)init
{
    if (self = [super init]) {
        self.key = @"FB";
        self.name = @"Facebook";
        self.valid = NO;
        self.initialized = NO;
        self.fbAppEvents = [FBSDKAppEvents class];
    }
    return self;
}


- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}



// Initialize Facebook with required parameters
-(void) init:(NSDictionary*) parameters{

    // get the application id Facebook gave you when you created your facebook app from parameters
    NSString *applicationId = [parameters objectForKey:@"applicationId"];
    
    // setup the app id to the fb SDK
    if (applicationId){
        [self.fbAppEvents setLoggingOverrideAppID:applicationId];
        FIFLog(kTAGLoggerLogLevelInfo, @" Facebook appId set to %@ ", applicationId);

    }
    
    self.initialized = TRUE;
    [self activateApp];
}


// let the fb sdk know that your app has been launched in order to measure sessions
// Call it in your app delegate's applicationDidBecomeActive method once the handler has been initialized
-(void) activateApp{
    [self.fbAppEvents activateApp];
}


// Send an event to facebook SDK. Calls differents methods depending on which parameters have been given
// Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
// When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
// that can represent any value (e.g., a price or a quantity).
// Note that both the valueToSum and parameters arguments are optional.
-(void) tagEvent:(NSDictionary*) parameters{
    if (![parameters objectForKey:EVENT_NAME]){
        NSLog(@"Cargo FacebookHandler : in tagEvent() missing mandatory parameter EVENT_NAME. The event hasn't been sent");
        return ;
    }
    NSMutableDictionary *params = [parameters mutableCopy];
    NSString *eventName = [CARUtils castToNSString:[params objectForKey:EVENT_NAME]];
    [params removeObjectForKey:EVENT_NAME];

    if ([params objectForKey:@"valueToSum"]){
        double valueToSum = [[CARUtils castToNSNumber:[params objectForKey:@"valueToSum"]] doubleValue];
        [params removeObjectForKey:@"valueToSum"];

        if (params.count > 0){
            [self.fbAppEvents logEvent:eventName valueToSum:valueToSum parameters:params];
            return ;
        }
        [self.fbAppEvents logEvent:eventName valueToSum:valueToSum];
        return ;
    }
    if (params.count > 0) {
        [self.fbAppEvents logEvent:eventName parameters:params];
        return ;
    }
    [self.fbAppEvents logEvent:eventName];
}


// Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
// The currency specification is expected to be an ISO 4217 currency code.
-(void) purchase:(NSDictionary*) parameters{
    if (![parameters objectForKey:@"purchaseAmount"] || ![parameters objectForKey:@"currencyCode"]){
        NSLog(@"Cargo FacebookHandler : in purchase() missing at least one of the parameters. The purchase hasn't been registered");
        return ;
    }
    double purchaseAmount = [[CARUtils castToNSNumber:[parameters objectForKey:@"purchaseAmount"]] doubleValue];
    NSString* currencyCode = [CARUtils castToNSString:[parameters objectForKey:@"currencyCode"]];
    [self.fbAppEvents logPurchase:purchaseAmount currency:currencyCode];
}


- (BOOL)isInitialized{
    return self.initialized;
}

@end

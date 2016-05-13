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


@implementation CARATInternetTagHandler


// The runtime sends the load message very soon after the class object
// is loaded in the process's address space. (http://stackoverflow.com/a/13326633)
//
// Instanciate the handler, and register its callback methods to GTM through a Cargo method
+(void)load{
    CARATInternetTagHandler *handler = [[CARATInternetTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"AT_init"];
    [Cargo registerTagHandler:handler withKey:@"AT_identify"];
    [Cargo registerTagHandler:handler withKey:@"AT_tagScreen"];
    [Cargo registerTagHandler:handler withKey:@"AT_tagEvent"];
}


// This one will be called after a tag has been sent
//
// @param tagName       The method you aime to call (this should be define in GTM interface)
// @param parameters    A dictionary key-object used as a way to give parameters to the class method aimed here
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];

    if ([tagName isEqualToString:@"AT_init"]){
        [self init:parameters];
    }
    else if ([tagName isEqualToString:@"AT_tagScreen"]){
        [self tagScreen:parameters];
    }
    else if ([tagName isEqualToString:@"AT_identify"]){
        [self identify:parameters];
    }
    else if ([tagName isEqualToString:@"AT_tagEvent"]){
        [self tagEvent:parameters];
    }
    else
        NSLog(@"Function %@ is not registered in the AT Internet handler of Cargo", tagName);
}


// Called in +load method, setup what is needed for Cargo and the ATInternet SDK
- (id)init
{
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


- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}

// Initialize ATInternet with required parameters
-(void)init:(NSDictionary*)parameters{
    NSString* domain = [parameters valueForKey:@"domain"];
    if(domain){
        [self.tracker setConfig:@"domain" value:domain completionHandler:nil];
    }
    
    NSString* siteId = [parameters valueForKey:@"siteId"];
    if (siteId) {
        [self.tracker setConfig:@"siteId" value:siteId completionHandler:nil];
    
    self.initialized = TRUE;

    }
}


// Send a tag for the screen changes to Tune
// Allow you to add custom_dim to your tag
- (void)tagScreen:(NSDictionary*)parameters{
    
    NSString* screenName = [parameters valueForKey:SCREEN_NAME];
    
    if ([parameters valueForKey:CUSTOM_DIM1] && [parameters valueForKey:CUSTOM_DIM2]){
        NSString *customDim1 = [parameters valueForKey:CUSTOM_DIM1];
        NSString *customDim2 = [parameters valueForKey:CUSTOM_DIM2];
        
        [self.tracker.customObjects addWithDictionary:@{CUSTOM_DIM1: customDim1, CUSTOM_DIM2: customDim2}];
    }

    ATScreen *screen = [self.tracker.screens addWithName:screenName];
    screen.level2 = (int)[[parameters valueForKey:LEVEL2] integerValue];
    [screen sendView];
}

// Allow you to identify the user through the UUID you have to give as a parameter under the USER_ID key
- (void)identify:(NSDictionary*)parameters{
  
    if ([parameters valueForKey:USER_ID]){
        [self.tracker setConfig:USER_ID value:[parameters valueForKey:USER_ID] completionHandler:nil];
        return;
    }
    NSLog(@"CARGO_ATInternet_identify: missing USER_ID (UUID) parameter. USER_ID hasn't been set");
}

// Send a custom event to ATInternet
// Please provide a event name and type as mandatory parameters
// Possibility to attach up to 3 chapters to the event
- (void)tagEvent:(NSDictionary*)parameters{
    
    NSString* tagName = [parameters valueForKey:EVENT_NAME];
    NSString* tagValue = [parameters valueForKey:EVENT_TYPE];
    
    ATGesture *gesture = [self.tracker.gestures addWithName:tagName];
    
    if ([parameters valueForKey:@"chapter1"]){
        
        [gesture setChapter1:[parameters valueForKey:@"chapter1"]];
        if ([parameters valueForKey:@"chapter2"]){
            
            [gesture setChapter2: [parameters valueForKey:@"chapter2"]];
            if ([parameters valueForKey:@"chapter3"]){
                
                [gesture setChapter3: [parameters valueForKey:@"chapter3"]];
            }
        }
    }
    
    gesture.level2 = (int)[[parameters valueForKey:LEVEL2] integerValue];
    
    if ([tagValue isEqualToString:@"sendTouch"]) {
        [gesture sendTouch];
    }
    else if ([tagValue isEqualToString:@"sendNavigation"]){
        [gesture sendNavigation];
    }
    else if ([tagValue isEqualToString:@"sendDownload"]){
        [gesture sendDownload];
    }
    else if ([tagValue isEqualToString:@"sendExit"]){
        [gesture sendExit];
    }
    else if ([tagValue isEqualToString:@"sendSearch"]){
        [gesture sendSearch];
    }
    else{
        NSLog(@"CARGO_ATInternet_tagEvent: no EVENT_TYPE provided. Event hasn't been sent.");
    }
}


@end

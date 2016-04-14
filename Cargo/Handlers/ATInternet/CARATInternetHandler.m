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


+(void)load{
    CARATInternetTagHandler *handler = [[CARATInternetTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"AT_init"];
    [Cargo registerTagHandler:handler withKey:@"AT_identify"];
    [Cargo registerTagHandler:handler withKey: @"AT_tagScreen"];
}



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
}


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


- (void)identify:(NSDictionary*)parameters{
  
    if ([parameters valueForKey:USER_ID]){
        [self.tracker setConfig:USER_ID value:[parameters valueForKey:USER_ID] completionHandler:nil];
        return;
    }
    NSLog(@"Missing USER_ID parameter in AT_identify");
}


@end

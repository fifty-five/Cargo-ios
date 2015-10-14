//
//  GAFunctionCallTagHandler_v3.0.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARATInternetTagHandler.h"

#import "FIFLogger.h"


@interface CARATInternetTagHandler()


@end


@implementation CARATInternetTagHandler


+(void)load{
    CARATInternetTagHandler *handler = [[CARATInternetTagHandler alloc] init];
    
    [Cargo registerTagHandler:handler withKey:@"AT_init"];
}



-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];

    if ([tagName isEqualToString:@"AT_init"]){
        [self init:parameters];
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
    NSString* domain = [parameters objectForKey:@"domain"];
    if(domain){
        [self.tracker setConfig:@"domain" value:domain completionHandler:nil];
    }
    
    NSString* siteId = [parameters objectForKey:@"siteId"];
    if (siteId) {
        [self.tracker setConfig:@"siteId" value:siteId completionHandler:nil];
    
    self.initialized = TRUE;

    }
}




@end

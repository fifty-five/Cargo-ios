//
//  GAFunctionCallTagHandler_v3.0.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARGoogleAnalyticsMacroHandler.h"

#import "GAIFields.h"
#import "FIFLogger.h"


@implementation CARGoogleAnalyticsMacroHandler


+(void)load{
    CARGoogleAnalyticsMacroHandler * handler = [[CARGoogleAnalyticsMacroHandler alloc] init];
    [Cargo registerMacroHandler:handler forMacro:@"userGoogleId"];
    [Cargo registerMacroHandler:handler forMacro:@"idfa"];
}


- (id)init
{
    if (self = [super init]) {
        self.key = @"GA";
        self.name = @"Google Analytics";
        self.valid = NO;
        self.initialized = NO;
    }
    return self;
}




#pragma mark - GTMFunctionMacroCallBack
- (id)valueForMacro:(NSString *)functionName parameters:(NSDictionary *)parameters {
    if ([functionName isEqualToString:@"userGoogleId"]) {
        TAGManager *tagManager = [[Cargo sharedHelper] tagManager];
        if (tagManager) {
            // Fetch the Google Id
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            NSString * clientID  = [tracker get:kGAIClientId];
            return clientID;
        }
    }
    else if ([functionName isEqualToString:@"idfa"]) {
        if (![CARUtils isAdvertisingTrackingEnabled]) {
            return nil;
        }
        
        NSUUID *adId = [CARUtils advertisingIdentifier];
        if (adId) {
            return [adId UUIDString];
        }
    }
    
    return nil;
}

@end

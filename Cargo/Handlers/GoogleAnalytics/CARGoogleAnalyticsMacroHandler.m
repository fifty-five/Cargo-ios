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
#import "CARConstants.h"

/**
 The class which handles interactions with the Google Analytics SDK.
 */
@implementation CARGoogleAnalyticsMacroHandler

/**
 Called on runtime to instantiate the handler.
 Register the macros to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 */
+(void)load{
    CARGoogleAnalyticsMacroHandler * handler = [[CARGoogleAnalyticsMacroHandler alloc] init];
    [Cargo registerMacroHandler:handler forMacro:@"userGoogleId"];
    [Cargo registerMacroHandler:handler forMacro:@"idfa"];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.
 
 @return the instance of the Google Anayltics Macro handler
 */
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



/**
 * Returns an object which is the calculated value of the macro.
 * Handler is given the macro name and a dictionary of named parameters.
 *
 * @param macroName The same name by which the handler was registered. It
 *     is provided as a convenience to allow a single handler to be registered
 *     for multiple function call macros.
 * @param parameters The named parameters for the function call. The
 *     dictionary may contain <code>NSString</code>, <code>NSNumber</code>
 *     (double, int, or boolean), <code>NSDictionary</code>, or
 *     <code>NSArray</code>.
 * @return The evaluated result, which can be an <code>NSString</code> or
 *     <code>NSNumber</code>.
 */
#pragma mark - GTMFunctionMacroCallBack
- (id)valueForMacro:(NSString *)functionName parameters:(NSDictionary *)parameters {
    if ([functionName isEqualToString:USER_GOOGLE_ID]) {
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

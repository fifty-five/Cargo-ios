//
//  CARMobileAppTrackingTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARFacebookTagHandler.h"



@implementation CARFacebookTagHandler



+(void)load{
    CARFacebookTagHandler *handler = [[CARFacebookTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"FB_init"];
    [Cargo registerTagHandler:handler withKey:@"FB_tagEvent"];
}



-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"FB_init"]){
        [self init:parameters];
    }
    else if([tagName isEqualToString:@"FB_tagEvent"]){
        [self tagEvent:parameters];
    }

}


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

-(void) init:(NSDictionary*) parameters{
    
    //Initialize Tune with required parameters
    NSString *applicationId = [parameters objectForKey:@"applicationId"];
    
    
    if (applicationId){
        [self.fbAppEvents setLoggingOverrideAppID:applicationId];
        FIFLog(kTAGLoggerLogLevelInfo, @" Facebook appId set to %@ ", applicationId);

    }
    
    [self.fbAppEvents activateApp];
    self.initialized = TRUE;
    
    
    //then set values if necessary
    NSMutableDictionary * mutParams = [parameters mutableCopy];
    [mutParams removeObjectForKey:@"applicationId"];
    [self set:mutParams];
    
}

-(void) tagEvent:(NSDictionary*) parameters{
    [FBSDKAppEvents logEvent:[parameters objectForKey:EVENT_NAME]];
}


- (void)set:(NSDictionary *)parameters {
    
    
}





@end

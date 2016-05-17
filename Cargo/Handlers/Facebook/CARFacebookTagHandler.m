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
    [Cargo registerTagHandler:handler withKey:@"FB_tagEvent"];
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
    else if([tagName isEqualToString:@"FB_tagEvent"]){
        [self tagEvent:parameters];
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
    
    // let the fb sdk know that your app has been launched
    [self.fbAppEvents activateApp];
    self.initialized = TRUE;
    
    
    //then set values if necessary
    NSMutableDictionary * mutParams = [parameters mutableCopy];
    [mutParams removeObjectForKey:@"applicationId"];
    [self set:mutParams];
    
}

// Send an event to facebook SDK
-(void) tagEvent:(NSDictionary*) parameters{
    // retrieves the custom event from parameters and send its to FB
    [FBSDKAppEvents logEvent:[parameters objectForKey:EVENT_NAME]];
}


- (void)set:(NSDictionary *)parameters {
    
    
}





@end

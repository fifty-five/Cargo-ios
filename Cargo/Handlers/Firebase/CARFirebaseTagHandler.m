//
//  CARFirebaseTagHandler.m
//  Cargo
//
//  Created by Med on 19/07/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARFirebaseTagHandler.h"
#import "CARConstants.h"

@implementation CARFirebaseTagHandler

NSString *const ENABLE_COLLECTION = @"enableCollection";

// The runtime sends the load message very soon after the class object
// is loaded in the process's address space. (http://stackoverflow.com/a/13326633)
//
// Instanciate the handler, and register its callback methods to GTM through a Cargo method
+(void)load{
    CARFirebaseTagHandler *handler = [[CARFirebaseTagHandler alloc] init];
    [FIRApp configure];
    
    [Cargo registerTagHandler:handler withKey:@"Firebase_init"];
    [Cargo registerTagHandler:handler withKey:@"Firebase_identify"];
    [Cargo registerTagHandler:handler withKey:@"Firebase_tagEvent"];
}


// This one will be called after a tag has been sent
//
// @param tagName       The method you aim to call (this should be define in GTM interface)
// @param parameters    A dictionary key-object used as a way to give parameters to the class method aimed here
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"Firebase_init"]){
        [self init:parameters];
    } else if([tagName isEqualToString:@"Firebase_identify"]){
        [self identify:parameters];
    }else if([tagName isEqualToString:@"Firebase_tagEvent"]){
        [self tagEvent:parameters];
    }
}

// Setup what is needed for Cargo and the Firebase SDK
- (id)init
{
    if (self = [super init]) {
        self.key = @"Firebase";
        self.name = @"Firebase";
        self.valid = NO;
        self.initialized = NO;
    }
    return self;
}

- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
    self.initialized = YES;
}

// The method you may call first if you want to disable the Firebase analytics collection
// The parameter requested is a boolean true/false for collection enabled/disabled
// This setting is persisted across app sessions. By default it is enabled.
-(void) init:(NSDictionary*) parameters{
    if ([parameters objectForKey:ENABLE_COLLECTION]) {
        Boolean enabled = (Boolean)[parameters valueForKey:ENABLE_COLLECTION];
        [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:enabled];
    }
}

// Allow you to identify the user and to define the segment it belongs to
-(void) identify:(NSDictionary*) parameters{
    
    NSMutableDictionary *params = [parameters mutableCopy];
    if ([params objectForKey:USER_ID]) {
        [FIRAnalytics setUserID:[CARUtils castToNSString:[params valueForKey:USER_ID]]];
        [params removeObjectForKey:USER_ID];
    }
    
    for(id key in params) {
        NSString *value = [CARUtils castToNSString:[params valueForKey:key]];
        [FIRAnalytics setUserPropertyString:value forName:[CARUtils castToNSString:key]];
    }
}

/**
 * Method used to create and fire an event to the Firebase Console
 * The mandatory parameters is EVENT_NAME which is a necessity to build the event
 * Without this parameter, the event won't be built.
 * After the creation of the event object, some attributes can be added,
 * using the dictionary obtained from the gtm container.
 *
 * For the format to apply to the name and the parameters, check http://tinyurl.com/j7ppm6b
 *
 * @param map   the parameters given at the moment of the dataLayer.push(),
 *              passed through the GTM container and the execute method.
 *              * EVENT_NAME : the only parameter requested here
 */
-(void) tagEvent:(NSDictionary*) parameters{
    if ([parameters objectForKey:EVENT_NAME]) {
        NSMutableDictionary* params = [parameters mutableCopy];
        NSString* eventName = [CARUtils castToNSString:[params valueForKey:EVENT_NAME]];
        [params removeObjectForKey:EVENT_NAME];

        if (params.count == 0) {
            [FIRAnalytics logEventWithName:eventName parameters:nil];
            return ;
        }
        [FIRAnalytics logEventWithName:eventName parameters:params];
    }
    else
        NSLog(@"Cargo FirebaseHandler: in order to create an event, an eventName is required. The event hasn't been created.");
}

@end

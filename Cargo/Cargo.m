//
//  FIFTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "Cargo.h"


@implementation Cargo
@synthesize logger;

/* *********************************** Variables Declaration ************************************ */

/** A variable that hold the Cargo instance, which allow to use it as a singleton */
static Cargo * _sharedHelper;

/** A dictionary which registers a handler for a specific tag function call */
static NSMutableDictionary *registeredHandlers;


/* *************************************** Initializer ****************************************** */

#pragma mark - SharedInstance
/**
 Class method which allow the user to retrieve the cargo instance
 On its first call, creates and returns a fresh cargo instance
 On other calls, returns the instance stocked in _sharedHelper variable

 @return returns the cargo instance
 */
+ (Cargo *) sharedHelper {

    // If sharedHelper is already defined, returns it
    if (_sharedHelper) {
        return _sharedHelper;
    }
    // Otherwise, initialize sharedHelper with a new Cargo instance and returns it
    _sharedHelper = [[Cargo alloc] init];
    return _sharedHelper;
}

/**
 The cargo constructor. Initialize a cargo object and set up its logger.

 @return the cargo instance just created
 */
-(id)init {
    if (self = [super init]) {
        logger = [[FIFLogger alloc] initLogger:@"Cargo"];
        self.launchOptionsFlag = false;
    }
    return self;
}


/* *********************************** Methods declaration ************************************** */

#pragma mark - GTM
/**
 Setup the tagManager and the GTM container as properties of Cargo
 Setup the log level of the Cargo logger from the level of the tagManager logger
 This method has to be called right after retrieving the container and the Cargo instance 
 for the first time, and before any other Cargo method.

 @param tagManager The tag manager instance
 @param container The GTM container instance
 */
- (void)initTagHandlerWithLogLevel:(LogLevel)logLevel {

    //Logger level setting
    [self.logger setLevel:logLevel];
}

- (void)registerHandler:(CARTagHandler*)handler forKey:(NSString*)key {
    if (!registeredHandlers) {
        registeredHandlers = [[NSMutableDictionary alloc] init];
    }

    [registeredHandlers setObject:handler forKey:key];
}

- (void)executeMethod:(NSString*)handlerMethod forHandlerKey:(NSString*)handlerKey withParameters:(NSDictionary*)params{
    CARTagHandler* handler = [registeredHandlers valueForKey:handlerKey];
    if (!handler) {
        [self.logger logNotFoundValue:@"handler name" forKey:handlerKey inValueSet:[registeredHandlers allKeys]];
    }
    else {
        [handler execute:handlerMethod parameters:params];
    }
}

/**
 Called in order to set the launchOptions dictionary in AppDelegate. LaunchOptions is used in some
 third part tracking SDK.

 @param l the launchOptions dictonary retrieved in AppDelegate.
 */
-(void) setLaunchOptions:(NSDictionary *)l{
    _launchOptions = l;
    _launchOptionsFlag = true;
}

/**
 Returns whether the LaunchOptions dictionary has been set in Cargo, depending on the flag

 @return true or false according the options flag is set or not
 */
-(BOOL) isLaunchOptionsSet{
    return self.launchOptionsFlag;
}

@end

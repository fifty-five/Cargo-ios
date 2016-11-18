//
//  FIFTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "Cargo.h"
#import "CARTagHandler.h"
#import "CARMacroHandler.h"

//GTM
#import "TAGManager.h"
#import "TAGDataLayer.h"


@implementation Cargo
@synthesize logger;

/* *********************************** Variables Declaration ************************************ */

/** A variable that hold the Cargo instance, which allow to use it as a singleton */
static Cargo * _sharedHelper;

/** A dictionary which registers a handler for a specific tag function call */
static NSMutableDictionary * registeredTagHandlers;
/** A dictionary which registers a handler for a specific macro call */
static NSMutableDictionary * registeredMacroHandlers;


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
- (void)initTagHandlerWithManager:(TAGManager *)tagManager
                        container:(TAGContainer *)container {
    //GTM
    self.tagManager = tagManager;
    self.container = container;

    //Logger level setting
    [self.logger setLevel:[self.tagManager.logger logLevel]];
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

/**
 Class method called by the handler in its load method to register their GTM functions callbacks
 in the registeredTagHandlers dictionary, which is initialized if it wasn't already
 A specific function key is linked to a specific handler.

 @param handler the instance of the handler
 @param key the name of the function which will be used in GTM interface
 */
+ (void) registerTagHandler:(CARTagHandler*)handler withKey:(NSString*) key {
    if(registeredTagHandlers == NULL){
        registeredTagHandlers = [[NSMutableDictionary alloc] init];
    }

    [registeredTagHandlers setValue:handler forKey:key];
}

/**
 Class method called by the handler in its load method to register their GTM macros
 in the registeredMacroHandlers dictionary, which is initialized if it wasn't already
 A specific macro key is linked to a specific handler.

 @param handler the instance of the handler
 @param macro the name of the macro which will be used in GTM interface
 */+ (void) registerMacroHandler:(CARMacroHandler*)handler forMacro:(NSString*) macro {
     if(registeredMacroHandlers == NULL){
         registeredMacroHandlers = [[NSMutableDictionary alloc] init];
     }

     [registeredMacroHandlers setValue:handler forKey:macro];
 }

/**
 For each key stored in the registeredTagHandlers Dictionary, calls on the key,
 check if the handler was correctly initialized, then registers its GTM callback methods
 to the container for this particular handler.
 Does the same with the GTM callback macros
 */
-(void) registerHandlers{
    // functions
    for (NSString* key in registeredTagHandlers) {
        CARTagHandler *handler = registeredTagHandlers[key];
        [handler validate];

        if(handler.valid){
            [self.container registerFunctionCallTagHandler:handler forTag:key];
        }
        NSLog(@"Handler with key %@ has been registered", key );
    }
    // macros
    for(NSString* key in registeredMacroHandlers ){
        CARMacroHandler *macroHandler = registeredMacroHandlers[key];
        [self.container registerFunctionCallMacroHandler:macroHandler forMacro:key];
        NSLog(@"Macro %@ has been registered", key);
    }
}

@end

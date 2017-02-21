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

bool tagFiredSinceLastChange = false;


/* *************************************** Initializer ****************************************** */

#pragma mark - SharedInstance
/**
 Class met(nonatomic) hod which allow the user to retrieve the cargo instance
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

/**
 Method called by the handlers on their load method, stores the handler which called this 
 method in a NSDictionary with the handler key parameter as the key.
 
 @param handler the reference of the handler to store
 */
- (void)registerHandler:(CARTagHandler*)handler {
    if (!registeredHandlers) {
        registeredHandlers = [[NSMutableDictionary alloc] init];
    }

    [registeredHandlers setObject:handler forKey:handler.key];
}

/**
 Changes the level of logs for Cargo and all its handlers
 
 @param logLevel the log level to set Cargo and its handlers with.
 */
- (void)setLogLevel:(LogLevel)logLevel {
    [self.logger setLevel:logLevel];

    // calls on all the registered handlers 'seLogLevel' method
    for (NSString *key in registeredHandlers) {
        CARTagHandler *handler = [registeredHandlers valueForKey:key];
        [handler setLogLevel];
    }
}

/**
 Called from the Tags class which is made to handle callbacks from GTM.
 Calls on this method allow the correct function tag to be redirected to the correct handler.
 
 @param handlerMethod name of the method aimed by the callback, originally a parameter in the NSDict.
 @param handlerKey the key of the handler aimed by the callback, created from the handlerMethod, eg. 'FB_init'
 @param params a NSDictionary of the parameters sent to the method.
 */
- (void)executeMethod:(NSString*)handlerMethod forHandlerKey:(NSString*)handlerKey withParameters:(NSDictionary*)params{
    CARTagHandler* handler = [registeredHandlers valueForKey:handlerKey];
    if (!handler) {
        [self.logger logNotFoundValue:@"handler name" forKey:handlerKey inValueSet:[registeredHandlers allKeys]];
    }
    else {
        [handler execute:handlerMethod parameters:params];
    }
}


/* ************************************* ItemArray methods ************************************** */

/**
 Add an item to the array of items which will be linked with to the next items relative event.
 The array of item is a property of Cargo and has a nil value at the beginning or when an 
 item-relative event has been sent, but the alloc and init are handled in this method.
 A nil object given as parameter will be ignored.
 
 @param item The CargoItem object to add to the list which will be sent with the item-relative event.
 */
- (void)attachItemToEvent:(CargoItem *)item {
    if (item == nil) {
        return ;
    }
    [self emptyListIfTagHasBeenFired];
    if (self.itemsArray == nil) {
        self.itemsArray = [[NSMutableArray alloc] init];
    }
    [self.itemsArray addObject:item];
}

/**
 A getter for the NSMutableArray of items which will be sent to the next "item relative" event.
 May be used to modify some objects before setting a new Array with the 'setItemsArray' method.
 
 @return an NSMutableArray of CargoItem objects.
 */
- (NSMutableArray *)getItemsArray {
    return self.itemsArray;
}

/**
 Sets the array of items which will be sent to the next "item relative" event with a new value.
 
 @param newItemsArray A new array of CargoItem objects, which value can be null.
 */
- (void)setNewItemsArray:(NSMutableArray *)newItemsArray {
    [self emptyListIfTagHasBeenFired];
    if ([newItemsArray count]) {
        self.itemsArray = newItemsArray;
    }
    else {
        self.itemsArray = nil;
    }
}

-(void)emptyListIfTagHasBeenFired {
    if (tagFiredSinceLastChange) {
        tagFiredSinceLastChange = false;
        self.itemsArray = nil;
    }
}

- (void)notifyTagFired {
    tagFiredSinceLastChange = true;
}


/* *************************************** Other methods **************************************** */

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

//
//  FIFTagHandler.h
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FIFLogger.h"
#import "CARTagHandler.h"
#import "CargoItem.h"


/**
 *  A class that provides a template to manage and schedule different function
 *  calls from different mobile tracking frameworks using GTM.
 */
@interface Cargo : NSObject

/** Default logger */
@property (nonatomic, strong) FIFLogger *logger;

/** App launchOptions */
@property (nonatomic, strong) NSDictionary *launchOptions;

/** Flag to know is launchOptions has been set */
@property (nonatomic, assign) BOOL launchOptionsFlag;

@property NSMutableArray *itemsArray;


-(BOOL) isLaunchOptionsSet;


/**
 *  Use sharedHandler to get a shared instance of FIFTagHandler.
 *
 *  @return a shared instance of type FIFTagHandler *
 */
+ (Cargo *) sharedHelper;

/**
 Method called by the handlers on their load method, stores the handler which called this method
 in a NSDictionary with the handler key parameter as the key.
 
 @param handler the reference of the handler to store
 */
- (void)registerHandler:(CARTagHandler*)handler;

- (void)setLogLevel:(LogLevel)logLevel;

/**
 Called from the Tags class which is made to handle callbacks from GTM.
 Calls on this method allow the correct function tag to be redirected to the correct handler.
 
 @param handlerMethod name of the method aimed by the callback, originally a parameter in the NSDict.
 @param handlerKey the key of the handler aimed by the callback, created from the handlerMethod, eg. 'FB_init'
 @param params a NSDictionary of the parameters sent to the method.
 */
- (void)executeMethod:(NSString*)handlerMethod forHandlerKey:(NSString*)handler withParameters:(NSDictionary*)params;

/**
 Add an item to the array of items which will be linked with to the next items relative event.
 The array of item is a property of Cargo and has a nil value at the beginning or when an
 item-relative event has been sent, but the alloc and init are handled in this method.
 A nil object given as parameter will be ignored.
 
 @param item The CargoItem object to add to the list which will be sent with the item-relative event.
 */
- (void)attachItemToEvent:(CargoItem *)item;

/**
 Returns the itemsArray.
 */
- (NSMutableArray *)itemsArray;

/**
 Sets the array of items which will be sent to the next "item relative" event with a new value.
 
 @param newItemsArray A new array of CargoItem objects, which value can be null.
 */
- (void)setNewItemsArray:(NSMutableArray *)newItemsArray;

/**
 A method called whenever a tag is received in the Tags class.
 */
- (void)notifyTagFired;

@end

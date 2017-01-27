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

@end

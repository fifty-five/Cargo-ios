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


#pragma mark - GoogleTagManager
/**
 *  Use initTagHandlerWithManager:container: to configure and initilize
 *  FIFTagHandler with Google Tag Manager.
 *
 *  @param tagManager A google tag manager instance.
 *  @param container  The tag container.
 */
- (void)initTagHandlerWithLogLevel:(LogLevel)logLevel;

- (void)registerHandler:(CARTagHandler*)handler forKey:(NSString*)key;

- (void)executeMethod:(NSString*)handlerMethod forHandlerKey:(NSString*)handler withParameters:(NSDictionary*)params;

@end

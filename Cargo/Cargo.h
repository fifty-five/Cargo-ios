//
//  FIFTagHandler.h
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "FIFLogger.h"

#import "TAGContainer.h"

#import "Handlers.h"


@class TAGManager;
@class TAGContainer;


/**
 *  A class that provides a template to manage and schedule different function
 *  calls from different mobile tracking frameworks using GTM.
 */
@interface Cargo : NSObject

/** Default logger */
@property (nonatomic, strong) FIFLogger *logger;

/** GTM tag manager */
@property (nonatomic, strong) TAGManager *tagManager;

/** GTM container */
@property (nonatomic, strong) TAGContainer *container;

/** App launchOptions */
@property (nonatomic, strong) NSDictionary *launchOptions;

/** Flag to know is launchOptions has been set */
@property (nonatomic, assign) BOOL launchOptionsFlag;


+ (void) registerTagHandler:(id<TAGFunctionCallTagHandler>)handler withKey:(NSString*) key;
+ (void) registerMacroHandler:(id<TAGFunctionCallMacroHandler>)handler forMacro:(NSString*) macro;


-(void) registerHandlers;


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
- (void)initTagHandlerWithManager:(TAGManager *)tagManager
                        container:(TAGContainer *)container;


@end

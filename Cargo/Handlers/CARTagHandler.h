//
//  FIFGenericFunctionCallTagHandler.h
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAGContainer.h"
#import "Cargo.h"
#import "TAGLogger.h"
#import "CARUtils.h"

/**
 *  This class registers and handle all GTM event calls. This class decides which framework 
    handles the call received from GTM and routes it. 
    It also defines basic attributes shared between handlers.
 */
@class FIFLogger;
@interface CARTagHandler : NSObject <TAGFunctionCallTagHandler>

/** Context logger */
@property (nonatomic, retain) FIFLogger *logger;

/** Unique key for this handler */
@property (nonatomic, retain) NSString *key;
/** Name of the handler */
@property (nonatomic, retain) NSString *name;
/** Defines whether the handler has been instanciated */
@property(assign, readwrite) BOOL valid;
/** Defines whether the SDK has been initialized */
@property(assign, readwrite) BOOL initialized;


/**
 Method called in the Cargo class to mark the handler as initialized.
 */
- (void)validate;



@end

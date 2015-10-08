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
 *  This class registers and handle all GTM event calls. This classe decides which framework to handle the call received from GTM and routes it.
 */
@class FIFLogger;
@interface CARTagHandler : NSObject <TAGFunctionCallTagHandler>



/** Context logger */
@property (nonatomic, retain) FIFLogger *logger;


@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property(assign, readwrite) BOOL initialized;
@property(assign, readwrite) BOOL valid;



- (void)validate;



@end

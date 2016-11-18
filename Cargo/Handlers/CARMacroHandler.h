//
//  FIFGenericFunctionCallMacroHandler.h
//  Cargo
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAGContainer.h"


@interface CARMacroHandler : NSObject <TAGFunctionCallMacroHandler>

/** Unique key for this handler */
@property (nonatomic, retain) NSString *key;
/** Name of the handler */
@property (nonatomic, retain) NSString *name;
/** Defines whether the handler has been instanciated */
@property(assign, readwrite) BOOL valid;
/** Defines whether the SDK has been initialized */
@property(assign, readwrite) BOOL initialized;

- (id)valueForMacro:(NSString *)functionName parameters:(NSDictionary *)parameters;


@end

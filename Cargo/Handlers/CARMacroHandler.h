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

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property(assign, readwrite) BOOL initialized;
@property(assign, readwrite) BOOL valid;

- (id)valueForMacro:(NSString *)functionName parameters:(NSDictionary *)parameters;


@end

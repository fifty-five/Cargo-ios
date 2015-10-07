//
//  FIFGenericFunctionCallMacroHandler.m
//  Cargo
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARMacroHandler.h"

@implementation CARMacroHandler

@synthesize key;
@synthesize name;
@synthesize initialized;
@synthesize valid;


#pragma mark - GTMFunctionMacroCallBack
- (id)valueForMacro:(NSString *)functionName parameters:(NSDictionary *)parameters {

    return nil;
}


@end

//
//  Tags.m
//  Cargo
//
//  Created by Julien Gil on 25/01/2017.
//  Copyright © 2017 55 SAS. All rights reserved.
//

#import "Tags.h"
#import "Cargo.h"
#import "CARUtils.h"

@implementation Tags

NSString* HANDLER_METHOD = @"handlerMethod";

- (NSObject*)executeWithParameters:(NSDictionary*)parameters {
    NSMutableDictionary* params = [parameters mutableCopy];

    NSString* handlerMethod = [CARUtils castToNSString:[params valueForKey:HANDLER_METHOD]];
    NSString* handler = [[handlerMethod componentsSeparatedByString:@"_"] objectAtIndex:0];
    [params removeObjectForKey:HANDLER_METHOD];
    [[Cargo sharedHelper] executeMethod:handlerMethod forHandlerKey:handler withParameters:params];
    return nil;
}

@end

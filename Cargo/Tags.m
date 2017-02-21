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

/**
 Method which is called by GTM when a tag calling a custom function is triggered.
 Looks for the 'handlerMethod' parameter and calls on Cargo method with 
 the name of the handler to call on, its method, and the parameters associated to the event.
 
 @param parameters The parameters which should contain the 'handlerMethod' key.
 @return nil
 */
- (NSObject*)executeWithParameters:(NSDictionary*)parameters {
    NSMutableDictionary* params = [parameters mutableCopy];

    NSString* handlerMethod = [CARUtils castToNSString:[params valueForKey:HANDLER_METHOD]];
    NSString* handler = [[handlerMethod componentsSeparatedByString:@"_"] objectAtIndex:0];
    [params removeObjectForKey:HANDLER_METHOD];
    [[Cargo sharedHelper] executeMethod:handlerMethod forHandlerKey:handler withParameters:params];
    [[Cargo sharedHelper] notifyTagFired];
    return nil;
}

@end

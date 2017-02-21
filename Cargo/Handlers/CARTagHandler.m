//
//  FIFGenericFunctionCallTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARTagHandler.h"
#import "Cargo.h"


@implementation CARTagHandler

@synthesize key;
@synthesize name;
@synthesize initialized;
@synthesize valid;


@synthesize logger;


#pragma mark - GTMFunctionCallBack

/**
 Called when a child "execute" method is called. Logs the method call and its parameters

 @param functionName the tag name of the callback method
 @param parameters the parameters sent to the method through a dictionary
 */
- (void)execute:(NSString *)functionName parameters:(NSDictionary *)parameters {
    [self.logger logReceivedFunction:functionName withParam:parameters];
}

/**
 Method called in the Cargo class to mark the handler as initialized.
 */
- (void)validate{
    self.valid = true;
}

/**
 Sets the handler's name and key, initialize the logger instance, 
 sets the loglevel of this one at the same level as cargo's, stores the handler into a dict in Cargo
 
 @param handlerKey a short string describing the handler, and which will be used to call it
 @param handlerName the name of the tool the handlers stands for.
 */
- (id)initWithKey:(NSString *)handlerKey andName:(NSString *)handlerName{
    self.key = handlerKey;
    self.name = handlerName;
    [[Cargo sharedHelper] registerHandler:self];
    self.logger = [[FIFLogger alloc] initLogger:[self.key stringByAppendingString:@"_handler"]];
    self.valid = NO;
    self.initialized = NO;

    return self;
}

- (void)setLogLevel {
    [self.logger  setLevel:[[[Cargo sharedHelper] logger] level]];
}


@end

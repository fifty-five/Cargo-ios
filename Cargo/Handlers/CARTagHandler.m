//
//  FIFGenericFunctionCallTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARTagHandler.h"
#import "FIFLogger.h"
#import "CARUtils.h"


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
    FIFLog(kTAGLoggerLogLevelInfo, @"Function '%@' has been received with parameters '%@'",
           functionName,
           parameters);
    
}

/**
 Method called in the Cargo class to mark the handler as initialized.
 */
- (void)validate{
    self.valid = true;
}


@end

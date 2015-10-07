//
//  FIFGenericFunctionCallTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARTagHandler.h"
#import "FIFLogger.h"
#import "Cargo.h"
#import "CARUtils.h"


@implementation CARTagHandler

@synthesize key;
@synthesize name;
@synthesize initialized;
@synthesize valid;


@synthesize logger;






#pragma mark - GTMFunctionCallBack
- (void)execute:(NSString *)functionName parameters:(NSDictionary *)parameters {
    FIFLog(kTAGLoggerLogLevelInfo, @"Function '%@' has been received with parameters '%@'",
           functionName,
           parameters);
    
}

- (void)validate{
    self.valid = true;
}


@end

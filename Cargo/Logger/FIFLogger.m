//
//  FIFLogger.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "FIFLogger.h"
#import <UIKit/UIKit.h>

@interface FIFLogger ()
- (BOOL)levelEnabled:(TAGLoggerLogLevelType)intentLevel;
- (NSString *)nameOfLevel:(TAGLoggerLogLevelType)loggingLevel;

@end

#pragma mark - Main logging function
FIFLogger * refToSelf;
void FIFLog(TAGLoggerLogLevelType intentLevel,
            NSString *messageFormat, ...) {
    
    if (!refToSelf)
        refToSelf = [[FIFLogger alloc] init];
        
    if ([refToSelf levelEnabled:intentLevel]) {
        va_list args;
        va_start(args, messageFormat);
        
        NSString *logMessage = [[NSString alloc]
                                 initWithFormat:messageFormat
                                 arguments:args];
        NSLog(@"[%@] - %@ - %@",
              refToSelf.context,
              [refToSelf nameOfLevel:intentLevel],
              logMessage);
        va_end(args);
    }
}


@implementation FIFLogger
@synthesize format;
@synthesize level;
@synthesize context;


- (id)initLogger:(NSString *)aContext {
    if (self = [super init]) {
        self.context = aContext;
        [self setLevel:kTAGLoggerLogLevelVerbose];
        [self setFormat:@"[%@] - %@ - %@"];
        refToSelf = self;
    }
    
    return self;
}


#pragma mark - Setters
- (void)setLevel:(TAGLoggerLogLevelType)logLevel {
    level = logLevel;
    if (level == kTAGLoggerLogLevelVerbose &&
        [context isEqualToString:@"Cargo"]) {
        FIFLog(kTAGLoggerLogLevelWarning,
              @"Cargo Verbose Mode Enabled."
              " Use only when debugging. Do not release with this enabled");
    }
}


- (void)setFormat:(NSString *)logFormat {
    format = [[NSString alloc] initWithString:logFormat];
}



#pragma mark - Logging
- (void)logMissingParam:(NSString *)paramName
               inMethod:(NSString *)methodName {
    
    FIFLog(kTAGLoggerLogLevelWarning, @"[%@] Parameter '%@' is required in method '%@'",
           context,
           paramName,
           methodName);
}


- (void)logUncastableParam:(NSString *)paramName
                    toType:(NSString *)type {
    FIFLog(kTAGLoggerLogLevelWarning, @"param %@ cannot be casted to %@ ", paramName, type);
}


- (void)logUninitializedFramework {
    FIFLog(kTAGLoggerLogLevelWarning, @"[%@] You must init framework before using it",
           context);
}


- (void)logParamSetWithSuccess:(NSString *)paramName
                     withValue:(id)value {
    FIFLog(kTAGLoggerLogLevelInfo, @"[%@] Parameter '%@' has been set to '%@' with success",
           context,
           paramName,
           value);
}


- (void)logUnknownParam:(NSString *)paramName {
    FIFLog(kTAGLoggerLogLevelWarning, @"[%@] Parameter '%@' is unknown",
           context,
           paramName);
}


- (void)logNotFoundValue:(NSString *)value
                  forKey:(NSString *)key
              inValueSet:(NSArray *)possibleValues {
    FIFLog(kTAGLoggerLogLevelWarning, @"[%@] Value '%@' for key '%@' is not "
           "found among possible values %@",
           context,
           value,
           key,
           possibleValues);
}



#pragma mark - Utils
- (BOOL)levelEnabled:(TAGLoggerLogLevelType)intentLevel {
    return ((level != kTAGLoggerLogLevelNone) && (intentLevel >= level));
}


- (NSString *)nameOfLevel:(TAGLoggerLogLevelType)loggingLevel {
    NSString *result = @"UNKN";
    switch (loggingLevel) {
        case kTAGLoggerLogLevelVerbose:
            result = @"VERB";
            break;
        case kTAGLoggerLogLevelDebug:
            result = @"DEBU";
            break;
        case kTAGLoggerLogLevelInfo:
            result = @"INFO";
            break;
        case kTAGLoggerLogLevelWarning:
            result = @"WARN";
            break;
        case kTAGLoggerLogLevelError:
            result = @"ERRO";
            break;
        case kTAGLoggerLogLevelNone:
            result = @"NONE";
            break;
    }
    return result;
}
@end

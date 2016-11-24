//
//  FIFLogger.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "FIFLogger.h"
#import <UIKit/UIKit.h>

/**
 *  A class that provides a logger for the FIFTagHandler framework
 */
@interface FIFLogger ()
- (BOOL)levelEnabled:(TAGLoggerLogLevelType)intentLevel;
- (NSString *)nameOfLevel:(TAGLoggerLogLevelType)loggingLevel;

@end

@implementation FIFLogger
@synthesize level;
@synthesize superContext;
@synthesize context;

/**
 *  Initialize the logger with a context
 *
 *  @param aContext The Context
 *
 *  @return The created logger
 */
- (id)initLogger:(NSString *)aContext {
    if (self = [super init]) {
        self.superContext = @"Cargo";
        self.context = aContext;
        [self setLevel:kTAGLoggerLogLevelVerbose];
    }
    return self;
}

- (void)FIFLog:(TAGLoggerLogLevelType)intentLevel withMessage:(NSString *)messageFormat, ... {

    if ([self levelEnabled:intentLevel]) {
        va_list args;
        va_start(args, messageFormat);

        NSString *logMessage = [[NSString alloc]
                                initWithFormat:messageFormat
                                arguments:args];
        NSLog(@"%@ - %@ [%@]: %@",
              self.superContext,
              self.context,
              [self nameOfLevel:intentLevel],
              logMessage);
        va_end(args);
    }
}

#pragma mark - Setters
/**
 *  Set the logging level
 *
 *  @param logLevel the logging level
 */
- (void)setLevel:(TAGLoggerLogLevelType)logLevel {
    level = logLevel;
    if (level == kTAGLoggerLogLevelVerbose && [self.context  isEqual: @"Cargo"]) {
        [self FIFLog:kTAGLoggerLogLevelWarning withMessage:
         @"Verbose Mode Enabled. Do not release with this enabled"];
    }
}


#pragma mark - Logging
/**
 *  This method logs a warning about
 *  a missing required parameter.
 *
 *  @param paramName  The missing param name
 *  @param methodName The method name
 */
- (void)logMissingParam:(NSString *)paramName
               inMethod:(NSString *)methodName {

    [self FIFLog:kTAGLoggerLogLevelWarning withMessage:
     @"Parameter '%@' is required in method '%@'",
     paramName,
     methodName];
}

/**
 *  This method logs a warning about an
 *  uncastable param.
 *
 *  @param paramName The uncastable param name
 *  @param type      The type
 */
- (void)logUncastableParam:(NSString *)paramName
                    toType:(NSString *)type {
    [self FIFLog:kTAGLoggerLogLevelWarning withMessage:
     @"param %@ cannot be casted to %@ ",
     paramName,
     type];
}

/**
 *  This method logs a warning about
 *  a missing initialization of the framework
 *
 *  @param handlerName the name of the uninitialized handler
 */
- (void)logUninitializedFramework:(NSString *)handlerName {
    [self FIFLog:kTAGLoggerLogLevelWarning withMessage:
     @"You must init framework %@ before using it",
     handlerName];
}

/**
 *  This method logs a setter success
 *
 *  @param paramName The set param
 *  @param value     The set value
 */
- (void)logParamSetWithSuccess:(NSString *)paramName
                     withValue:(id)value {
    [self FIFLog:kTAGLoggerLogLevelInfo withMessage:
     @"Parameter '%@' has been set to '%@' with success",
     paramName,
     value];
}

/**
 *  This method logs a warning about an
 *  unknown param.
 *
 *  @param paramName The unknown param
 */
- (void)logUnknownParam:(NSString *)paramName {
    [self FIFLog:kTAGLoggerLogLevelWarning withMessage:@"Parameter '%@' is unknown", paramName];
}

/**
 *  This method logs a warning about a
 *  missing value from a predifined value set
 *
 *  @param value          The value
 *  @param possibleValues The value set
 */
- (void)logNotFoundValue:(NSString *)value
                  forKey:(NSString *)key
              inValueSet:(NSArray *)possibleValues {
    [self FIFLog:kTAGLoggerLogLevelWarning withMessage:
     @"Value '%@' for key '%@' is not found among possible values %@",
     value,
     key,
     possibleValues];
}

/**
 Defines if a message has to be logged by comparing its log level to the log level the logger
 is using.

 @param BOOL The level of the message which want to be logged
 @return A boolean value telling whether the message can (true) or cannot (false) be logged.
 */
#pragma mark - Utils
- (BOOL)levelEnabled:(TAGLoggerLogLevelType)intentLevel {
    return ((level != kTAGLoggerLogLevelNone) && (intentLevel >= level));
}

/**
 Returns a string associated to the level of the log.

 @param loggingLevel the log level
 @return the String defining the log level
 */
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

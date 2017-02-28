//
//  FIFUtils.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARUtils.h"
#import "FIFLogger.h"

/**
 *  This class is a set of method used to check
 *  data types and manage castings
 */
@implementation CARUtils


#pragma mark - Casting methods

/* *************************************** Number types ***************************************** */

/**
 *  This class method checks if a passed object
 *  is an instance of NSNumber
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSNumber *)castToNSNumber:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSNumber class]])
        return (NSNumber *) value;
    
    
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * number = [formatter numberFromString:value];
        return number;
    }
    
    return nil;
}

/**
 *  This class method calls on castToNSNumber
 *  and cast the result as an int.
 *
 *  @param value The value to check
 *
 *  @return the casted value, -1 if the given value is nil
 */
+ (int)castToNSInteger:(id)value withDefault:(int)defaultValue {
    NSNumber* temp = [CARUtils castToNSNumber:value];
    
    if (!temp)
        return defaultValue;
    else
        return [temp intValue];
    
    return defaultValue;
}

/**
 *  This class method calls on castToNSNumber
 *  and cast the result as a float.
 *
 *  @param value The value to check
 *
 *  @return the casted value, -1 if the given value is nil
 */
+ (int)castToFloat:(id)value withDefault:(float)defaultValue {
    NSNumber* temp = [CARUtils castToNSNumber:value];
    
    if (!temp)
        return defaultValue;
    else
        return [temp floatValue];
    
    return defaultValue;
}


/* *************************************** Storage types **************************************** */

/**
 *  This class method checks if a passed object
 *  is an instance of NSArray
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSArray *)castToNSArray:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSArray class]])
        return (NSArray *) value;
    
    return nil;
}

/**
 *  This class method checks if a passed object
 *  is an instance of NSDictionary
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSDictionary *)castToNSDictionary:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSDictionary class]])
        return (NSDictionary *)value;
    
    return nil;
}

/**
 *  This class method checks if a passed object
 *  is an instance of NSData
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSData *)castToNSData:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSData class]])
        return (NSData *)value;
    
    if ([value isKindOfClass:[NSString class]])
        return [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
    
    return nil;
}


/* ************************************ String & Date types ************************************* */

/**
 *  This class method checks if a passed object
 *  is an instance of NSString
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSString *)castToNSString:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    
    return nil;
}

/**
 *  This class method checks if a passed object
 *  is an instance of NSDate
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSDate *)castToNSDate:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;

    if ([value isKindOfClass:[NSDate class]]) {
        return (NSDate *)value;
    }

    if ([value isKindOfClass:[NSString class]])
        return [NSDate dateWithTimeIntervalSince1970: [value doubleValue]];
    
    return nil;
}


/* ***************************************** Utility ******************************************** */

/**
 *  This class method checks if advertising
 *  tracking is enabled for this app.
 *
 *  @return YES if the advertising tracking
 *  is enabled, NO otherwise.
 */
+ (BOOL)isAdvertisingTrackingEnabled {
#if __has_include(<AdSupport/AdSupport.h>)
    Class klass = NSClassFromString(@"ASIdentifierManager");
    if (klass) {
        // Adsupport exists
        id object = [[klass alloc] init];
        
        SEL sharedSelector = NSSelectorFromString(@"sharedManager");
        IMP sharedImp = [[object class] methodForSelector:sharedSelector];
        id (*shareFunc)(id, SEL) = (void *)sharedImp;
        id sharedManager = shareFunc([object class], sharedSelector);
        
        SEL adEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        IMP adEnabledImp = [sharedManager methodForSelector:adEnabledSelector];
        BOOL (*adEnabledFunc)(id, SEL) = (void *)adEnabledImp;
        BOOL adEnabled = adEnabledFunc(sharedManager, adEnabledSelector);
        
        return adEnabled;
    }
#endif
    
    return NO;
}

/**
 *  This class method returns the advertising
 *  identifier if possible.
 *
 *  @return the advertising id or nil.
 */
+ (NSUUID *)advertisingIdentifier {
#if __has_include(<AdSupport/AdSupport.h>)
    Class klass = NSClassFromString(@"ASIdentifierManager");
    if (klass) {
        // Adsupport exists
        id object = [[klass alloc] init];
        
        SEL sharedSelector = NSSelectorFromString(@"sharedManager");
        IMP sharedImp = [[object class] methodForSelector:sharedSelector];
        id (*shareFunc)(id, SEL) = (void *)sharedImp;
        id sharedManager = shareFunc([object class], sharedSelector);
        
        SEL idfaSelector = NSSelectorFromString(@"advertisingIdentifier");
        IMP idfaImp = [sharedManager methodForSelector:idfaSelector];
        id (*idfaFunc)(id, SEL) = (void *)idfaImp;
        NSUUID* idfa = (NSUUID *)idfaFunc(sharedManager, idfaSelector);
        
        return idfa;
    }
#endif
    
    
    return nil;
}

@end

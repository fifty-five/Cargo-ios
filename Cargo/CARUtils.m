//
//  FIFUtils.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARUtils.h"
#import "FIFLogger.h"

@implementation CARUtils


#pragma mark - Casting methods
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


+ (int)castToNSInteger:(id)value withDefault:(int)defaultValue {
    NSNumber* temp = [CARUtils castToNSNumber:value];
    
    if (!temp)
        return defaultValue;
    else
        return [temp intValue];
    
    return defaultValue;
}


+ (int)castToFloat:(id)value withDefault:(float)defaultValue {
    NSNumber* temp = [CARUtils castToNSNumber:value];
    
    if (!temp)
        return defaultValue;
    else
        return [temp floatValue];
    
    return defaultValue;
}


+ (NSArray *)castToNSArray:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSArray class]])
        return (NSArray *) value;
    
    return nil;
}


+ (NSDictionary *)castToNSDictionary:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSDictionary class]])
        return (NSDictionary *)value;
    
    return nil;
}


+ (NSData *)castToNSData:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSData class]])
        return (NSData *)value;
    
    if ([value isKindOfClass:[NSString class]])
        return [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
    
    return nil;
}


+ (NSDate *)castToNSDate:(id)value {
    if ([value isEqual:[NSNull null]] || value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSDate class]])
        return (NSDate *)value;
    
    if ([value isKindOfClass:[NSString class]]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
        return (NSDate *) [df dateFromString: value];
    }
    
    return nil;
}

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
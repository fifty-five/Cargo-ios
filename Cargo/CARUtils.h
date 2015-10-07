//
//  FIFUtils.h
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//


#import <Foundation/Foundation.h>


/**
 *  This class is a set of method used to check 
 *  data types and manage castings
 */
@interface CARUtils : NSObject


/**
 *  This class method checks if a passed object 
 *  is an instance of NSNumber
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSNumber *)castToNSNumber:(id) value;


/**
 *  This class method checks if a passed object 
 *  is an instance of NSString
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSString *)castToNSString:(id) value;


/**
 *  This class method checks if a passed object
 *  is an instance of NSArray
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSArray *)castToNSArray:(id) value;


/**
 *  This class method checks if a passed object
 *  is an instance of NSDictionary
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSDictionary *)castToNSDictionary:(id) value;


/**
 *  This class method checks if a passed object
 *  is an instance of NSData
 *  and cast it if possible.
 *
 *  @param value The value to check
 *
 *  @return nil or the casted value
 */
+ (NSData *)castToNSData:(id)value;


/**
 *  This class method checks if advertising
 *  tracking is enabled for this app.
 *
 *  @return YES if the advertising tracking
 *  is enabled, NO otherwise.
 */
+ (BOOL)isAdvertisingTrackingEnabled;


/**
 *  This class method returns the advertising
 *  identifier if possible.
 *
 *  @return the advertising id or nil.
 */
+ (NSUUID *)advertisingIdentifier;



@end

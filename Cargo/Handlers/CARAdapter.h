//
//  FIFGenericAdapter.h
//  FFNews
//
//  Created by louis chavane on 22/08/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FIFLogger.h"
#import "CARUtils.h"

/**
 *  This class is a representation 
 *  of a generic adapter
 */
@interface CARAdapter : NSObject {
    /** Logger of the generic adapter */
    FIFLogger *logger;
}



/**
 *  Set attributes from a set of parameters
 *
 *  @param parameters The set of parameters
 */
- (void)setAttributesFromParameters:(NSDictionary *)parameters;


/**
 *  This method defines actions when attempting to set
 *  an undifined parameter
 *
 *  @param value The value
 *  @param key   The undefined key
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end

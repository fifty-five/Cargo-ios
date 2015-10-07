//
//  FIFGenericAdapter.m
//  FFNews
//
//  Created by louis chavane on 22/08/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARAdapter.h"
#import "Cargo.h"

@implementation CARAdapter




- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    [logger logUnknownParam:key];
}


- (void)setAttributesFromParameters:(NSDictionary *)parameters{
    [self setValuesForKeysWithDictionary:parameters];
}
@end

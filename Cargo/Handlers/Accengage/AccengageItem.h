//
//  AccengageItem.h
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMA4SSDK.h"

@interface AccengageItem : NSObject

@property NSString* ID;
@property NSString* label;
@property NSString* category;
@property double price;
@property NSInteger quantity;

- (id)initWithId:(NSString*)ID label:(NSString*)label category:(NSString*)category price:(double)price quantity:(NSInteger)quantity;
-(BMA4SPurchasedItem*)toA4SItem;

@end

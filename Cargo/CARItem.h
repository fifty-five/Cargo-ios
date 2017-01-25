//
//  CARItem.h
//  Cargo
//
//  Created by Julien Gil on 24/01/2017.
//  Copyright © 2017 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CARItem : NSObject

@property NSString      *name;
@property float         unitPrice;
@property unsigned int  quantity;
@property float         revenue;
@property NSString      *attribute1;
@property NSString      *attribute2;
@property NSString      *attribute3;
@property NSString      *attribute4;
@property NSString      *attribute5;

- (id)initWithName:(NSString *)itemName andUnitPrice:(float)unitPrice andQuantity:(unsigned int)quantity;

- (id)initWithName:(NSString *)itemName
      andUnitPrice:(float)unitPrice
       andQuantity:(UInt32)quantity
        andRevenue:(float)revenue;

+ (NSString *)toGTM:(NSArray *)items;

@end

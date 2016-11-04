//
//  AccengageItem.m
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "AccengageItem.h"

@implementation AccengageItem

- (id)initWithId:(NSString*)ID label:(NSString*)label category:(NSString*)category price:(double)price quantity:(NSInteger)quantity {
    if (self = [super init]) {
        self.ID = ID;
        self.label = label;
        self.category = category;
        self.price = price;
        self.quantity = quantity;
    }
    return self;
}

-(BMA4SPurchasedItem*)toA4SItem{
    BMA4SPurchasedItem *item = [BMA4SPurchasedItem itemWithId:self.ID
                                                        label:self.label
                                                     category:self.category
                                                        price:self.price
                                                     quantity:self.quantity];
    return item;
}

@end


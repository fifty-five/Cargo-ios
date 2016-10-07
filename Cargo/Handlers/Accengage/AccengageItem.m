//
//  AccengageItem.m
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "AccengageItem.h"

@implementation AccengageItem

- (id)initWithId:(NSString*)ID AndLabel:(NSString*)label AndCategory:(NSString*)category AndPrice:(double)price AndQuantity:(NSInteger)quantity {
    if (self = [super init]) {
        self.ID = ID;
        self.label = label;
        self.category = category;
        self.price = price;
        self.quantity = quantity;
    }
    return self;
}

@end


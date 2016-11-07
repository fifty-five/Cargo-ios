//
//  AccengageItem.m
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "AccengageItem.h"

@implementation AccengageItem

- (id)initWithId:(NSString*)ID name:(NSString*)name brand:(NSString*)brand category:(NSString*)category price:(double)price quantity:(NSInteger)quantity {
    if (self = [super init]) {
        self.ID = ID;
        self.name = name;
        self.brand = brand;
        self.category = category;
        self.price = price;
        self.quantity = quantity;
    }
    return self;
}

-(ACCCartItem*)toA4SItem{
    ACCCartItem *item = [ACCCartItem itemWithId:self.ID
                                           name:self.name
                                          brand:self.brand
                                       category:self.category
                                          price:self.price
                                       quantity:self.quantity];
    return item;
}

@end


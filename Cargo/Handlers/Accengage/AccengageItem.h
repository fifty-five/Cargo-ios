//
//  AccengageItem.h
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accengage/Accengage.h>

/**
 A class which handles item objects transfer from the app to Accengage SDK
 */
@interface AccengageItem : NSObject

/** ID of the item */
@property NSString* ID;
/** Name of the item */
@property NSString* name;
/** Brand of the item */
@property NSString* brand;
/** Category the item belongs to */
@property NSString* category;
/** Price of the item */
@property double price;
/** Quantity of this item */
@property NSInteger quantity;

/**
 The init method for the item object

 @param ID the ID of the item
 @param name the name of the item
 @param brand the brand of the item
 @param category the category the item belongs to
 @param price the price of the item
 @param quantity the quantity of items concerned
 @return an item object
 */
- (id)initWithId:(NSString*)ID name:(NSString*)name brand:(NSString*)brand category:(NSString*)category price:(double)price quantity:(NSInteger)quantity;
- (ACCCartItem*)toA4SItem;

@end

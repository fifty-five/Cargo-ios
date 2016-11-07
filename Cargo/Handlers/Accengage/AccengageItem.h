//
//  AccengageItem.h
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accengage/Accengage.h>

@interface AccengageItem : NSObject

@property NSString* ID;
@property NSString* name;
@property NSString* brand;
@property NSString* category;
@property double price;
@property NSInteger quantity;

- (id)initWithId:(NSString*)ID name:(NSString*)name brand:(NSString*)brand category:(NSString*)category price:(double)price quantity:(NSInteger)quantity;
- (ACCCartItem*)toA4SItem;

@end

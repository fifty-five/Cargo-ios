//
//  CARConstants.h
//  Cargo
//
//  Created by louis chavane on 03/12/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CARConstants : NSObject

#pragma tracker
extern NSString *const ENABLE_DEBUG;
extern NSString *const DISPATCH_PERIOD;
extern NSString *const ENABLE_OPTOUT;
extern NSString *const DISABLE_TRACKING;

#pragma screen
extern NSString *const SCREEN_NAME;

#pragma events
extern NSString *const EVENT_NAME;
extern NSString *const EVENT_VALUE;

#pragma user
extern NSString *const USER_GOOGLE_ID;
extern NSString *const USER_FACEBOOK_ID;
extern NSString *const USER_ID;

#pragma transaction
extern NSString *const TRANSACTION_ID;
extern NSString *const TRANSACTION_TOTAL;
extern NSString *const TRANSACTION_PRODUCTS;
extern NSString *const TRANSACTION_PRODUCT_NAME;
extern NSString *const TRANSACTION_PRODUCT_SKU;
extern NSString *const TRANSACTION_PRODUCT_PRICE;
extern NSString *const TRANSACTION_PRODUCT_CATEGORY;
extern NSString *const TRANSACTION_PRODUCT_QUANTITY;


@end

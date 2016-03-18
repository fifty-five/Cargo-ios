//
//  CARConstants.m
//  Cargo
//
//  Created by louis chavane on 03/12/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARConstants.h"

@implementation CARConstants

#pragma tracker
NSString *const ENABLE_DEBUG = @"enableDebug";
NSString *const ENABLE_OPTOUT = @"enableOptOut";
NSString *const DISABLE_TRACKING = @"disableTracking";
NSString *const DISPATCH_PERIOD = @"dispatchPeriod";


#pragma screen
NSString *const SCREEN_NAME = @"screenName";

#pragma event
NSString *const EVENT_NAME = @"eventName";
NSString *const EVENT_VALUE = @"eventValue";

#pragma user
NSString *const USER_GOOGLE_ID = @"userGoogleId";
NSString *const USER_FACEBOOK_ID = @"userFacebookId";
NSString *const USER_ID = @"userId";

#pragma transaction

NSString *const TRANSACTION_ID = @"transactionId";
NSString *const TRANSACTION_TOTAL = @"transactionTotal";
NSString *const TRANSACTION_PRODUCTS = @"transactionProducts";
NSString *const TRANSACTION_PRODUCT_NAME = @"name";
NSString *const TRANSACTION_PRODUCT_SKU = @"sku";
NSString *const TRANSACTION_PRODUCT_PRICE = @"price";
NSString *const TRANSACTION_PRODUCT_CATEGORY = @"category";
NSString *const TRANSACTION_PRODUCT_QUANTITY = @"quantity";



@end
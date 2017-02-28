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
NSString *const APPLICATION_ID = @"applicationId";
NSString *const ENABLE_DEBUG = @"enableDebug";
NSString *const ENABLE_OPTOUT = @"enableOptOut";
NSString *const DISABLE_TRACKING = @"disableTracking";
NSString *const DISPATCH_INTERVAL = @"dispatchInterval";
NSString *const LEVEL2 = @"level2";
NSString *const CUSTOM_DIM1 = @"customDim1";
NSString *const CUSTOM_DIM2 = @"customDim2";


#pragma screen
NSString *const SCREEN_NAME = @"screenName";

#pragma event
NSString *const EVENT_NAME = @"eventName";
NSString *const EVENT_ID = @"eventId";
NSString *const EVENT_VALUE = @"eventValue";
NSString *const EVENT_TYPE = @"eventType";

#pragma user
NSString *const USER_ID = @"userId";
NSString *const USER_AGE = @"userAge";
NSString *const USER_EMAIL = @"userEmail";
NSString *const USER_NAME = @"userName";
NSString *const USER_GENDER = @"userGender";
NSString *const USER_GOOGLE_ID = @"userGoogleId";
NSString *const USER_TWITTER_ID = @"userTwitterId";
NSString *const USER_FACEBOOK_ID = @"userFacebookId";

#pragma transaction
NSString *const TRANSACTION_ID = @"transactionId";
NSString *const TRANSACTION_TOTAL = @"transactionTotal";
NSString *const TRANSACTION_CURRENCY_CODE = @"transactionCurrencyCode";
NSString *const TRANSACTION_PRODUCTS = @"transactionProducts";
NSString *const TRANSACTION_PRODUCT_NAME = @"name";
NSString *const TRANSACTION_PRODUCT_SKU = @"sku";
NSString *const TRANSACTION_PRODUCT_PRICE = @"price";
NSString *const TRANSACTION_PRODUCT_CATEGORY = @"category";
NSString *const TRANSACTION_PRODUCT_QUANTITY = @"quantity";



@end

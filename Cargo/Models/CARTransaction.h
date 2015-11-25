//
//  CARTransaction.h
//  Cargo
//
//  Created by louis chavane on 06/11/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//


@interface CARTransaction : NSObject

@property (nonatomic, strong) NSString * transactionId;
@property (nonatomic, strong) NSString * transactionTotal;
@property (nonatomic, strong) NSString * transactionAffiliation;
@property (nonatomic, strong) NSString * transactionTax;
@property (nonatomic, strong) NSString * transactionShipping;
@property (nonatomic, strong) NSString * transactionCurrency;
@property (nonatomic, strong) NSMutableArray * transactionProducts;



@end

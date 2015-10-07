//
//  FIFTagHandlerTest.h
//  Cargo
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GoogleTagManager/TAGContainer.h>
#import <GoogleTagManager/TAGManager.h>


@interface FIFTagHandlerTest : XCTest

@property (nonatomic, strong) TAGManager *tagManager;
@property (nonatomic, strong) TAGContainer *container;

@end

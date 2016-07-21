//
//  FirebaseTests.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TAGManager.h"
#import "CARFirebaseTagHandler.h"
#import <Firebase.h>
#import "CARConstants.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface FirebaseTests : XCTestCase

@property CARFirebaseTagHandler* handler;

@end



@implementation FirebaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARFirebaseTagHandler alloc] init];

    
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


@end

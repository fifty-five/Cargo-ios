//
//  AccengageTests.m
//  Cargo
//
//  Created by François K on 18/03/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import <XCTest/XCTest.h>


//FIFTagHandler
#import "Cargo.h"


#import "CARAccengageTagHandler.h"
#import "BMA4SSDK.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>


#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>



@interface AccengageTest : XCTestCase

@property (nonatomic, strong) CARAccengageTagHandler *handler;
@property Class accTrackerMock;


@end


@implementation AccengageTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARAccengageTagHandler alloc] init];
    _accTrackerMock = mockClass([BMA4STracker class]);
    [_handler setTracker:_accTrackerMock];
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) testInitAccengageWithoutParams {
    [_handler execute:@"ACC_init" parameters:nil];
    [verifyCount(_accTrackerMock, never()) trackWithPartnerId:anything() privateKey:anything() options:anything()];
    
    XCTAssertFalse(_handler.initialized);
    
}

-(void) testInitAccengageWithParams {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"12345",@"partnerId", @"6789",@"privateKey", nil];

    [_handler execute:@"ACC_init" parameters:dict];
    [verifyCount(_accTrackerMock, times(1)) trackWithPartnerId:@"12345" privateKey:@"6789" options:anything()];
    
    XCTAssertTrue(_handler.initialized);
    
}

-(void) testTrackEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"call",@"eventName", @"3", @"eventValue", nil];
    
    [_handler execute:@"ACC_tagEvent" parameters:dict];
    [verifyCount(_accTrackerMock, times(1)) trackLeadWithLabel:@"call" value:@"3"];
    
}

@end
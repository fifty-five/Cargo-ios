//
//  GoogleAnalyticsTests.m
//  
//
//  Created by Med on 13/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import <XCTest/XCTest.h>


//FIFTagHandler
#import "Cargo.h"


#import "CARFacebookTagHandler.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>


#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface FacebookTest : XCTestCase

@property (nonatomic, strong) CARFacebookTagHandler *handler;
@property Class fbEventsMock;


@end

@implementation FacebookTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARFacebookTagHandler alloc] init];
    _fbEventsMock = mockClass([FBSDKAppEvents class]);
    [_handler setFbAppEvents:_fbEventsMock];
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) testInitFacebook {
    [_handler execute:@"FB_init" parameters:nil];

    XCTAssertFalse(_handler.initialized);

}

-(void) testInitFacebookWithAppId {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"1234",@"applicationId", nil];
    [_handler execute:@"FB_init" parameters:dict];
    [verifyCount(_fbEventsMock, times(1)) setLoggingOverrideAppID:@"1234"];
    XCTAssertTrue(_handler.initialized);

}

-(void) testSimpleTagEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"testName", EVENT_NAME, nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagEvent" parameters:dict];

    [verifyCount(_fbEventsMock, times(1)) logEvent:@"testName"];
}

-(void) testFailedSimpleTagEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"testName", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagEvent" parameters:dict];

    [verifyCount(_fbEventsMock, never()) logEvent:anything()];
}

-(void) testTagEventWithVTS {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"testName", EVENT_NAME, [NSNumber numberWithDouble:55.42], @"valueToSum", nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagEvent" parameters:dict];

    [verifyCount(_fbEventsMock, times(1)) logEvent:@"testName" valueToSum:55.42];
}

-(void) testTagEventWithVTSAndParams {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:FBSDKAppEventNameAddedToCart, EVENT_NAME, [NSNumber numberWithDouble:55.42], @"valueToSum", @"USD", FBSDKAppEventParameterNameCurrency, @"product", FBSDKAppEventParameterNameContentType, @"HDFU-8452", FBSDKAppEventParameterNameContentID, nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagEvent" parameters:dict];

    [verifyCount(_fbEventsMock, times(1)) logEvent:FBSDKAppEventNameAddedToCart valueToSum:55.42 parameters:@{ FBSDKAppEventParameterNameCurrency    : @"USD",                                                                                                               FBSDKAppEventParameterNameContentType : @"product",                                                                                                               FBSDKAppEventParameterNameContentID   : @"HDFU-8452" }];
}

-(void) testTagEventWithParams {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:FBSDKAppEventNameAddedToCart, EVENT_NAME, @"USD", FBSDKAppEventParameterNameCurrency, @"product", FBSDKAppEventParameterNameContentType, @"HDFU-8452", FBSDKAppEventParameterNameContentID, nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagEvent" parameters:dict];

    [verifyCount(_fbEventsMock, times(1)) logEvent:FBSDKAppEventNameAddedToCart parameters:@{ FBSDKAppEventParameterNameCurrency: @"USD",                                                                                                               FBSDKAppEventParameterNameContentType : @"product",                                                                                                               FBSDKAppEventParameterNameContentID   : @"HDFU-8452" }];
}

-(void) testPurchase {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"USD", TRANSACTION_CURRENCY_CODE, [NSNumber numberWithDouble:15.15], TRANSACTION_TOTAL, nil];

    [_handler setInitialized:true];
    [_handler execute:@"FB_tagPurchase" parameters:dict];

    [verifyCount(_fbEventsMock, times(1)) logPurchase:15.15 currency:@"USD"];
}

@end

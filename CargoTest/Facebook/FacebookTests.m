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
    [verifyCount(_fbEventsMock, times(1)) activateApp];
    
    XCTAssertTrue(_handler.initialized);
    
}

-(void) testInitFacebookWithAppId {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"1234",@"applicationId", nil];
    [_handler execute:@"FB_init" parameters:dict];
    [verifyCount(_fbEventsMock, times(1)) setLoggingOverrideAppID:@"1234"];
    [verifyCount(_fbEventsMock, times(1)) activateApp];
    
    XCTAssertTrue(_handler.initialized);
    
}



@end

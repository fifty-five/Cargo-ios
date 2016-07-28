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

@property CARFirebaseTagHandler *handler;
@property Class firebaseAnalyticsMock;
@property Class firebaseConfMock;
@property FIRAnalyticsConfiguration *confMock;

@end



@implementation FirebaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARFirebaseTagHandler alloc] init];
    _firebaseConfMock = mockClass([FIRAnalyticsConfiguration class]);
    _firebaseAnalyticsMock = mockClass([FIRAnalytics class]);
    _confMock = mock([FIRAnalyticsConfiguration class]);

    [_handler setFireAnalyticsClass:_firebaseAnalyticsMock];
    [_handler setFireConfClass:_firebaseConfMock];
}



- (void)testInitCollectionEnabled{
    [given([_firebaseConfMock sharedInstance]) willReturn:_confMock];

    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@(YES), @"enableCollection", nil];
    [_handler execute:@"Firebase_init" parameters:dict];

    [verify(_confMock) setAnalyticsCollectionEnabled:YES];
}

- (void)testInitCollectionDisabledNSNumberWay{
    [given([_firebaseConfMock sharedInstance]) willReturn:_confMock];

    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"enableCollection", nil];
    [_handler execute:@"Firebase_init" parameters:dict];

    [verify(_confMock) setAnalyticsCollectionEnabled:NO];
}

- (void)testInitCollectionDisabledWrapWay{
    [given([_firebaseConfMock sharedInstance]) willReturn:_confMock];

    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@(NO), @"enableCollection", nil];
    [_handler execute:@"Firebase_init" parameters:dict];

    [verify(_confMock) setAnalyticsCollectionEnabled:NO];
}

- (void)testInitCollectionDefault{
    [given([_firebaseConfMock sharedInstance]) willReturn:_confMock];

    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: nil];
    [_handler execute:@"Firebase_init" parameters:dict];

    [verify(_confMock) setAnalyticsCollectionEnabled:YES];
}


- (void)testSimpleFirebaseIdentify{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"234", USER_ID, nil];
    [_handler execute:@"Firebase_identify" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(1)) setUserID:@"234"];
    [verifyCount(_firebaseAnalyticsMock, times(0)) setUserPropertyString:anything() forName:anything()];
}

- (void)testFullFirebaseIdentify{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"234", USER_ID, @"55", USER_AGE, @"Male", USER_GENDER, @"01223456789", USER_FACEBOOK_ID, nil];
    [_handler execute:@"Firebase_identify" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(1)) setUserID:@"234"];
    [verifyCount(_firebaseAnalyticsMock, times(3)) setUserPropertyString:anything() forName:anything()];
}

- (void)testUserPropertiesFirebaseIdentify{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"55", USER_AGE, @"Male", USER_GENDER, @"01223456789", USER_FACEBOOK_ID, nil];
    [_handler execute:@"Firebase_identify" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(0)) setUserID:anything()];
    [verifyCount(_firebaseAnalyticsMock, times(3)) setUserPropertyString:anything() forName:anything()];
}

- (void)testFailFirebaseIdentify{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: nil];
    [_handler execute:@"Firebase_identify" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(0)) setUserID:anything()];
    [verifyCount(_firebaseAnalyticsMock, times(0)) setUserPropertyString:anything() forName:anything()];
}



- (void)testSimpleTagEvent{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"aRandomEventName", EVENT_NAME, nil];
    [_handler execute:@"Firebase_tagEvent" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(1)) logEventWithName:@"aRandomEventName" parameters:nil];
}

- (void)testComplexTagEvent{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"aRandomEventName", EVENT_NAME, @"anEventParameter", @"anEventParamName", @"anotherEventParameter", @"anotherEventParamName", [NSNumber numberWithInteger:55], @"lastParamName", nil];
    [_handler execute:@"Firebase_tagEvent" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(0)) logEventWithName:@"aRandomEventName" parameters:nil];
    [verifyCount(_firebaseAnalyticsMock, times(1)) logEventWithName:@"aRandomEventName" parameters:anything()];
}

- (void)testFailTagEvent{
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"aRandomEventName", EVENT_TYPE, nil];
    [_handler execute:@"Firebase_tagEvent" parameters:dict];

    [verifyCount(_firebaseAnalyticsMock, times(0)) logEventWithName:anything() parameters:anything()];
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end

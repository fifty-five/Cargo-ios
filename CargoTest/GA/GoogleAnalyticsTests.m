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


#import "CARGoogleAnalyticsTagHandler.h"
#import "CARGoogleAnalyticsMacroHandler.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface GoogleAnalyticsTest : XCTestCase

@property (nonatomic, strong) CARGoogleAnalyticsTagHandler *handler;
@property (nonatomic, strong) GAI *instanceMock;
@property (nonatomic, strong) id<GAITracker> trackerMock;

@end


@implementation GoogleAnalyticsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARGoogleAnalyticsTagHandler alloc] init];

    _instanceMock = mock([GAI class]);
    _trackerMock = mockProtocol(@protocol(GAITracker));
    
    [_handler setInstance:_instanceMock];
    [_handler setTracker:_trackerMock];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/* ***************************************** Test Init ****************************************** */

#pragma mark - TestGoogleAnalytics
-(void)testInit{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"myUUID", @"applicationId", nil];

    [_handler execute:@"GA_init" parameters:dict];
    [verifyCount(_instanceMock, times(1) ) trackerWithTrackingId:@"myUUID"];
    XCTAssertTrue(_handler.initialized);
}

-(void)testWithoutInit{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"10", @"dispatchInterval", nil];

    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_instanceMock, times(0)) setDispatchInterval:10 ];
    [verifyCount(_trackerMock, times(0)) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(0)) setTrackUncaughtExceptions:true];
    [verifyCount(_instanceMock, times(0)) setDryRun:false];
    [verifyCount(_instanceMock, times(0)) setOptOut:false];
}

/* ****************************************** Test Set ****************************************** */

-(void) testSetDispatchInterval{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"10", @"dispatchInterval", nil];

    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:10 ];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:true];
}


-(void) testTrackUncaughtExceptions{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@false, @"trackUncaughtExceptions", nil];

    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:false];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:30];
}


-(void) testAllowIdfaCollection{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@false, @"allowIdfaCollection", nil];

    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:false];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:true];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:30];
}

-(void) testEnableOptOut{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"enableOptOut", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:true];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:30];
    [verifyCount(_instanceMock, times(1) ) setDryRun:false];
    [verifyCount(_instanceMock, times(1) ) setOptOut:true];
}

-(void) testDryRun{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"disableTracking", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:true];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:30];
    [verifyCount(_instanceMock, times(1) ) setDryRun:true];
    [verifyCount(_instanceMock, times(1) ) setOptOut:false];
}

-(void) testDefaultValues{
    NSDictionary * dict = [[NSDictionary alloc] init];

    [_handler setInitialized:true];
    [_handler execute:@"GA_set" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setAllowIDFACollection:true];
    [verifyCount(_instanceMock, times(1) ) setTrackUncaughtExceptions:true];
    [verifyCount(_instanceMock, times(1) ) setDispatchInterval:30];
    [verifyCount(_instanceMock, times(1) ) setDryRun:false];
    [verifyCount(_instanceMock, times(1) ) setOptOut:false];
}

/* **************************************** Test Identify *************************************** */

-(void) testIdentify{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"user", @"userId", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_identify" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) set:kGAIUserId value:@"user"];
}

-(void) testFailIdentify{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:nil, @"userId", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_identify" parameters:dict];
    [verifyCount(_trackerMock, times(0) ) set:kGAIUserId value:anything()];
}

/* **************************************** Test tagScreen ************************************** */

-(void) testTagScreen{
    NSDictionary * dict = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"my screen", @"screenName", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_tagScreen" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) set:kGAIScreenName value:@"my screen"];
    [verifyCount(_trackerMock, times(1) ) send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) testFailTagScreen{
    NSDictionary * dict = [[NSDictionary alloc] init];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_tagScreen" parameters:dict];
    [verifyCount(_trackerMock, times(0) ) set:kGAIScreenName value:anything()];
    [verifyCount(_trackerMock, times(0) ) send:[[GAIDictionaryBuilder createScreenView] build]];
}

/* **************************************** Test tagEvent *************************************** */

-(void) testTagEvent{
    NSDictionary * dict = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"action", @"eventAction",
                           @"category", @"eventCategory", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_tagEvent" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) send:anything()];
}

-(void) testFailTagEvent{
    NSDictionary * dict = [[NSDictionary alloc]
                           initWithObjectsAndKeys:@"action", @"eventAction", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"GA_tagEvent" parameters:dict];
    [verifyCount(_trackerMock, times(0) ) send:anything()];
}

@end

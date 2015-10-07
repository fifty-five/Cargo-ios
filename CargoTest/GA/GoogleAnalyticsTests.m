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

@interface GoogleAnalyticsTest : XCTestCase
    @property (nonatomic, strong) TAGManager *tagManager;
    @property (nonatomic, strong) TAGContainer *container;
    @property (nonatomic, strong) CARGoogleAnalyticsTagHandler *handler;
    @property (nonatomic, strong) GAI* gaInstance;
    @property (nonatomic, strong) id<GAITracker> tracker;

@end

@implementation GoogleAnalyticsTest

@synthesize handler;
@synthesize gaInstance;
@synthesize tracker;

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    handler = [[CARGoogleAnalyticsTagHandler alloc] init];
    self.gaInstance = [GAI sharedInstance];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-123456-9"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TestGoogleAnalytics

-(void) testSetDryRun{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"dryRun", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.dryRun, true, @"Failed to set dryRun to Google Analytics");
}

-(void) testSetDispatchInterval{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"10", @"dispatchInterval", nil];

    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.dispatchInterval, 10, @"Failed to set dispatchInterval to Google Analytics");
}

-(void) testEnableOptOut{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"optOut", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.optOut, true, @"Failed to set optOut to Google Analytics");
}

-(void) testDisableOptOut{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"false", @"optOut", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.optOut, false, @"Failed to set optOut to Google Analytics");
}

-(void) testEnableTrackUncaughtExceptions{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"trackUncaughtExceptions", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.trackUncaughtExceptions, true, @"Failed to enable trackUncaughtExceptions to Google Analytics");
}


-(void) testDisableTrackUncaughtExceptions{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@false, @"trackUncaughtExceptions", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(gaInstance.trackUncaughtExceptions, false, @"Failed to disable trackUncaughtExceptions to Google Analytics");
}



-(void) testEnableAllowIdfaCollection{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@true, @"allowIDFACollection", nil];
    [handler execute:@"GA_set" parameters:dict];
    XCTAssertEqual(tracker.allowIDFACollection, true, @"Failed to set allowIdfaCollection to Google Analytics");
}




@end

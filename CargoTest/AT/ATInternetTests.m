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


#import "CARATInternetTagHandler.h"


#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface ATInternetTest : XCTestCase

@property (nonatomic, strong) CARATInternetTagHandler *handler;
@property ATTracker * trackerMock;
@property ATInternet * instanceMock;

@end

@implementation ATInternetTest


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARATInternetTagHandler alloc] init];

    _instanceMock = mock([ATInternet class]);
    _trackerMock = mock([ATTracker class]);
    
    [_handler setInstance:_instanceMock];
    [_handler setTracker:_trackerMock];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - TestGoogleAnalytics

-(void)testATInit{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"fifty-five.com", @"domain",@"2345",@"siteId", nil];
    [_handler execute:@"AT_init" parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setConfig:@"siteId" value:@"2345" completionHandler:nil ];
    [verifyCount(_trackerMock, times(1) ) setConfig:@"domain" value:@"fifty-five.com" completionHandler:nil];

}



@end

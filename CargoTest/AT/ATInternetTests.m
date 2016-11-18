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
#import "CARConstants.h"


#import "CARATInternetTagHandler.h"


#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface ATInternetTest : XCTestCase

@property (nonatomic, strong) CARATInternetTagHandler *handler;
@property ATTracker *trackerMock;
@property ATInternet *instanceMock;

@property ATScreen *screenMock;
@property ATScreens *screensMock;
@property ATCustomObjects *customObjsMock;

@property ATGestures *gesturesMock;
@property ATGesture *gestureMock;

@end


@implementation ATInternetTest

NSString *TAG_SCREEN = @"AT_tagScreen";
NSString *TAG_EVENT = @"AT_tagEvent";
NSString *IDENTIFY = @"AT_identify";
NSString *INIT = @"AT_init";


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARATInternetTagHandler alloc] init];

    _instanceMock = mock([ATInternet class]);
    _trackerMock = mock([ATTracker class]);
    
    _screenMock = mock([ATScreen class]);
    _screensMock = mock([ATScreens class]);
    _customObjsMock = mock([ATCustomObjects class]);
    
    _gesturesMock = mock([ATGestures class]);
    _gestureMock = mock([ATGesture class]);
    
    
    [_handler setInstance:_instanceMock];
    [_handler setTracker:_trackerMock];
    
    [given([_trackerMock screens]) willReturn:_screensMock];
    [given([_trackerMock.screens addWithName:@"screenNameTest"]) willReturn:_screenMock];
    [given([_trackerMock customObjects]) willReturn:_customObjsMock];
    
    [given([_trackerMock gestures]) willReturn:_gesturesMock];
    [given([_trackerMock.gestures addWithName:@"testName"]) willReturn:_gestureMock];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TestATInternet

-(void)testAT_init{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"fifty-five.com", @"domain",@"2345",@"siteId", nil];
    [_handler execute:INIT parameters:dict];
    [verifyCount(_trackerMock, times(1) ) setConfig:@"siteId" value:@"2345" completionHandler:anything() ];
    [verifyCount(_trackerMock, times(1) ) setConfig:@"domain" value:@"fifty-five.com" completionHandler:anything()];

}

-(void)testAT_identifyUUIDParam{
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:uuid, USER_ID, nil];
    [_handler setInitialized:true];
    [_handler execute:IDENTIFY parameters:dict];
    
    [verifyCount(_trackerMock, times(1) ) setStringParam:USER_ID value:uuid];
}

-(void)testAT_withoutInit{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"screenNameTest", SCREEN_NAME, @55, LEVEL2, nil];
    
    [_handler setInitialized:false];
    [_handler execute:TAG_SCREEN parameters:dict];
    assertThat([_trackerMock screens], equalTo(_screensMock));
    assertThat([_trackerMock.screens addWithName:@"screenNameTest"], equalTo(_screenMock));
    
    [verifyCount(_screenMock, times(0) ) sendView];
}

-(void)testAT_tagScreenSimpleTest{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"screenNameTest", SCREEN_NAME, @55, LEVEL2, nil];
    
    [_handler setInitialized:true];
    [_handler execute:TAG_SCREEN parameters:dict];
    assertThat([_trackerMock screens], equalTo(_screensMock));
    assertThat([_trackerMock.screens addWithName:@"screenNameTest"], equalTo(_screenMock));
    
    [verifyCount(_screenMock, times(1) ) setLevel2:55];
    [verifyCount(_screenMock, times(1) ) sendView];
}

-(void)testAT_tagScreenCustomDimTest{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"screenNameTest", SCREEN_NAME, @55, LEVEL2, @"customDimTest1", CUSTOM_DIM1, @"customDimTest2", CUSTOM_DIM2, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_SCREEN parameters:dict];
    assertThat([_trackerMock screens], equalTo(_screensMock));
    assertThat([_trackerMock.screens addWithName:@"screenNameTest"], equalTo(_screenMock));

    [verifyCount(_customObjsMock, times(1) ) addWithDictionary:@{CUSTOM_DIM1: @"customDimTest1", CUSTOM_DIM2: @"customDimTest2"}];
    [verifyCount(_screenMock, times(1) ) setLevel2:55];
    [verifyCount(_screenMock, times(1) ) sendView];
}




-(void)testAT_tagEventTouchChapter2ShouldntSet{
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @"sendTouch", EVENT_TYPE, @55, LEVEL2, @"testChapter", @"chapter2", nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];

    assertThat([_trackerMock gestures], equalTo(_gesturesMock));
    assertThat([_trackerMock.gestures addWithName:@"testName"], equalTo(_gestureMock));

    [verifyCount(_gestureMock, times(0) ) setChapter1:@"testChapter1"];
    [verifyCount(_gestureMock, times(0) ) setChapter2:@"testChapter2"];
    [verifyCount(_gestureMock, times(0) ) setChapter3:@"testChapter3"];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(1) ) sendTouch];
}

-(void)testAT_tagEventDownloadChaptersShouldSet{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @"sendDownload", EVENT_TYPE, @55, LEVEL2, @"testChapter2", @"chapter2", @"testChapter1", @"chapter1", @"testChapter3", @"chapter3", nil];
    
    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    assertThat([_trackerMock gestures], equalTo(_gesturesMock));
    assertThat([_trackerMock.gestures addWithName:@"testName"], equalTo(_gestureMock));
    
    [verifyCount(_gestureMock, times(1) ) setChapter1:@"testChapter1"];
    [verifyCount(_gestureMock, times(1) ) setChapter2:@"testChapter2"];
    [verifyCount(_gestureMock, times(1) ) setChapter3:@"testChapter3"];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(1) ) sendDownload];
}

-(void)testAT_tagEventShouldntWork{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(0) ) setLevel2:55];
    [verifyCount(_gestureMock, times(0) ) sendTouch];
    [verifyCount(_gestureMock, times(0) ) sendNavigation];
    [verifyCount(_gestureMock, times(0) ) sendDownload];
    [verifyCount(_gestureMock, times(0) ) sendExit];
    [verifyCount(_gestureMock, times(0) ) sendSearch];
}


-(void)testAT_tagEventShouldSendTouch{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, @"sendTouch", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(1) ) sendTouch];
    [verifyCount(_gestureMock, times(0) ) sendNavigation];
    [verifyCount(_gestureMock, times(0) ) sendDownload];
    [verifyCount(_gestureMock, times(0) ) sendExit];
    [verifyCount(_gestureMock, times(0) ) sendSearch];
}

-(void)testAT_tagEventShouldSendNavigation{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, @"sendNavigation", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(0) ) sendTouch];
    [verifyCount(_gestureMock, times(1) ) sendNavigation];
    [verifyCount(_gestureMock, times(0) ) sendDownload];
    [verifyCount(_gestureMock, times(0) ) sendExit];
    [verifyCount(_gestureMock, times(0) ) sendSearch];
}

-(void)testAT_tagEventShouldSendDownload{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, @"sendDownload", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(0) ) sendTouch];
    [verifyCount(_gestureMock, times(0) ) sendNavigation];
    [verifyCount(_gestureMock, times(1) ) sendDownload];
    [verifyCount(_gestureMock, times(0) ) sendExit];
    [verifyCount(_gestureMock, times(0) ) sendSearch];
}

-(void)testAT_tagEventShouldSendExit{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, @"sendExit", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(0) ) sendTouch];
    [verifyCount(_gestureMock, times(0) ) sendNavigation];
    [verifyCount(_gestureMock, times(0) ) sendDownload];
    [verifyCount(_gestureMock, times(1) ) sendExit];
    [verifyCount(_gestureMock, times(0) ) sendSearch];
}

-(void)testAT_tagEventShouldSendSearch{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"testName", EVENT_NAME, @55, LEVEL2, @"sendSearch", EVENT_TYPE, nil];

    [_handler setInitialized:true];
    [_handler execute:TAG_EVENT parameters:dict];
    
    [verifyCount(_gestureMock, times(1) ) setLevel2:55];
    [verifyCount(_gestureMock, times(0) ) sendTouch];
    [verifyCount(_gestureMock, times(0) ) sendNavigation];
    [verifyCount(_gestureMock, times(0) ) sendDownload];
    [verifyCount(_gestureMock, times(0) ) sendExit];
    [verifyCount(_gestureMock, times(1) ) sendSearch];
}

@end



















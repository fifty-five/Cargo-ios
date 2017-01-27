//
//  TuneTests.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CARTuneTagHandler.h"
#import <Tune/Tune.h>
#import "CARConstants.h"
#import "CARItem.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface TuneTests : XCTestCase

@property CARTuneTagHandler *handler;
@property Class tuneClassMock;
@property FIFLogger *loggerMock;

@end



@implementation TuneTests


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARTuneTagHandler alloc] init];
    _tuneClassMock = mockClass([Tune class]);
    _loggerMock = mock([FIFLogger class]);
    
    [_handler setTuneClass:_tuneClassMock];
    [_handler setLogger:_loggerMock];
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) testInitTune {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"234",@"advertiserId",@"456",@"conversionKey", nil];
    [_handler execute:@"TUN_init" parameters:dict];
    [verifyCount(_tuneClassMock, times(1)) initializeWithTuneAdvertiserId:@"234" tuneConversionKey:@"456"];
    
    XCTAssertTrue(_handler.initialized);
}

-(void) testInitTuneWithoutRequiredParams {
    NSDictionary * dict = [[NSDictionary alloc ] init];
    [_handler execute:@"TUN_init" parameters:dict];
    [verifyCount(_tuneClassMock, times(0)) initializeWithTuneAdvertiserId:anything() tuneConversionKey:anything()];
    XCTAssertFalse(_handler.initialized);
}

-(void) testWithoutInit {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"55", USER_AGE, @"Male", USER_GENDER, @"01223456789", USER_FACEBOOK_ID, nil];

    [_handler execute:@"TUN_identify" parameters:dict];

    [verifyCount(_tuneClassMock, times(0)) setFacebookUserId:anything()];
    [verifyCount(_tuneClassMock, times(0)) setGender:TuneGenderMale];
    [verifyCount(_tuneClassMock, times(0)) setAge:55];
    [verifyCount(_tuneClassMock, times(0)) setTwitterUserId:anything()];
    [verifyCount(_tuneClassMock, times(0)) setGoogleUserId:anything()];

}

-(void) testTuneIdentifyAll {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"234", USER_ID,
                           @"55", USER_AGE,
                           @"Male", USER_GENDER,
                           @"test@test.com", USER_EMAIL,
                           @"Jean-Paul", USER_NAME,
                           @"01223456789", USER_FACEBOOK_ID,
                           @"01223456789", USER_TWITTER_ID,
                           @"01223456789", USER_GOOGLE_ID, nil];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_identify" parameters:dict];

    [verifyCount(_tuneClassMock, times(1)) setUserId:@"234"];
    [verifyCount(_tuneClassMock, times(1)) setFacebookUserId:@"01223456789"];
    [verifyCount(_tuneClassMock, times(1)) setGender:TuneGenderMale];
    [verifyCount(_tuneClassMock, times(1)) setAge:55];
    [verifyCount(_tuneClassMock, times(1)) setTwitterUserId:@"01223456789"];
    [verifyCount(_tuneClassMock, times(1)) setGoogleUserId:@"01223456789"];
}

-(void) testTuneIdentifyNone {
    NSDictionary * dict = [[NSDictionary alloc ] init];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_identify" parameters:dict];

    [verifyCount(_tuneClassMock, times(0)) setUserId:anything()];
    [verifyCount(_tuneClassMock, times(0)) setFacebookUserId:anything()];
    [verifyCount(_tuneClassMock, times(0)) setTwitterUserId:anything()];
    [verifyCount(_tuneClassMock, times(0)) setGoogleUserId:anything()];
    [verifyCount(_loggerMock, (times(0))) logParamSetWithSuccess:anything() withValue:anything()];
}

-(void) testTuneIdentifyWithFemaleGender {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"female", USER_GENDER, nil];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_identify" parameters:dict];

    [verifyCount(_tuneClassMock, times(1)) setGender:TuneGenderFemale];
}

-(void) testTuneIdentifyWithWeirdGender {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"skdjhf", USER_GENDER, nil];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_identify" parameters:dict];

    [verifyCount(_tuneClassMock, times(1)) setGender:TuneGenderUnknown];
}


-(void) testSimpleTagEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"eventName",EVENT_NAME,
                           @"USD", @"eventCurrencyCode", [NSNumber numberWithInt:42],
                           @"eventQuantity", nil];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_tagEvent" parameters:dict];
    
    [verifyCount(_tuneClassMock, times(1)) measureEvent:anything()];
}

-(void) testFullTagEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:
                           @"eventName", EVENT_NAME,
                           @"EUR", @"eventCurrencyCode",
                           @"ref123", @"eventRefId",
                           @"contentId", @"eventContentId",
                           @"contentType", @"eventContentType",
                           @"searchString", @"eventSearchString",
                           @"attr1", @"eventAttribute1",
                           @"attr2", @"eventAttribute2",
                           @"attr3", @"eventAttribute3",
                           @"attr4", @"eventAttribute4",
                           @"attr5", @"eventAttribute5",
                           [NSNumber numberWithInt:100], @"eventRating",
                           [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue], @"eventDate1",
                           [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] stringValue], @"eventDate2",
                           [NSNumber numberWithFloat:10.5f], @"eventRevenue",
                           [CARItem toGTM:[[NSArray alloc] initWithObjects:[[CARItem alloc] initWithName:@"test" andUnitPrice:15.0f andQuantity:6], nil]], @"eventItems",
                           [NSNumber numberWithInt:10], @"eventLevel",
                           [[NSData alloc] init], @"eventReceipt",
                           [NSNumber numberWithInt:15], @"eventQuantity",
                           [NSNumber numberWithInt:1], @"eventTransactionState", nil];
    
    [_handler setInitialized:true];
    [_handler execute:@"TUN_tagEvent" parameters:dict];

    [verifyCount(_loggerMock, (times(20))) logParamSetWithSuccess:anything() withValue:anything()];
    [verifyCount(_loggerMock, (times(0))) logUncastableParam:anything() toType:anything()];
    [verifyCount(_tuneClassMock, times(1)) measureEvent:anything()];
}

- (void) testFailedTagEvent {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys: @"USD", @"eventCurrencyCode",
                           [NSNumber numberWithInt:42], @"eventQuantity", nil];

    [_handler setInitialized:true];
    [_handler execute:@"TUN_tagEvent" parameters:dict];
    
    [verifyCount(_tuneClassMock, never()) measureEvent:anything()];
}

@end

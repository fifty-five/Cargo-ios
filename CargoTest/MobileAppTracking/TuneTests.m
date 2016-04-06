//
//  TuneTests.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TAGManager.h"
#import "CARTuneTagHandler.h"
#import <Tune/Tune.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface TuneTests : XCTestCase

@property CARTuneTagHandler *handler;
@property Class tuneClassMock;

@end



@implementation TuneTests


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARTuneTagHandler alloc] init];
    _tuneClassMock = mockClass([Tune class]);
    [_handler setTuneClass:_tuneClassMock];
}




- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) testInitTune {
    NSDictionary * dict = [[NSDictionary alloc ] initWithObjectsAndKeys:@"234",@"advertiserId",@"456",@"conversionKey", nil];
    [_handler execute:@"Tune_init" parameters:dict];
    [verifyCount(_tuneClassMock, times(1)) initializeWithTuneAdvertiserId:@"234" tuneConversionKey:@"456"];
    
    XCTAssertTrue(_handler.initialized);
    
}

-(void) testInitTuneWithoutRequiredParams {
    NSDictionary * dict = [[NSDictionary alloc ] init];
    [_handler execute:@"Tune_init" parameters:dict];
    [verifyCount(_tuneClassMock, times(0)) initializeWithTuneAdvertiserId:anything() tuneConversionKey:anything()];
    XCTAssertFalse(_handler.initialized);
    
}

-(void) testScreenName {
    NSDictionary * dict = [[NSDictionary alloc ]
                           initWithObjectsAndKeys:@"A screen",@"screenName", nil];

    
    [_handler execute:@"Tune_tagScreen" parameters:dict];
    [verifyCount(_tuneClassMock, times(1)) measureEvent:anything()];
}

@end

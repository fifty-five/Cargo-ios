//
//  AccengageTests.m
//  
//
//  Created by Julien on 10/10/16.
//  Copyright (c) 2016 fifty-five. All rights reserved.
//

#import <XCTest/XCTest.h>


//FIFTagHandler
#import "Cargo.h"
#import "CARConstants.h"


#import "CARAccengageTagHandler.h"


#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>




@interface AccengageTest : XCTestCase

@property (nonatomic, strong) CARAccengageTagHandler *handler;

@end


@implementation AccengageTest

NSString *INIT = @"ACC_init";
NSString *TAG_EVENT = @"ACC_tagEvent";


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARAccengageTagHandler alloc] init];


}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TestATInternet

-(void)testACC_init{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"fifty-five.com", @"domain",@"2345",@"siteId", nil];
    [_handler execute:INIT parameters:dict];

}


@end



















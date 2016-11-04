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

@property Cargo *cargoMock;
@property CARAccengageTagHandler *handler;
@property Class trackMock;

@end


@implementation AccengageTest

NSString *ACC_INIT = @"ACC_init";
NSString *ACC_TAG_EVENT = @"ACC_tagEvent";
NSString *ACC_TAG_PURCHASE = @"ACC_tagPurchaseEvent";
NSString *ACC_TAG_Cart = @"ACC_tagCartEvent";
NSString *ACC_TAG_LEAD = @"ACC_tagLead";
NSString *ACC_TAG_UPDATE = @"ACC_updateDeviceInfo";

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _handler = [[CARAccengageTagHandler alloc] init];
    _cargoMock = mock([Cargo class]);
    _trackMock = mockClass([BMA4STracker class]);
    
    [_handler setCargo:_cargoMock];
    [_handler setTracker:_trackMock];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TestAccengage

-(void)testValidACC_init{
    [given([_cargoMock isLaunchOptionsSet]) willReturnBool:true];
    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"fifty-five.com", @"partnerId",@"2345",@"privateKey", nil];
    [_handler execute:ACC_INIT parameters:dict];
    
    [verify(_trackMock) trackWithPartnerId:anything() privateKey:anything() options:anything()];
}

-(void)testFailACC_init1{
    [given([_cargoMock isLaunchOptionsSet]) willReturnBool:false];
    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"fifty-five.com", @"partnerId",@"2345",@"privateKey", nil];
    [_handler execute:ACC_INIT parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackWithPartnerId:anything() privateKey:anything() options:anything()];
}

-(void)testFailACC_init2{
    [given([_cargoMock isLaunchOptionsSet]) willReturnBool:true];
    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2345",@"privateKey", nil];
    [_handler execute:ACC_INIT parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackWithPartnerId:anything() privateKey:anything() options:anything()];
}



-(void)testWithoutInit{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt: 1002], @"eventType", nil];
    [_handler setInitialized:false];
    [_handler execute:ACC_TAG_EVENT parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackEventWithType:1002 parameters:anything()];
}



-(void)testSimpleCorrectACC_tagEvent{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt: 1002], @"eventType", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_EVENT parameters:dict];
    
    [verify(_trackMock) trackEventWithType:1002 parameters:@[]];
}

-(void)testComplexCorrectACC_tagEvent{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt: 1005], @"eventType", @"value1", @"param1", @"value2", @"param2", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_EVENT parameters:dict];
    
    [verify(_trackMock) trackEventWithType:1005 parameters:@[@"param1: value1", @"param2: value2"]];
}

-(void)testFailACC_tagEvent{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt: 1000], @"eventType", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_EVENT parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackEventWithType:1000 parameters:anything()];
}



-(void)testSimpleCorrectACC_tagPurchase{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"transactionId",
                           @"USD", @"currencyCode",
                           @"14.99", @"transactionTotal", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_PURCHASE parameters:dict];
    
    [verify(_trackMock) trackPurchaseWithId:@"5542" currency:@"USD" totalPrice: 14.99];
}

-(void)testMediumCorrectACC_tagPurchase{
    AccengageItem *item1 = [[AccengageItem alloc] initWithId:@"abd123"
                                                    label:@"item1"
                                                 category:@"cat1"
                                                    price:(double)19.99
                                                 quantity: 10];
    AccengageItem *item2 = [[AccengageItem alloc] initWithId:@"321abc"
                                                       label:@"item2"
                                                    category:@"cat2"
                                                       price:(double)99.99
                                                    quantity: 2];
    NSArray *array = [[NSArray alloc] initWithObjects:item1, item2, nil];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"transactionId",
                           @"USD", @"currencyCode",
                           array, @"transactionProducts", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_PURCHASE parameters:dict];
    
    [verifyCount(_trackMock, times(1)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything()];
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" totalPrice:14.99];;
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything() totalPrice:14.99];
}

-(void)testComplexCorrectACC_tagPurchase{
    AccengageItem *item1 = [[AccengageItem alloc] initWithId:@"abd123"
                                                       label:@"item1"
                                                    category:@"cat1"
                                                       price:(double)19.99
                                                    quantity: 10];
    AccengageItem *item2 = [[AccengageItem alloc] initWithId:@"321abc"
                                                       label:@"item2"
                                                    category:@"cat2"
                                                       price:(double)99.99
                                                    quantity: 2];
    NSArray *array = [[NSArray alloc] initWithObjects:item1, item2, nil];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"transactionId",
                           @"USD", @"currencyCode",
                           array, @"transactionProducts",
                           @"14.99", @"transactionTotal", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_PURCHASE parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything()];
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" totalPrice:14.99];;
    [verifyCount(_trackMock, times(1)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything() totalPrice:14.99];
}

-(void)testFallbackACC_tagPurchase{
    NSString *item1 = [[NSString alloc] initWithFormat:@"hello"];
    NSString *item2 = [[NSString alloc] initWithFormat:@"world"];
    NSArray *array = [[NSArray alloc] initWithObjects:item1, item2, nil];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"transactionId",
                           @"USD", @"currencyCode",
                           array, @"transactionProducts",
                           @"14.99", @"transactionTotal", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_PURCHASE parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything()];
    [verifyCount(_trackMock, times(1)) trackPurchaseWithId:@"5542" currency:@"USD" totalPrice:14.99];
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" items: anything() totalPrice:14.99];
}

-(void)testFailedACC_tagPurchase{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"transactionId",
                           @"USD", @"currencyCode", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_PURCHASE parameters:dict];
    
    [verifyCount(_trackMock, times(0)) trackPurchaseWithId:@"5542" currency:@"USD" totalPrice:14.99];
}



-(void)testCorrectACC_tagCart{
    AccengageItem *item1 = [[AccengageItem alloc] initWithId:@"abd123"
                                                       label:@"item1"
                                                    category:@"cat1"
                                                       price:(double)19.99
                                                    quantity: 10];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"5542", @"cartId",
                           @"USD", @"currencyCode",
                           item1, @"product", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_Cart parameters:dict];
    
    [verify(_trackMock) trackCartWithId:@"5542" forArticleWithId:item1.ID andLabel:item1.label category:item1.category price:item1.price currency:@"USD" quantity:item1.quantity];
}



-(void)testCorrectACC_tagLead{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"test1", @"leadLabel",
                           @"test2", @"leadValue", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_LEAD parameters:dict];
    
    [verify(_trackMock) trackLeadWithLabel:@"test1" value:@"test2"];
}



-(void)testCorrectACC_tagUpdateDevice{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"test1", @"leadLabel",
                           @"test2", @"leadValue", nil];
    [_handler setInitialized:true];
    [_handler execute:ACC_TAG_UPDATE parameters:dict];
    
    [verify(_trackMock) updateDeviceInfo:dict];
}

@end



















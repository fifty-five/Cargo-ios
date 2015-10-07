//
//  FIFTagHandlerTest.m
//  Cargo
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "FIFTagHandlerTest.h"
#import "TAGContainerOpener.h"


@implementation FIFTagHandlerTest

@synthesize tagManager;
@synthesize container;


- (void)setUp
{
    [super setUp];
    self.tagManager = [TAGManager instance];
    id<TAGContainerFuture> future = [TAGContainerOpener openContainerWithId:@"GTM-KJKKCN"
                                                                 tagManager:self.tagManager
                                                                   openType:kTAGOpenTypePreferFresh
                                                                    timeout:nil];
    self.container = [future get];
    NSURL *url = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];

    
    [[FIFTagHandler sharedHelper] initTagHandlerWithManager:self.tagManager
                                                  container:self.container];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - TestGoogleAnalytics
- (void)testSharedHelperNotEmpty {
    
    XCTAssert(sharedHandler.returnCode == FIFNotInitializedCode, @"Failed to set Google Analytics");
}

@end

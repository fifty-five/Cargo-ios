//
//  CARMobileAppTrackingTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARMobileAppTrackingTagHandler.h"



@implementation CARMobileAppTrackingTagHandler



+(void)load{
    CARMobileAppTrackingTagHandler *handler = [[CARMobileAppTrackingTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"MAT_init"];
}



-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"MAT_init"]){
        [self init:parameters];
    }

}


- (id)init
{
    if (self = [super init]) {
        self.key = @"MAT";
        self.name = @"Mobile App Tracking";
        self.valid = NO;
        self.initialized = NO;
        self.tuneClass = [Tune class];
    }
    return self;
}




- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}

-(void) init:(NSDictionary*) parameters{
    
    //Initialize Tune with required parameters
    NSString *advertiserId = [parameters objectForKey:@"advertiserId"];
    NSString *conversionKey = [parameters objectForKey:@"conversionKey"];
    
    
    if(advertiserId && conversionKey){
        [self.tuneClass initializeWithTuneAdvertiserId:advertiserId tuneConversionKey:conversionKey];
        self.initialized = TRUE;
    } else{
        FIFLog(kTAGLoggerLogLevelWarning,@"Missing required parameter advertiserId and conversionKey for Tune");
    }
    
    //then set values if necessary
    NSMutableDictionary * mutParams = [parameters mutableCopy];
    [mutParams removeObjectForKey:@"advertiserId"];
    [mutParams removeObjectForKey:@"conversionKey"];
    [self set:mutParams];
    
}





- (void)set:(NSDictionary *)parameters {
    
    
}





@end

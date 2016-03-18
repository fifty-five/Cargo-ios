//
//  CARAccengageTagHandler.m
//  Cargo
//
//  Created by François K on 18/03/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARAccengageTagHandler.h"
#import "CARConstants.h"

@implementation CARAccengageTagHandler

+(void)load{
    CARAccengageTagHandler *handler = [[CARAccengageTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"ACC_init"];
    [Cargo registerTagHandler:handler withKey:@"ACC_tagEvent"];

}


// Implémente la fonction de FunctionCallTagHandler de GTM (protocole qui hérite de FunctionCallTag Handler)
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"ACC_init"]){
        [self initiate:parameters];
    }else if([tagName isEqualToString:@"ACC_tagEvent"]){
            [self tagEvent:parameters];
    }
}


- (id)init
{
    if (self = [super init]) {
        self.key = @"ACC";
        self.name = @"Accengage";
        self.valid = NO;
        self.initialized = NO;
        self.tracker = [BMA4STracker class];
    }
    return self;
}



-(void) initiate:(NSDictionary*) parameters{
    
    //Initialize Accengage with required parameters
    NSString *partnerId = [parameters objectForKey:@"partnerId"];
    NSString *privateKey = [parameters objectForKey:@"privateKey"];  //nom qu'on veut lui donner pour la macro GTM
    NSDictionary* options = [[Cargo sharedHelper] launchOptions];
    
    if(!partnerId || !privateKey){
       FIFLog(kTAGLoggerLogLevelWarning, @" Accengage needs an partnerId and a privateKey");
        return;
    }
    
    [self.tracker trackWithPartnerId:partnerId privateKey:privateKey options:options];
    self.initialized=TRUE;
    
    FIFLog(kTAGLoggerLogLevelInfo, @" Accengage has been init with id %@ ", partnerId);

}

-(void) tagEvent:(NSDictionary*) parameters{
     NSString *eventName = [parameters objectForKey:EVENT_NAME];
     NSString *eventValue = [parameters objectForKey:EVENT_VALUE];
    
    
    if(!eventName){
        FIFLog(kTAGLoggerLogLevelWarning, @"You must provide and eventName with ACC_tagEvent");
    }
    
    [self.tracker trackLeadWithLabel:eventName value:eventValue];
    FIFLog(kTAGLoggerLogLevelInfo, @" Accengage event %@ has been sent", eventName);
    
}


@end

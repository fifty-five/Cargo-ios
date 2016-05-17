//
//  CARTuneTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARTuneTagHandler.h"
#import "CARConstants.h"

@implementation CARTuneTagHandler


// The runtime sends the load message very soon after the class object
// is loaded in the process's address space. (http://stackoverflow.com/a/13326633)
//
// Instanciate the handler, and register its callback methods to GTM through a Cargo method
+(void)load{
    CARTuneTagHandler *handler = [[CARTuneTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"Tune_init"];
    [Cargo registerTagHandler:handler withKey:@"Tune_tagEvent"];
    [Cargo registerTagHandler:handler withKey:@"Tune_tagScreen"];
    [Cargo registerTagHandler:handler withKey:@"Tune_identify"];
}


// This one will be called after a tag has been sent
//
// @param tagName       The method you aime to call (this should be define in GTM interface)
// @param parameters    A dictionary key-object used as a way to give parameters to the class method aimed here
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"Tune_init"]){
        [self init:parameters];
    } else if([tagName isEqualToString:@"Tune_tagScreen"]){
        [self tagScreen:parameters];
    } else if([tagName isEqualToString:@"Tune_identify"]){
        [self identify:parameters];
    }else if([tagName isEqualToString:@"Tune_tagEvent"]){
        [self tagEvent:parameters];
    }
}


// Called in +load method, setup what is needed for Cargo and the Tune SDK
- (id)init
{
    if (self = [super init]) {
        self.key = @"Tune";
        self.name = @"Tune";
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

// Setup Tune SDK with required parameters
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

// Allow you to identify the user through several ways
-(void) identify:(NSDictionary*) parameters{
    [Tune setUserId:[parameters valueForKey:USER_ID]];
    [Tune setFacebookUserId:[parameters valueForKey:USER_FACEBOOK_ID]];
    [Tune setGoogleUserId:[parameters valueForKey:USER_GOOGLE_ID]];
}

// Send a custom event to Tune
-(void) tagEvent:(NSDictionary*) parameters{
    TuneEvent *event = [TuneEvent eventWithName:[parameters valueForKey:EVENT_NAME]];
    [Tune measureEvent:event];
}


- (void)set:(NSDictionary *)parameters {
    
}

// Send a tag for the screen changes to Tune
- (void)tagScreen:(NSDictionary *)parameters {

    NSString* screenName = [parameters valueForKey:SCREEN_NAME];
    
    TuneEventItem *item1 = [TuneEventItem eventItemWithName:screenName unitPrice:0 quantity:0];
    NSArray *eventItems = @[item1];
    TuneEvent *event = [TuneEvent eventWithName:TUNE_EVENT_CONTENT_VIEW];
    event.eventItems = eventItems;

    [self.tuneClass measureEvent:event];
    
}






@end

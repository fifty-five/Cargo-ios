//
//  CARTuneTagHandler.m
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "CARTuneTagHandler.h"
#import "CARUtils.h"
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
    
    
    NSString *userId = [CARUtils castToNSString:[parameters valueForKey:USER_ID]];
    if (userId == nil){
        NSLog(@"Cargo TuneHandler : in identify() missing mandatory parameter USER_ID. USER_ID and any other parameters given haven't been set");
        return ;
    }
    [Tune setUserId:userId];
    if ([parameters objectForKey:USER_FACEBOOK_ID])
        [Tune setFacebookUserId:[CARUtils castToNSString:[parameters valueForKey:USER_FACEBOOK_ID]]];
    if ([parameters objectForKey:USER_GOOGLE_ID])
        [Tune setGoogleUserId:[CARUtils castToNSString:[parameters valueForKey:USER_GOOGLE_ID]]];
    if ([parameters objectForKey:USER_TWITTER_ID])
        [Tune setTwitterUserId:[CARUtils castToNSString:[parameters valueForKey:USER_TWITTER_ID]]];
    if ([parameters objectForKey:USER_AGE])
        [Tune setAge:[[parameters valueForKey:USER_AGE] intValue]];
    if ([parameters objectForKey:USER_GENDER])
        [self setGender:[CARUtils castToNSString:[parameters valueForKey:USER_GENDER]]];
}

// A method to set the gender with the parameters Tune awaits
-(void) setGender:(NSString*) gender{
    if (gender == nil) {
        NSLog(@"Cargo TuneHandler : Gender parameter given is nil, no gender set");
        return ;
    }

    NSString *upperGender = [gender uppercaseString];
    if ([upperGender isEqualToString:@"MALE"])
        [Tune setGender:TuneGenderMale];
    else if ([upperGender isEqualToString:@"FEMALE"])
        [Tune setGender:TuneGenderFemale];
    else {
        [Tune setGender:TuneGenderUnknown];
        NSLog(@"Cargo TuneHandler : Gender should be MALE/FEMALE. Gender set to UNKNOWN");
    }
}

// Send a custom event to Tune
-(void) tagEvent:(NSDictionary*) parameters{
    NSString* eventName = [CARUtils castToNSString:[parameters valueForKey:EVENT_NAME]];
    TuneEvent *event = [TuneEvent eventWithName:eventName];
    [Tune measureEvent:event];
}


- (void)set:(NSDictionary *)parameters {
    
}

// Send a tag for the screen changes to Tune
- (void)tagScreen:(NSDictionary *)parameters {

    NSString* screenName = [CARUtils castToNSString:[parameters valueForKey:SCREEN_NAME]];
    
    TuneEventItem *item1 = [TuneEventItem eventItemWithName:screenName unitPrice:0 quantity:0];
    NSArray *eventItems = @[item1];
    TuneEvent *event = [TuneEvent eventWithName:TUNE_EVENT_CONTENT_VIEW];
    event.eventItems = eventItems;

    [self.tuneClass measureEvent:event];
    
}






@end

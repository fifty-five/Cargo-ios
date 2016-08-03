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


NSString *const EVENT_RATING = @"eventRating";
NSString *const EVENT_DATE1 = @"eventDate1";
NSString *const EVENT_DATE2 = @"eventDate2";
NSString *const EVENT_REVENUE = @"eventRevenue";
NSString *const EVENT_ITEMS = @"eventItems";
NSString *const EVENT_LEVEL = @"eventLevel";
NSString *const EVENT_RECEIPT = @"eventReceipt";
NSString *const EVENT_QUANTITY = @"eventQuantity";
NSString *const EVENT_TRANSACTION_STATE = @"eventTransactionState";

NSArray *EVENT_PROPERTIES;

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

    EVENT_PROPERTIES = [NSArray arrayWithObjects:@"eventCurrencyCode", @"eventRefId", @"eventContentId", @"eventContentType", @"eventSearchString", @"eventAttribute1", @"eventAttribute2", @"eventAttribute3", @"eventAttribute4", @"eventAttribute5", nil];
}


// This one will be called after a tag has been sent
//
// @param tagName       The method you aim to call (this should be define in GTM interface)
// @param parameters    A dictionary key-object used as a way to give parameters to the class method aimed here
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];
    if([tagName isEqualToString:@"Tune_init"]){
        [self init:parameters];
    } else if([tagName isEqualToString:@"Tune_identify"]){
        [self identify:parameters];
    } else if([tagName isEqualToString:@"Tune_tagScreen"]){
        [self tagScreen:[parameters mutableCopy]];
    }else if([tagName isEqualToString:@"Tune_tagEvent"]){
        [self tagEvent:[parameters mutableCopy]];
    }else {
        NSLog(@"Cargo TuneHandler : Function %@ is not registered", tagName);
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
    [self.tuneClass setUserId:userId];
    if ([parameters objectForKey:USER_FACEBOOK_ID])
        [self.tuneClass setFacebookUserId:[CARUtils castToNSString:[parameters valueForKey:USER_FACEBOOK_ID]]];
    if ([parameters objectForKey:USER_GOOGLE_ID])
        [self.tuneClass setGoogleUserId:[CARUtils castToNSString:[parameters valueForKey:USER_GOOGLE_ID]]];
    if ([parameters objectForKey:USER_TWITTER_ID])
        [self.tuneClass setTwitterUserId:[CARUtils castToNSString:[parameters valueForKey:USER_TWITTER_ID]]];
    if ([parameters objectForKey:USER_AGE])
        [self.tuneClass setAge:[[parameters valueForKey:USER_AGE] intValue]];
    if ([parameters objectForKey:USER_NAME])
        [self.tuneClass setUserName:[CARUtils castToNSString:[parameters valueForKey:USER_NAME]]];
    if ([parameters objectForKey:USER_EMAIL])
        [self.tuneClass setUserEmail:[CARUtils castToNSString:[parameters valueForKey:USER_EMAIL]]];
    if ([parameters objectForKey:USER_GENDER])
        [self setGender:[CARUtils castToNSString:[parameters valueForKey:USER_GENDER]]];
}


/**
 * Method used to create and fire an event to the Tune Console
 * The mandatory parameters are EVENT_NAME or EVENT_ID which are a necessity to build the event
 * Without this parameter, the event won't be built.
 * After the creation of the event object, some attributes can be added through the eventBuilder
 * method, using the map obtained from the gtm container.
 *
 * @param map   the parameters given at the moment of the [dataLayer push],
 *              passed through the GTM container and the execute method.
 *              The only parameter requested here is a name or an id for the event
 *              (EVENT_NAME or EVENT_ID)
 */
-(void) tagEvent:(NSMutableDictionary*) parameters{

    TuneEvent* tuneEvent;

    if ([parameters objectForKey:EVENT_NAME]) {
        NSString* eventName = [CARUtils castToNSString:[parameters valueForKey:EVENT_NAME]];
        tuneEvent = [TuneEvent eventWithName:eventName];
        [parameters removeObjectForKey:EVENT_NAME];
    }
    else if ([parameters objectForKey:EVENT_ID]) {
        NSNumber* eventId = [CARUtils castToNSNumber:[parameters valueForKey:EVENT_ID]];
        tuneEvent = [TuneEvent eventWithId:[eventId intValue]];
        [parameters removeObjectForKey:EVENT_ID];
    }
    else {
        NSLog(@"Cargo TuneHandler : in order to create an event, an eventName or eventId is mandatory. The event hasn't been created");
        return ;
    }

    tuneEvent = [self buildEvent: tuneEvent withParameters: parameters];

    if (tuneEvent)
        [self.tuneClass measureEvent:tuneEvent];
}


/**
 * Method used to create and fire a screen view to the Tune Console
 * The mandatory parameters is SCREEN_NAME which is a necessity to build the tagScreen.
 * Actually, as no native tagScreen is given in the Tune SDK, we fire a custom event.
 *
 * After the creation of the event object, some attributes can be added through the
 * buildEvent:withParameters: method, using the NSDictionary obtained from the gtm container.
 * We recommend to use Attribute1/2 if you need more information about the screen.
 *
 * @param map   the parameters given at the moment of the [dataLayer push],
 *              passed through the GTM container and the execute method.
 *              The only parameter requested here is a name for the screen
 *              (SCREEN_NAME)
 */
- (void)tagScreen:(NSMutableDictionary *)parameters {

    TuneEvent* tuneEvent;

    if ([parameters objectForKey:SCREEN_NAME]) {
        NSString* screenName = [CARUtils castToNSString:[parameters valueForKey:SCREEN_NAME]];
        tuneEvent = [TuneEvent eventWithName:screenName];
        [parameters removeObjectForKey:SCREEN_NAME];
    }
    else {
        NSLog(@"Cargo TuneHandler : in order to create a tagScreen, an screenName is mandatory. The event hasn't been created");
        return ;
    }

    tuneEvent = [self buildEvent: tuneEvent withParameters: parameters];

    if (tuneEvent)
        [self.tuneClass measureEvent:tuneEvent];

}


/**
 * The method used to add attributes to the event object given as a parameter. The NSDictionary contains
 * the key of the attributes to attach to this event. For the name of the key you have to give,
 * please have a look at all the EVENT_... constants on the top of this file. The NSString Array
 * contains all the parameters requested as NSString from Tune SDK, reflection is used to call the
 * corresponding instance methods.
 *
 * @param parameters    the key/value list of the attributes you want to attach to your event
 * @param tuneEvent     the event you want to custom
 * @return              the custom event
 */
- (TuneEvent *) buildEvent:(TuneEvent *) tuneEvent withParameters:(NSMutableDictionary *)parameters {

    if ([parameters objectForKey:EVENT_RATING]) {
        tuneEvent.rating = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_RATING] withDefault:-1];
        [parameters removeObjectForKey:EVENT_RATING];
    }
    if ([parameters objectForKey:EVENT_DATE1]) {
        tuneEvent.date1 = [CARUtils castToNSDate:[parameters valueForKey:EVENT_DATE1]];
        [parameters removeObjectForKey:EVENT_DATE1];

        if ([parameters objectForKey:EVENT_DATE2]) {
            tuneEvent.date2 = [CARUtils castToNSDate:[parameters valueForKey:EVENT_DATE2]];
            [parameters removeObjectForKey:EVENT_DATE2];
        }
    }
    if ([parameters objectForKey:EVENT_REVENUE]) {
        tuneEvent.revenue = [CARUtils castToFloat:[parameters valueForKey:EVENT_REVENUE] withDefault:-1];
        [parameters removeObjectForKey:EVENT_REVENUE];
    }
    if ([parameters objectForKey:EVENT_ITEMS]) {
        tuneEvent.eventItems = [CARUtils castToNSArray:[parameters valueForKey:EVENT_ITEMS]];
        [parameters removeObjectForKey:EVENT_ITEMS];
    }
    if ([parameters objectForKey:EVENT_LEVEL]) {
        tuneEvent.level = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_LEVEL] withDefault:-1];
        [parameters removeObjectForKey:EVENT_LEVEL];
    }
    if ([parameters objectForKey:EVENT_TRANSACTION_STATE]) {
        tuneEvent.transactionState = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_TRANSACTION_STATE] withDefault:-1];
        [parameters removeObjectForKey:EVENT_TRANSACTION_STATE];
    }
    if ([parameters objectForKey:EVENT_RECEIPT]) {
        tuneEvent.receipt = [CARUtils castToNSData:[parameters valueForKey:EVENT_RECEIPT]];
        [parameters removeObjectForKey:EVENT_RECEIPT];
    }
    if ([parameters objectForKey:EVENT_QUANTITY]) {
        int qty = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_QUANTITY] withDefault:-1];
        if (qty >= 0)
            tuneEvent.quantity = (NSUInteger)qty;
        else
            tuneEvent.quantity = 0;
        [parameters removeObjectForKey:EVENT_QUANTITY];
    }

    for (int i = 0 ; i < [EVENT_PROPERTIES count]; i++)
    {
        if ([parameters objectForKey:EVENT_PROPERTIES[i]])
        {
            NSString* propertyName = [EVENT_PROPERTIES[i] substringFromIndex:5];
            NSString* firstChar = [propertyName substringToIndex:1];
            firstChar = [firstChar lowercaseString];
            propertyName = [propertyName substringFromIndex:1];

            propertyName = [NSString stringWithFormat:@"%@%@", firstChar, propertyName];

            if (!tuneEvent) {
                NSLog(@"Cargo TuneHandler : trying to set properties on a nil TuneEvent. Operation has been cancelled");
                return nil;
            }
            NSString* value = [CARUtils castToNSString:[parameters valueForKey:EVENT_PROPERTIES[i]]];
            [tuneEvent setValue:value forKey:propertyName];

            [parameters removeObjectForKey:EVENT_PROPERTIES[i]];
        }
    }

    for (NSString* leftKey in parameters)
        NSLog(@"Cargo TuneHandler : the event builder couldn't find any match with the parameter key [%@] with value [%@]", leftKey, [CARUtils castToNSString:[parameters valueForKey:leftKey]]);

    return tuneEvent;
}


/**
 * A simple method called by identify() to set the gender in a secured way
 *
 * @param gender    The gender given in the identify method.
 *                  If the gender doesn't match with the Tune genders,
 *                  sets the gender to UNKNOWN.
 */
-(void) setGender:(NSString*) gender{
    if (gender == nil) {
        NSLog(@"Cargo TuneHandler : Gender parameter given is nil, no gender set");
        return ;
    }

    NSString *upperGender = [gender uppercaseString];
    if ([upperGender isEqualToString:@"MALE"])
        [self.tuneClass setGender:TuneGenderMale];
    else if ([upperGender isEqualToString:@"FEMALE"])
        [self.tuneClass setGender:TuneGenderFemale];
    else {
        [self.tuneClass setGender:TuneGenderUnknown];
        NSLog(@"Cargo TuneHandler : Gender should be MALE/FEMALE. Gender set to UNKNOWN");
    }
}

- (void) set:(NSDictionary *)parameters {
    
}






@end
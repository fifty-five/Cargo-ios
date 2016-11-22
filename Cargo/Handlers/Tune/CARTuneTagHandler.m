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

/**
 The class which handles interactions with the Accengage SDK.
 */
@implementation CARTuneTagHandler

/* *********************************** Variables Declaration ************************************ */

/** Constants used to define callbacks in the register and in the execute method */
NSString* const Tune_init = @"Tune_init";
NSString* const Tune_tagEvent = @"Tune_tagEvent";
NSString* const Tune_tagScreen = @"Tune_tagScreen";
NSString* const Tune_identify = @"Tune_identify";

/** All the parameters that could be set as attributes to a TuneEvent object */
NSString* const EVENT_RATING = @"eventRating";
NSString* const EVENT_DATE1 = @"eventDate1";
NSString* const EVENT_DATE2 = @"eventDate2";
NSString* const EVENT_REVENUE = @"eventRevenue";
NSString* const EVENT_ITEMS = @"eventItems";
NSString* const EVENT_LEVEL = @"eventLevel";
NSString* const EVENT_RECEIPT = @"eventReceipt";
NSString* const EVENT_QUANTITY = @"eventQuantity";
NSString* const EVENT_TRANSACTION_STATE = @"eventTransactionState";

NSArray* EVENT_PROPERTIES;
NSArray* ALL_EVENT_PROPERTIES;


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 Also fill the array of possible Tune event parameters.
 */
+(void)load{
    CARTuneTagHandler* handler = [[CARTuneTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:Tune_init];
    [Cargo registerTagHandler:handler withKey:Tune_tagEvent];
    [Cargo registerTagHandler:handler withKey:Tune_tagScreen];
    [Cargo registerTagHandler:handler withKey:Tune_identify];

    EVENT_PROPERTIES = [NSArray arrayWithObjects:@"eventCurrencyCode", @"eventRefId",
                        @"eventContentId", @"eventContentType", @"eventSearchString",
                        @"eventAttribute1", @"eventAttribute2", @"eventAttribute3",
                        @"eventAttribute4", @"eventAttribute5", nil];

    ALL_EVENT_PROPERTIES = [NSArray arrayWithObjects:@"eventCurrencyCode", @"eventRefId",
                            @"eventContentId", @"eventContentType", @"eventSearchString",
                            @"eventAttribute1", @"eventAttribute2", @"eventAttribute3",
                            @"eventAttribute4", @"eventAttribute5", @"eventRating", @"eventDate1",
                            @"eventDate2", @"eventRevenue", @"eventItems", @"eventLevel",
                            @"eventReceipt", @"eventQuantity", @"eventTransactionState", nil];
}

/**
 Instantiate the handler with its key and name properties
 Initialize its attribute to the default values.

 @return the instance of the Tune handler
 */
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

/**
 Call back from GTM container to call a specific method
 after a function tag and associated parameters are received

 @param tagName The tag name of the aimed method
 @param parameters Dictionary of parameters
 */
-(void) execute:(NSString *)tagName parameters:(NSDictionary *)parameters{
    [super execute:tagName parameters:parameters];

    if([tagName isEqualToString:Tune_init]){
        [self init:parameters];
    // check whether the SDK has been initialized before calling any method
    } else if (self.initialized) {
        if ([tagName isEqualToString:Tune_identify]){
            [self identify:parameters];
        }
        else if([tagName isEqualToString:Tune_tagScreen]){
            [self tagScreen:[parameters mutableCopy]];
        }
        else if([tagName isEqualToString:Tune_tagEvent]){
            [self tagEvent:[parameters mutableCopy]];
        }
        else {
            NSLog(@"Cargo TuneHandler : Function %@ is not registered", tagName);
        }
    }
    else
        [self.logger logUninitializedFramework:self.name];
}

/**
 Called in registerHandlers to validate a handler and check for its initialization.
 */
- (void)validate
{
    // Nothing is required
    self.valid = TRUE;
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Tune SDK
 Register the advertiser ID and the conversion key to the Tune SDK.
 
 @param conversionKey: a key Tune gives when you register your app
 @param advertiserId: an ID Tune gives when you register your app
 */
-(void) init:(NSDictionary*)parameters{
    NSString* adId = [CARUtils castToNSString:[parameters objectForKey:@"advertiserId"]];
    NSString* convKey = [CARUtils castToNSString:[parameters objectForKey:@"conversionKey"]];

    if (adId && convKey) {
        [self.tuneClass initializeWithTuneAdvertiserId:adId tuneConversionKey:convKey];
        self.initialized = TRUE;
    }
    else {
        FIFLog(kTAGLoggerLogLevelWarning,@"Missing required parameter advertiserId and conversionKey for Tune");
    }
}


/* ****************************************** Tracking ****************************************** */

/**
 Allows to identify the current user through several ways.

 @param userId : the ID used to reference this user
 @param userage : age of the user
 @param userName : name of the user
 @param userEmail : email adress of the user
 @param userFacebookId : the id of the facebook account of the user
 @param userGoogleId : the id of the google account of the user
 @param userTwitterId : the id of the twitter account of the user
 @param userGender : user's gender as MALE, FEMALE. Any other input will be changed to UNKNOWN

 */
-(void) identify:(NSDictionary*) parameters{
    
    NSString* userId = [CARUtils castToNSString:[parameters valueForKey:USER_ID]];
    NSNumber* userAge = [CARUtils castToNSNumber:[parameters valueForKey:USER_AGE]];
    NSString* userName = [CARUtils castToNSString:[parameters valueForKey:USER_NAME]];
    NSString* userMail = [CARUtils castToNSString:[parameters valueForKey:USER_EMAIL]];
    NSString* facebookId = [CARUtils castToNSString:[parameters valueForKey:USER_FACEBOOK_ID]];
    NSString* googleId = [CARUtils castToNSString:[parameters valueForKey:USER_GOOGLE_ID]];
    NSString* twitterId = [CARUtils castToNSString:[parameters valueForKey:USER_TWITTER_ID]];
    NSString* userGender = [CARUtils castToNSString:[parameters valueForKey:USER_GENDER]];
    
    if (userId) {
        [self.tuneClass setUserId:userId];
        [self.logger logParamSetWithSuccess:USER_ID withValue:userId];
    }
    if (userAge != nil) {
        [self.tuneClass setAge:[userAge intValue]];
        [self.logger logParamSetWithSuccess:USER_AGE withValue:userAge];
    }
    if (userName) {
        [self.tuneClass setUserName:userName];
        [self.logger logParamSetWithSuccess:USER_NAME withValue:userName];
    }
    if (userMail) {
        [self.tuneClass setUserEmail:userMail];
        [self.logger logParamSetWithSuccess:USER_EMAIL withValue:userMail];
    }
    if (facebookId) {
        [self.tuneClass setFacebookUserId:facebookId];
        [self.logger logParamSetWithSuccess:USER_FACEBOOK_ID withValue:facebookId];
    }
    if (googleId) {
        [self.tuneClass setGoogleUserId:googleId];
        [self.logger logParamSetWithSuccess:USER_GOOGLE_ID withValue:googleId];
    }
    if (twitterId) {
        [self.tuneClass setTwitterUserId:twitterId];
        [self.logger logParamSetWithSuccess:USER_TWITTER_ID withValue:twitterId];
    }
    if (userGender)
        [self setGender:userGender];
}

/**
 Method used to create and fire an event to the Tune Console.
 The mandatory parameters are eventName OR eventId.
 Many other parameters can be add to the event : http://tinyurl.com/hry2slr

 @param eventName
 @param eventId
 @param eventRating
 @param eventDate1
 @param eventDate2
 @param eventRevenue
 @param eventItems
 @param eventLevel
 @param eventReceipt
 @param eventQuantity
 @param eventTransactionState
 @param eventCurrencyCode
 @param eventRefId
 @param eventContentId
 @param eventContentType
 @param eventSearchString
 @param eventAttribute1
 @param eventAttribute2
 @param eventAttribute3
 @param eventAttribute4
 @param eventAttribute5
 */
-(void) tagEvent:(NSMutableDictionary*) parameters{

    NSString* eventName = [CARUtils castToNSString:[parameters valueForKey:EVENT_NAME]];
    NSNumber* eventId = [CARUtils castToNSNumber:[parameters valueForKey:EVENT_ID]];
    TuneEvent* tuneEvent;

    if (eventName) {
        tuneEvent = [TuneEvent eventWithName:eventName];
        [parameters removeObjectForKey:EVENT_NAME];
    }
    else if (eventId != nil) {
        tuneEvent = [TuneEvent eventWithId:[eventId intValue]];
        [parameters removeObjectForKey:EVENT_ID];
    }
    else {
        [self.logger logMissingParam:@"eventName and eventId" inMethod:Tune_tagEvent];
        return ;
    }

    if ([parameters count] > 0)
        tuneEvent = [self buildEvent: tuneEvent withParameters: parameters];

    if (tuneEvent) {
        [self.tuneClass measureEvent:tuneEvent];
        if (eventName)
            [self.logger logParamSetWithSuccess:eventName withValue:parameters];
        else
            [self.logger logParamSetWithSuccess:[eventId stringValue] withValue:parameters];
    }
}

/**
 Method used to create and fire a screen view to the Tune Console
 The mandatory parameter is screenName.
 Actually, as no native tagScreen is given in the Tune SDK, we fire a custom event.
 We recommend to use Attribute1/2 if you need more information about the screen.

 @param screenName
 @param eventRating
 @param eventDate1
 @param eventDate2 : will be set just if eventDate1 is also set.
 @param eventRevenue
 @param eventItems
 @param eventLevel
 @param eventReceipt
 @param eventQuantity
 @param eventTransactionState
 @param eventCurrencyCode
 @param eventRefId
 @param eventContentId
 @param eventContentType
 @param eventSearchString
 @param eventAttribute1
 @param eventAttribute2
 @param eventAttribute3
 @param eventAttribute4
 @param eventAttribute5
 */
- (void)tagScreen:(NSMutableDictionary *)parameters {
    NSString* screenName = [CARUtils castToNSString:[parameters valueForKey:SCREEN_NAME]];
    TuneEvent* tuneEvent;

    if (screenName) {
        tuneEvent = [TuneEvent eventWithName:screenName];
        [parameters removeObjectForKey:SCREEN_NAME];
    }
    else {
        [self.logger logMissingParam:SCREEN_NAME inMethod:Tune_tagScreen];
        return ;
    }

    if ([parameters count] > 0)
        tuneEvent = [self buildEvent: tuneEvent withParameters: parameters];

    if (tuneEvent) {
        [self.tuneClass measureEvent:tuneEvent];
        [self.logger logParamSetWithSuccess:screenName withValue:parameters];
    }
}


/* ****************************************** Utility ******************************************* */

/**
 The method used to add attributes to the event object given as a parameter. NSDictionary contains
 keys of the attributes to attach to this event. 
 The EVENT_PROPERTIES Array contains all the parameters requested as NSString from Tune SDK,
 reflection is used to call the corresponding instance methods.

 @param tuneEvent the event which more parameters are set to
 @param parameters the additional parameters
 @return the event with all the parameters set
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
        [self.logger logNotFoundValue:[parameters valueForKey:leftKey]
                               forKey:leftKey
                           inValueSet:ALL_EVENT_PROPERTIES];
    return tuneEvent;
}

/**
 Helper which sets the tune gender for an user, from a NSString to the right TuneGender type

 @param gender the user gender, as MALE, FEMALE. Any other input will be changed to UNKNOWN
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

@end

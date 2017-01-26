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
NSString* const TUN_INIT = @"TUN_init";
NSString* const TUN_TAG_EVENT = @"TUN_tagEvent";
NSString* const TUN_IDENTIFY = @"TUN_identify";

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

NSArray* EVENT_STRING_PROPERTIES;
NSArray* EVENT_MIXED_PROPERTIES;

NSString* const ADVERTISER_ID = @"advertiserId";
NSString* const CONVERSION_KEY = @"conversionKey";


/* ********************************** Handler core methods ************************************** */

/**
 Called on runtime to instantiate the handler.
 Register the callbacks to the container. After a [dataLayer push:@{}],
 these will trigger the execute method of this handler.
 Also fill the array of possible Tune event parameters.
 */
+(void)load{
    CARTuneTagHandler* handler = [[CARTuneTagHandler alloc] init];

    EVENT_STRING_PROPERTIES = [NSArray arrayWithObjects:@"eventCurrencyCode", @"eventRefId",
                        @"eventContentId", @"eventContentType", @"eventSearchString",
                        @"eventAttribute1", @"eventAttribute2", @"eventAttribute3",
                        @"eventAttribute4", @"eventAttribute5", nil];

    EVENT_MIXED_PROPERTIES = [NSArray arrayWithObjects:@"eventRating", @"eventDate1",
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
    if (self = [super initWithKey:@"TUN" andName:@"Tune"]) {
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

    if([tagName isEqualToString:TUN_INIT]){
        [self initialize:parameters];
    // check whether the SDK has been initialized before calling any method
    } else if (self.initialized) {
        if ([tagName isEqualToString:TUN_IDENTIFY]){
            [self identify:parameters];
        }
        else if([tagName isEqualToString:TUN_TAG_EVENT]){
            [self tagEvent:[parameters mutableCopy]];
        }
        else
            [self.logger logUnknownFunctionTag:tagName];
    }
    else
        [self.logger logUninitializedFramework];
}


/* ************************************ SDK initialization ************************************** */

/**
 The method you need to call first. Allow you to initialize Tune SDK
 Register the advertiser ID and the conversion key to the Tune SDK.
 
 @param conversionKey: a key Tune gives when you register your app
 @param advertiserId: an ID Tune gives when you register your app
 */
-(void) initialize:(NSDictionary*)parameters{
    NSString* adId = [CARUtils castToNSString:[parameters objectForKey:ADVERTISER_ID]];
    NSString* convKey = [CARUtils castToNSString:[parameters objectForKey:CONVERSION_KEY]];

    if (adId && convKey) {
        [self.tuneClass initializeWithTuneAdvertiserId:adId tuneConversionKey:convKey];
        [self.logger logParamSetWithSuccess:ADVERTISER_ID withValue:adId];
        [self.logger logParamSetWithSuccess:CONVERSION_KEY withValue:convKey];
        self.initialized = TRUE;
    }
    else {
        [self.logger logMissingParam:@"advertiserId and/or conversionKey" inMethod:TUN_INIT];
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
        [self.logger logParamSetWithSuccess:EVENT_NAME withValue:eventName];
        [parameters removeObjectForKey:EVENT_NAME];
    }
    else if (eventId != nil) {
        tuneEvent = [TuneEvent eventWithId:[eventId intValue]];
        [self.logger logParamSetWithSuccess:EVENT_ID withValue:eventId];
        [parameters removeObjectForKey:EVENT_ID];
    }
    else {
        [self.logger logMissingParam:@"eventName and eventId" inMethod:TUN_TAG_EVENT];
        return ;
    }

    if ([parameters count] > 0)
        tuneEvent = [self buildEvent: tuneEvent withParameters: parameters];

    if (tuneEvent) {
        [self.tuneClass measureEvent:tuneEvent];
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

    tuneEvent = [self getEvent:tuneEvent WithNumberParameters:parameters];
    tuneEvent = [self getEvent:tuneEvent WithComplexParameters:parameters];
    for (NSString* key in EVENT_MIXED_PROPERTIES) {
        [parameters removeObjectForKey:key];
    }

    for (int i = 0 ; i < [EVENT_STRING_PROPERTIES count]; i++)
    {
        if ([parameters objectForKey:EVENT_STRING_PROPERTIES[i]])
        {
            NSString* propertyName = [EVENT_STRING_PROPERTIES[i] substringFromIndex:5];
            NSString* firstChar = [propertyName substringToIndex:1];
            firstChar = [firstChar lowercaseString];
            propertyName = [propertyName substringFromIndex:1];

            propertyName = [NSString stringWithFormat:@"%@%@", firstChar, propertyName];

            NSString* value = [CARUtils castToNSString:[parameters
                                                        valueForKey:EVENT_STRING_PROPERTIES[i]]];
            [tuneEvent setValue:value forKey:propertyName];
            [self.logger logParamSetWithSuccess:EVENT_STRING_PROPERTIES[i] withValue:value];
            [parameters removeObjectForKey:EVENT_STRING_PROPERTIES[i]];
        }
    }

    for (NSString* leftKey in parameters) {
        [self.logger logNotFoundValue:[parameters valueForKey:leftKey]
                               forKey:leftKey
                           inValueSet:[EVENT_STRING_PROPERTIES
                                       arrayByAddingObjectsFromArray:EVENT_MIXED_PROPERTIES]];
    }
    return tuneEvent;
}


/**
 Adds the correct properties with number types to the TuneEvent object given as parameter

 @param tuneEvent The event object you add attributes to.
 @param parameters The dictionary of parameters given through the GTM callback
 @return The event object with the correct attributes set to the correct values
 */
-(TuneEvent *)getEvent:(TuneEvent *)tuneEvent WithNumberParameters:(NSDictionary *)parameters {
    if ([parameters objectForKey:EVENT_RATING]) {
        int rating = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_RATING] withDefault:-1];
        if (rating != -1) {
            tuneEvent.rating = rating;
            [self.logger logParamSetWithSuccess:EVENT_RATING withValue:[NSNumber numberWithInt:rating]];
        }
        else
            [self.logger logUncastableParam:EVENT_RATING toType:@"NSInteger"];
    }
    if ([parameters objectForKey:EVENT_REVENUE]) {
        float revenue = [CARUtils castToFloat:[parameters valueForKey:EVENT_REVENUE] withDefault:-1];
        if (revenue != -1) {
            tuneEvent.revenue = revenue;
            [self.logger logParamSetWithSuccess:EVENT_REVENUE withValue:[NSNumber numberWithFloat:revenue]];
        }
        else {
            [self.logger logUncastableParam:EVENT_REVENUE toType:@"float"];
        }
    }
    if ([parameters objectForKey:EVENT_LEVEL]) {
        int level = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_LEVEL] withDefault:-1];
        if (level != -1) {
            tuneEvent.level = level;
            [self.logger logParamSetWithSuccess:EVENT_LEVEL withValue:[NSNumber numberWithInt:level]];
        }
        else {
            [self.logger logUncastableParam:EVENT_LEVEL toType:@"NSInteger"];
        }
    }
    if ([parameters objectForKey:EVENT_TRANSACTION_STATE]) {
        int transactionState = [CARUtils castToNSInteger:
                                [parameters valueForKey:EVENT_TRANSACTION_STATE] withDefault:-1];
        if (transactionState != -1) {
            tuneEvent.transactionState = transactionState;
            [self.logger logParamSetWithSuccess:EVENT_TRANSACTION_STATE
                                      withValue:[NSNumber numberWithInt:transactionState]];
        }
        else {
            [self.logger logUncastableParam:EVENT_TRANSACTION_STATE toType:@"NSInteger"];
        }
    }
    if ([parameters objectForKey:EVENT_QUANTITY]) {
        int qty = [CARUtils castToNSInteger:[parameters valueForKey:EVENT_QUANTITY] withDefault:-1];
        if (qty >= 0) {
            tuneEvent.quantity = (NSUInteger)qty;
            [self.logger logParamSetWithSuccess:EVENT_QUANTITY withValue:[NSNumber numberWithInt:qty]];
        }
        else {
            [self.logger logUncastableParam:EVENT_QUANTITY toType:@"NSUInteger"];
        }
    }

    return tuneEvent;
}

/**
 Adds the correct properties with mixed types to the TuneEvent object given as parameter
 
 @param tuneEvent The event object you add attributes to.
 @param parameters The dictionary of parameters given through the GTM callback
 @return The event object with the correct attributes set to the correct values
 */
-(TuneEvent *)getEvent:(TuneEvent *)tuneEvent WithComplexParameters:(NSDictionary *)parameters {
    if ([parameters objectForKey:EVENT_DATE1]) {
        NSDate *date1 = [CARUtils castToNSDate:[parameters valueForKey:EVENT_DATE1]];
        if (date1) {
            tuneEvent.date1 = date1;
            [self.logger logParamSetWithSuccess:EVENT_DATE1 withValue:tuneEvent.date1];
            
            if ([parameters objectForKey:EVENT_DATE2]) {
                NSDate *date2 = [CARUtils castToNSDate:[parameters valueForKey:EVENT_DATE2]];
                if (date2) {
                    tuneEvent.date2 = date2;
                    [self.logger logParamSetWithSuccess:EVENT_DATE2 withValue:tuneEvent.date2];
                }
                else {
                    [self.logger logUncastableParam:EVENT_DATE2 toType:@"NSDate"];
                }
            }
        }
        else {
            [self.logger logUncastableParam:EVENT_DATE1 toType:@"NSDate"];
        }
    }
    if ([parameters objectForKey:EVENT_ITEMS]) {
        NSString *itemsString = [CARUtils castToNSString:[parameters valueForKey:EVENT_ITEMS]];
        if (itemsString) {
            NSArray *itemArray = [self getItems:itemsString];
            tuneEvent.eventItems = itemArray;
            [self.logger logParamSetWithSuccess:EVENT_ITEMS withValue:tuneEvent.eventItems];
        }
        else {
            [self.logger logUncastableParam:EVENT_ITEMS toType:@"NSArray"];
        }
    }
    if ([parameters objectForKey:EVENT_RECEIPT]) {
        NSData *receipt = [CARUtils castToNSData:[parameters valueForKey:EVENT_RECEIPT]];
        if (receipt) {
            tuneEvent.receipt = receipt;
            [self.logger logParamSetWithSuccess:EVENT_RECEIPT withValue:receipt];
        }
        else {
            [self.logger logUncastableParam:EVENT_RECEIPT toType:@"NSData"];
        }
    }

    return tuneEvent;
}

/**
 Helper which sets the tune gender for an user, from a NSString to the right TuneGender type

 @param gender the user gender, as MALE, FEMALE. Any other input will be changed to UNKNOWN
 */
-(void) setGender:(NSString*) gender{
    NSString *upperGender = [gender uppercaseString];

    if ([upperGender isEqualToString:@"MALE"]) {
        [self.tuneClass setGender:TuneGenderMale];
        [self.logger logParamSetWithSuccess:USER_GENDER withValue:@"MALE"];
    }
    else if ([upperGender isEqualToString:@"FEMALE"]) {
        [self.tuneClass setGender:TuneGenderFemale];
        [self.logger logParamSetWithSuccess:USER_GENDER withValue:@"FEMALE"];
    }
    else {
        [self.tuneClass setGender:TuneGenderUnknown];
        [self.logger logParamSetWithSuccess:USER_GENDER withValue:@"UNKNOWN"];
    }
}

-(NSArray *) getItems:(NSString *)itemsString {
    NSError *jsonError;
    NSData *jsonData = [itemsString dataUsingEncoding: NSUTF8StringEncoding];

    if (jsonData) {
        NSArray *arrayItems = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error: &jsonError];
        if (!jsonError) {

            NSMutableArray *tuneEventItems = [[NSMutableArray alloc] init];
            for (NSDictionary* item in arrayItems) {
                NSString *itemName = [CARUtils castToNSString:[item objectForKey:@"name"]];
                float unitPrice = [CARUtils castToFloat:[item objectForKey:@"unitPrice"] withDefault:0.0f];
                unsigned int quantity = [CARUtils castToNSInteger:[item objectForKey:@"quantity"] withDefault:0];
                float revenue = [CARUtils castToFloat:[item objectForKey:@"revenue"] withDefault:0];

                if (itemName && unitPrice > 0.0f && quantity && revenue > 0.0f) {
                    TuneEventItem *temp = [TuneEventItem eventItemWithName:itemName unitPrice:unitPrice quantity:quantity revenue:revenue];
                    if ([item objectForKey:@"attribute1"]) {
                        temp.attribute1 = [CARUtils castToNSString:[item objectForKey:@"attribute1"]];
                    }
                    if ([item objectForKey:@"attribute2"]) {
                        temp.attribute2 = [CARUtils castToNSString:[item objectForKey:@"attribute2"]];
                    }
                    if ([item objectForKey:@"attribute3"]) {
                        temp.attribute3 = [CARUtils castToNSString:[item objectForKey:@"attribute3"]];
                    }
                    if ([item objectForKey:@"attribute4"]) {
                        temp.attribute4 = [CARUtils castToNSString:[item objectForKey:@"attribute4"]];
                    }
                    if ([item objectForKey:@"attribute5"]) {
                        temp.attribute5 = [CARUtils castToNSString:[item objectForKey:@"attribute5"]];
                    }

                    [tuneEventItems addObject:temp];
                }
                else {
                    [self.logger logUncastableParam:@"eventItems" toType:@"TuneEventItems"];
                    return nil;
                }
            }
            return tuneEventItems;
        }
    }
    else {
        [self.logger logUncastableParam:@"eventItems" toType:@"TuneEventItems"];
    }
    return nil;
}

@end

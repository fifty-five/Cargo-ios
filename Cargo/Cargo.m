//
//  FIFTagHandler.m
//  FIFTagHandler
//
//  Created by Med on 05/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "Cargo.h"
#import "CARTagHandler.h"
#import "CARMacroHandler.h"

//GTM
#import "TAGManager.h"
#import "TAGDataLayer.h"


@implementation Cargo
@synthesize logger;

// THE Cargo instance
static Cargo * _sharedHelper;
// Dictionaries storing the instances of Tag/Macro handlers
static NSMutableDictionary * registeredTagHandlers;
static NSMutableDictionary * registeredMacroHandlers;


#pragma mark - SharedInstance

// Allow the user to retrieve a cargo instance
// If Cargo hasn't been init until now, creates and returns a fresh cargo instance
// If Cargo is already init, returns the instance stocked in _sharedHelper var
+ (Cargo *) sharedHelper {
    
    if (_sharedHelper) {
        return _sharedHelper;
    }
    
    _sharedHelper = [[Cargo alloc] init];
    return _sharedHelper;
}

// Returns a fresh initialized Cargo instance after started its logger
-(id)init {
    if (self = [super init]) {
        logger = [[FIFLogger alloc] initLogger:@"Cargo"];
        self.launchOptionsFlag = false;
    }
    
    return self;
}



#pragma mark - GTM
// Setup the tagManager and the GTM container
// Setup the log level of cargo after the level of the tagManager
- (void)initTagHandlerWithManager:(TAGManager *)tagManager
                        container:(TAGContainer *)container {
    //GTM
    self.tagManager = tagManager;
    self.container = container;
    
    //Logger
    [self.logger setLevel:[self.tagManager.logger logLevel]];
}




-(void) setLaunchOptions:(NSDictionary *)l{
    _launchOptions = l;
    _launchOptionsFlag = true;
}



// Returns true or false according the options flag is set or not
-(BOOL) isLaunchOptionsSet{
    return self.launchOptionsFlag;
}



// For each handler stored in the registeredTagHandlers variable,
// validate the handler in order to register its GTM callback methods
// does the same with the GTM callback macros
-(void) registerHandlers{
    for (NSString* key in registeredTagHandlers) {
        
        CARTagHandler *handler = registeredTagHandlers[key];
        [handler validate];
        
        if(handler.valid){
            [self.container registerFunctionCallTagHandler:handler forTag:key];
        }
        
        NSLog(@"Handler with key %@ has been registered", key );
    }
    
    // For all macro handlers registered
    for(NSString* key in registeredMacroHandlers ){
        CARMacroHandler *macroHandler = registeredMacroHandlers[key];
        [self.container registerFunctionCallMacroHandler:macroHandler forMacro:key];
        NSLog(@"Macro %@ has been registered", key);
    }
}



// Called by each handler (in its +load method) to register itself
// in the registeredTagHandlers variable, which is initialized if it wasn't already
+ (void) registerTagHandler:(CARTagHandler*)handler withKey:(NSString*) key {
    if(registeredTagHandlers == NULL){
        registeredTagHandlers = [[NSMutableDictionary alloc] init];
    }
    
    [registeredTagHandlers setValue:handler forKey:key];
}



// Called by each macro handler (in its +load method) to register itself
// in the registeredMacroHandlers variable, which is initialized if it wasn't already
+ (void) registerMacroHandler:(CARMacroHandler*)handler forMacro:(NSString*) macro {
    if(registeredMacroHandlers == NULL){
        registeredMacroHandlers = [[NSMutableDictionary alloc] init];
    }
    
    [registeredMacroHandlers setValue:handler forKey:macro];
}

@end

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

static Cargo * _sharedHelper;
static NSMutableDictionary * _registeredTagHandlers;
static NSMutableDictionary * _registeredMacroHandlers;



#pragma mark - SharedInstance
+ (Cargo *) sharedHelper {
    
    if (_sharedHelper) {
        return _sharedHelper;
    }
    
    _sharedHelper = [[Cargo alloc] init];
    return _sharedHelper;
}


-(id)init {
    if (self = [super init]) {
        logger = [[FIFLogger alloc] initLogger:@"Cargo"];
        self.launchOptionsFlag = false;
    }
    
    return self;
}


#pragma mark - GTM
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

-(BOOL) isLaunchOptionsSet{
    return self.launchOptionsFlag;
}






-(void) registerHandlers{
    for (NSString* key in _registeredTagHandlers) {
        
        CARTagHandler *handler = _registeredTagHandlers[key];
        [handler validate];
        
        if(handler.valid){
            [self.container registerFunctionCallTagHandler:handler forTag:key];
        }

        
        NSLog(@"Handler with key %@ has been registered", key );
    }
    
    // For all macro handlers registered
    for(NSString* key in _registeredMacroHandlers ){
        CARMacroHandler *macroHandler = _registeredMacroHandlers[key];
        [self.container registerFunctionCallMacroHandler:macroHandler forMacro:key];
        NSLog(@"Macro %@ has been registered", key);
    }
    
}

+ (void) registerTagHandler:(CARTagHandler*)handler withKey:(NSString*) key {
    if(_registeredTagHandlers == NULL){
        _registeredTagHandlers = [[NSMutableDictionary alloc] init];
    }
    
    [_registeredTagHandlers setValue:handler forKey:key];
}

+ (void) registerMacroHandler:(CARMacroHandler*)handler forMacro:(NSString*) macro {
    if(_registeredMacroHandlers == NULL){
        _registeredMacroHandlers = [[NSMutableDictionary alloc] init];
    }
    
    [_registeredMacroHandlers setValue:handler forKey:macro];
}


@end

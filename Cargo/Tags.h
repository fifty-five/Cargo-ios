//
//  Tags.h
//  Cargo
//
//  Created by Julien Gil on 25/01/2017.
//  Copyright © 2017 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleTagManager/TAGCustomFunction.h>

@interface Tags : NSObject<TAGCustomFunction>

/**
 Method which is called by GTM when a tag calling a custom function is triggered.
 Looks for the 'handlerMethod' parameter and calls on Cargo method with
 the name of the handler to call on, its method, and the parameters associated to the event.
 
 @param parameters The parameters which should contain the 'handlerMethod' key.
 @return nil
 */
- (NSObject*)executeWithParameters:(NSDictionary*)parameters;

@end

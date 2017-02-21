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

- (NSObject*)executeWithParameters:(NSDictionary*)parameters;

@end

//
//  CARFirebaseTagHandler.h
//  Cargo
//
//  Created by Med on 19/07/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase.h>
#import "CARTagHandler.h"

/**
 The class which handles interactions with the Firebase SDK.
 */
@interface CARFirebaseTagHandler : CARTagHandler

/** The firebase tracker */
@property Class fireAnalyticsClass;
/** The Firebase configurator helper */
@property Class fireConfClass;

@end

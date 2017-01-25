//
//  CARMobileAppTrackingTagHandler.h
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CARTagHandler.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CARConstants.h"

/**
 The class which handles interactions with the Facebook SDK.
 */
@interface CARFacebookTagHandler : CARTagHandler

/** The facebook tracker */
@property Class fbAppEvents;

@end

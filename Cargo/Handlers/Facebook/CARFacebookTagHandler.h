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


@interface CARFacebookTagHandler : CARTagHandler

@property Class fbAppEvents;

@end

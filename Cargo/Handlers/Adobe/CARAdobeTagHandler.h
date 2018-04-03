//
//  CARAdobeTagHandler.h
//  Cargo
//
//  Created by Julien Gil on 21/03/2018.
//  Copyright © 2018 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CARTagHandler.h"
#import "CargoLocation.h"
#import <UIKit/UIKit.h>
#import <ADBMobile.h>

@interface CARAdobeTagHandler : CARTagHandler

/** The Adobe tracker **/
@property Class adobe;

@end

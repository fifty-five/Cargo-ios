//
//  CARTuneTagHandler.h
//  Cargo
//
//  Created by louis chavane on 08/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CARTagHandler.h"
#import <Tune/Tune.h>


/**
 The class which handles interactions with the Accengage SDK.
 */
@interface CARTuneTagHandler : CARTagHandler

/** The Tune tracker */
@property Class tuneClass;

@end

//
//  CARAccengageTagHandler.h
//  Cargo
//
//  Created by Julien Gil on 07/10/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARTagHandler.h"
#import "AccengageItem.h"
#import "CARConstants.h"
#import <Accengage/Accengage.h>

/**
 *  The class which handles all the interactions and event calls with the Accengage SDK.
 */
@interface CARAccengageTagHandler : CARTagHandler

/** The Accengage tracker */
@property Class tracker;
/** Cargo instance */
@property Cargo* cargo;

@end

//
//  GAFunctionCallTagHandler_v3.0.h
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "CARTagHandler.h"
#import <UIKit/UIKit.h>
#import <ATInternet.h>
#import <ATScreen.h>
#import <ATGesture.h>
#import <ATCustomObject.h>



/**
 The class which handles interactions with the AT Internet SDK.
 */
@interface CARATInternetTagHandler : CARTagHandler

/** AT Internet tracker */
@property ATTracker * tracker;
/** AT Internet instance */
@property ATInternet * instance;


@end

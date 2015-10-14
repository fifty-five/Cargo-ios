//
//  GAFunctionCallTagHandler_v3.0.h
//  FIFTagHandler
//
//  Created by Med on 03/06/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "CARTagHandler.h"
#import "ATInternet.h"



/**
 *  The class handle all interaction and event calls shipped to Google Analytics.
 */
@interface CARATInternetTagHandler : CARTagHandler

@property ATTracker * tracker;
@property ATInternet * instance;


@end

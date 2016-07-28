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

@interface CARFirebaseTagHandler : CARTagHandler

@property Class fireAnalyticsClass;
@property Class fireConfClass;

@end

//
//  FAAdapter.h
//  FIFTagHandler
//
//  Created by Med on 22/08/14.
//  Copyright (c) 2014 fifty-five. All rights reserved.
//

#import "CARAdapter.h"


#if GA_v3_10_0


/**
 *  This class represents a Google
 *  Analytics adapter.
 */
@interface CARGoogleAnalyticsAdapter : CARAdapter


#pragma mark - GA tracker properties
@property (nonatomic, strong) id optOut;
@property (nonatomic, strong) id allowIDFACollection;
@property (nonatomic, strong) id dispatchInterval;
@property (nonatomic, strong) id trackUncaughtExceptions;
@property (nonatomic, strong) id dryRun;



@end
#endif
//
//  CargoLocation.h
//  Cargo
//
//  Created by Julien Gil on 22/03/2018.
//  Copyright © 2018 55 SAS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CargoLocation : NSObject

+ (void)setLocation:(CLLocation *)location;

+ (CLLocation *)getLocation;

@end

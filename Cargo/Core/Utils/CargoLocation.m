//
//  CargoLocation.m
//  Cargo
//
//  Created by Julien Gil on 22/03/2018.
//  Copyright © 2018 55 SAS. All rights reserved.
//

#import "CargoLocation.h"

@implementation CargoLocation

static CLLocation* location = nil;

+ (void)setLocation:(CLLocation *)newLocation{
    location = newLocation;
}

+ (CLLocation *)getLocation{
    return location;
}

@end

//
//  CARFirebaseTagHandler.m
//  Cargo
//
//  Created by Med on 19/07/16.
//  Copyright © 2016 55 SAS. All rights reserved.
//

#import "CARFirebaseTagHandler.h"

@implementation CARFirebaseTagHandler


// The runtime sends the load message very soon after the class object
// is loaded in the process's address space. (http://stackoverflow.com/a/13326633)
//
// Instanciate the handler, and register its callback methods to GTM through a Cargo method
+(void)load{
    CARFirebaseTagHandler *handler = [[CARFirebaseTagHandler alloc] init];
    [Cargo registerTagHandler:handler withKey:@"Firebase_init"];
    [Cargo registerTagHandler:handler withKey:@"Firebase_tagEvent"];
    [Cargo registerTagHandler:handler withKey:@"Firebase_tagScreen"];
    [Cargo registerTagHandler:handler withKey:@"Firebase_identify"];
    [FIRApp configure];
}


@end

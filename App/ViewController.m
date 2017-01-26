//
//  ViewController.m
//  App
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "ViewController.h"
#import "Cargo.h"
#import "CARItem.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Cargo *cargo = [Cargo sharedHelper];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tagEventPressed{
    [FIRAnalytics logEventWithName:@"tagEvent" parameters:nil];
}

- (IBAction)tagScreenPressed{
    [FIRAnalytics logEventWithName:@"tagScreen" parameters:nil];
}

- (IBAction)tagPurchasePressed{
    [FIRAnalytics logEventWithName:@"tagPurchase" parameters:nil];

}

- (IBAction)tagUserPressed{
    [FIRAnalytics logEventWithName:@"tagUser" parameters:nil];
}

@end

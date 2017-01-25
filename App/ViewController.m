//
//  ViewController.m
//  App
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "ViewController.h"
#import "Cargo.h"
#import "TAGManager.h"
#import "TAGDataLayer.h"
#import "CARItem.h"

@interface ViewController ()

@end

@implementation ViewController

TAGDataLayer *dataLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Cargo *cargo = [Cargo sharedHelper];
    dataLayer = cargo.tagManager.dataLayer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tagEventPressed{
    NSArray* itemArray = [[NSArray alloc]
                          initWithObjects:
                          [[CARItem alloc] initWithName:@"testItem" andUnitPrice:15.5f andQuantity:100],
                          [[CARItem alloc] initWithName:@"testItem2" andUnitPrice:20.55f andQuantity:1],
                          nil];
    
    [dataLayer push:@{@"event": @"tagEvent",
                      @"eventItems": [CARItem toGTM:itemArray],
                      @"eventDate1": [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]
                      }];
}

- (IBAction)tagScreenPressed{
    [dataLayer push:@{@"event": @"tagScreen"}];
}

- (IBAction)tagPurchasePressed{
    [dataLayer push:@{@"event": @"tagPurchase"}];
}

- (IBAction)tagUserPressed{
    [dataLayer push:@{@"event": @"tagUser"}];
}

@end

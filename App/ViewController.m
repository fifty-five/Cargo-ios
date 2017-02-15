//
//  ViewController.m
//  App
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import "ViewController.h"
#import "Cargo.h"
#import "CargoItem.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize userNameText;
@synthesize userMailText;

@synthesize xboxText;
@synthesize playText;
@synthesize nintendoText;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    float revenue = 0;
    [parameters setObject:@"EUR" forKey:@"currencyCode"];
    if (xboxText.text.doubleValue) {
        CargoItem *item = [[CargoItem alloc] initWithName:@"xBox One" andUnitPrice:149.99 andQuantity:(unsigned int)xboxText.text.doubleValue];
        [[Cargo sharedHelper] attachItemToEvent:item];
        revenue += (item.revenue);
    }
    if (playText.text.doubleValue) {
        CargoItem *item = [[CargoItem alloc] initWithName:@"Playstation 4" andUnitPrice:260 andQuantity:(unsigned int)playText.text.doubleValue];
        [[Cargo sharedHelper] attachItemToEvent:item];
        revenue += (item.revenue);
    }
    if (nintendoText.text.doubleValue) {
        CargoItem *item = [[CargoItem alloc] initWithName:@"Nintendo Switch" andUnitPrice:350.50 andQuantity:(unsigned int)nintendoText.text.doubleValue];
        [[Cargo sharedHelper] attachItemToEvent:item];
        revenue += (item.revenue);
    }
    [parameters setObject:[NSNumber numberWithFloat:revenue] forKey:@"totalRevenue"];
    [parameters setObject:[[Cargo sharedHelper] itemsArray] forKey:@"eventItems"];
    [FIRAnalytics logEventWithName:@"tagPurchase" parameters:parameters];

}

- (IBAction)tagUserPressed{
    [FIRAnalytics logEventWithName:@"tagUser" parameters:nil];
}

@end

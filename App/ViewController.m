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
#import "CargoLocation.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize scrollView;

@synthesize userNameText;
@synthesize userMailText;

@synthesize screenAndEventText;

@synthesize xboxText;
@synthesize playText;
@synthesize nintendoText;

@synthesize SwitchLocation;
@synthesize segmentedPrivacyStatus;

CLLocationManager* locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"shopAction" forKey:@"actionName"];
    [FIRAnalytics logEventWithName:@"ADB_trackTimeStart" parameters:parameters];
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
}

- (void)viewDidUnload {
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"shopAction" forKey:@"actionName"];
    [parameters setObject:@"FALSE" forKey:@"successfulAction"];
    [FIRAnalytics logEventWithName:@"ADB_trackTimeEnd" parameters:parameters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tagEventPressed{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:screenAndEventText.text forKey:@"eventName"];
    [FIRAnalytics logEventWithName:@"tagEvent" parameters:parameters];

    if (SwitchLocation.isOn) {
        [FIRAnalytics logEventWithName:@"tagLocation" parameters:nil];
    }
}

- (IBAction)tagScreenPressed{
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:screenAndEventText.text forKey:@"screenName"];
    [FIRAnalytics logEventWithName:@"tagScreen" parameters:parameters];

    if (SwitchLocation.isOn) {
        [FIRAnalytics logEventWithName:@"tagLocation" parameters:nil];
    }
}

- (IBAction)tagPurchasePressed{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    float revenue = 0;

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
    [parameters setObject:@"USD" forKey:@"currencyCode"];
    [parameters setObject:[NSNumber numberWithFloat:revenue] forKey:@"totalRevenue"];
    [parameters setObject:[NSNumber numberWithBool:true] forKey:@"eventItems"];
    [FIRAnalytics logEventWithName:@"tagPurchase" parameters:parameters];

    if (SwitchLocation.isOn) {
        [FIRAnalytics logEventWithName:@"tagLocation" parameters:nil];
    }

    if (revenue > 0) {
        [parameters setObject:@"shopAction" forKey:@"actionName"];
        [parameters setObject:@"TRUE" forKey:@"successfulAction"];
        [FIRAnalytics logEventWithName:@"ADB_trackTimeEnd" parameters:parameters];
        [FIRAnalytics logEventWithName:@"ADB_trackTimeStart" parameters:parameters];
    }
}

- (IBAction)tagUserPressed{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:userNameText.text forKey:@"userName"];
    [parameters setObject:userMailText.text forKey:@"userEmail"];
    [FIRAnalytics logEventWithName:@"tagUser" parameters:parameters];
}

- (IBAction)switchLocationValueChanged:(UISwitch *)sender {
    if (SwitchLocation.isOn) {
        [locationManager startUpdatingLocation];
    }
    else {
        [locationManager stopUpdatingLocation];
        [CargoLocation setLocation:nil];
    }
}

- (IBAction)segmentedControlPrivacyValueChanged:(UISegmentedControl *)sender {
    NSMutableString* privacyStatus = [[NSMutableString alloc] init];
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    if (segmentedPrivacyStatus.selectedSegmentIndex == 0) {
        privacyStatus = [NSMutableString stringWithString:@"OPT_IN"];
    }
    else if (segmentedPrivacyStatus.selectedSegmentIndex == 1) {
        privacyStatus = [NSMutableString stringWithString:@"OPT_OUT"];
    }
    else {
        privacyStatus = [NSMutableString stringWithString:@"UNKNOWN"];
    }
    [parameters setObject:privacyStatus forKey:@"privacyStatus"];
    [FIRAnalytics logEventWithName:@"setPrivacy" parameters:parameters];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* location = [locationManager location];
    if (location) {
        [CargoLocation setLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to find user's location : %@", error);
}

- (IBAction)clickOnView:(id)sender {
    [self dismissKeyboard];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField { CGPoint scrollPoint = CGPointMake(0, textField.frame.origin.y/2);
    [scrollView setContentOffset:scrollPoint animated:YES];
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    [scrollView setContentOffset:CGPointZero animated:YES];
}

-(void) dismissKeyboard {
    [userNameText resignFirstResponder];
    [userMailText resignFirstResponder];
    [screenAndEventText resignFirstResponder];
    [playText resignFirstResponder];
    [nintendoText resignFirstResponder];
    [xboxText resignFirstResponder];
}

@end

//
//  ViewController.h
//  App
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@import Firebase;

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *userNameText;
@property (strong, nonatomic) IBOutlet UITextField *userMailText;

@property (weak, nonatomic) IBOutlet UITextField *screenAndEventText;

@property (strong, nonatomic) IBOutlet UITextField *xboxText;
@property (strong, nonatomic) IBOutlet UITextField *playText;
@property (strong, nonatomic) IBOutlet UITextField *nintendoText;

@property (weak, nonatomic) IBOutlet UISwitch *SwitchLocation;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedPrivacyStatus;

- (IBAction)tagEventPressed;
- (IBAction)tagScreenPressed;
- (IBAction)tagPurchasePressed;
- (IBAction)tagUserPressed;

- (IBAction)switchLocationValueChanged:(UISwitch *)sender;
- (IBAction)segmentedControlPrivacyValueChanged:(UISegmentedControl *)sender;

@end


//
//  ViewController.h
//  App
//
//  Created by louis chavane on 07/10/15.
//  Copyright © 2015 55 SAS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *userNameText;
@property (strong, nonatomic) IBOutlet UITextField *userMailText;

@property (strong, nonatomic) IBOutlet UITextField *xboxText;
@property (strong, nonatomic) IBOutlet UITextField *playText;
@property (strong, nonatomic) IBOutlet UITextField *nintendoText;

- (IBAction)tagEventPressed;
- (IBAction)tagScreenPressed;
- (IBAction)tagPurchasePressed;
- (IBAction)tagUserPressed;

@end


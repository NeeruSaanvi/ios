//
//  SignUpViewController.h
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
@property (strong, nonatomic)  UIImage *imgAvtar;
@property (weak, nonatomic) IBOutlet UIButton *cmdPrivacypolicy;
@property (weak, nonatomic) IBOutlet UIView *viewtxtFullName;
@property (weak, nonatomic) IBOutlet UITextField *txtFullName;
@property (weak, nonatomic) IBOutlet UIView *viewtxtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIView *viewTxtPhoneNo;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNo;
@property (weak, nonatomic) IBOutlet UIView *viewTxtMonth;
@property (weak, nonatomic) IBOutlet UIView *viewtxtDay;
@property (weak, nonatomic) IBOutlet UITextField *txtMonth;
@property (weak, nonatomic) IBOutlet UIView *viewTxtYear;
@property (weak, nonatomic) IBOutlet UITextField *txtYear;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)cmdNext:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)cmdLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacyPolicy;
- (IBAction)cmdPrivacyPolicy:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
- (IBAction)cmdMale:(id)sender;
- (IBAction)cmdFemale:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;
@property (weak, nonatomic) IBOutlet UITextField *txtDay;

@end

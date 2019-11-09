//
//  LoginViewController.h
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewtxtLogin;
@property (weak, nonatomic) IBOutlet UIView *viewTxtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnForgotPassword;
- (IBAction)cmdForgotPassword:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)cmdLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
- (IBAction)cmdSignUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacyPolicy;
- (IBAction)cmdPrivacyPolicy:(id)sender;

@end

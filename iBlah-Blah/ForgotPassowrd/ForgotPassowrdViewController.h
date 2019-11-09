//
//  ForgotPassowrdViewController.h
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivacyPolicyViewController.h"
@interface ForgotPassowrdViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)cmdSend:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
- (IBAction)cmdPrivacyPolicy:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacyPolicy;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)cmdLogin:(id)sender;

@end

//
//  OTPViewController.h
//  iBlah-Blah
//
//  Created by webHex on 08/09/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivationCodeTextField.h"
@interface OTPViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet ActivationCodeTextField *txtOTP;
- (IBAction)cmdLogin:(id)sender;
- (IBAction)cmdResendOTP:(id)sender;
- (IBAction)cmdBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) NSDictionary *dictData;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneNumber;
@end

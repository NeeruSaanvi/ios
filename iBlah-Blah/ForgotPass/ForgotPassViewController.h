//
//  ForgotPassViewController.h
//  iBlah-Blah
//
//  Created by webHex on 10/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPassViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
- (IBAction)btnSubmit:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *submit;

@end

//
//  NumberVerificationViewController.h
//  iBlah-Blah
//
//  Created by webHex on 08/09/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryListViewController.h"

@interface NumberVerificationViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMobleNo;
- (IBAction)cmdSignUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
- (IBAction)cmdSelectCountry:(id)sender;
- (IBAction)cmdSkipVerfication:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCountry;
@end

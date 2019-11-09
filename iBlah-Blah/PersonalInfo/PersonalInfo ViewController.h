//
//  PersonalInfo ViewController.h
//  iBlah-Blah
//
//  Created by webHex on 10/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfo_ViewController : BaseViewController
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
@property (weak, nonatomic) IBOutlet UITextField *txtDay;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;

@end

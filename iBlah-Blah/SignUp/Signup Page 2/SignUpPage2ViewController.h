//
//  SignUpPage2ViewController.h
//  iBlah-Blah
//
//  Created by Arun on 20/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpPage2ViewController : UIViewController
@property (strong, nonatomic) NSString *strfullName;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strMobNum;
@property (strong, nonatomic) NSString *strMonth;
@property (strong, nonatomic) NSString *strDay;
@property (strong, nonatomic) NSString *strYear;
@property (strong, nonatomic)  UIImage *imgAvtar;
@property (strong, nonatomic)  NSString *strGender;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewtxtCountry;
@property (weak, nonatomic) IBOutlet UITextField *txtCountry;
@property (weak, nonatomic) IBOutlet UIView *viewtxtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UIView *viewtxtState;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UIView *viewtxtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *viewtxtConfrimPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfrimPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnTermandCondition;
- (IBAction)cmdTermandCondition:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
- (IBAction)cmdSignUp:(id)sender;
- (IBAction)cmdLogin:(id)sender;
- (IBAction)cmdPrivacyPolicy:(id)sender;

@end

//
//  OTPViewController.m
//  iBlah-Blah
//
//  Created by webHex on 08/09/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "OTPViewController.h"
#import "HomeViewController.h"


@interface OTPViewController (){
    BOOL doneCancleKeyBoard;
    IndecatorView *ind;
}

@end

@implementation OTPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _lblPhoneNumber.text=[_dictData objectForKey:@"mobile"];
    _txtOTP.maxCodeLength = 6;
    _txtOTP.customPlaceholder = @"_";
    _txtOTP.delegate = self;
    [_txtOTP setTextColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resignKeyBoard];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtOTP.inputAccessoryView = numberToolbar;
    // self.btnLogin.layer.cornerRadius=4;
    ind=[[IndecatorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.txtOTP resignFirstResponder];
}


- (IBAction)cmdLogin:(id)sender {
    [self resignKeyBoard];
    _btnLogin.userInteractionEnabled=NO;
    NSString *strOTP=self.txtOTP.text;
    strOTP=[strOTP stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strOTP.length<=0){
        [AlertView showAlertWithMessage:@"Please enter valid otp." view:self];
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *verificationID = [defaults objectForKey:@"authVerificationID"];
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    FIRAuthCredential *credential = [[FIRPhoneAuthProvider provider]
                                     credentialWithVerificationID:verificationID
                                     verificationCode:strOTP];
    
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRUser *user, NSError *error) {
                                  if (error) {
                                      // ...
                                      [ind removeFromSuperview];
                                      _btnLogin.userInteractionEnabled=YES;
                                      [AlertView showAlertWithMessage:@"OTP expire, please try using resend OTP" view:self];
                                      return;
                                  }
                                  // User successfully signed in. Get user data from the FIRUser object
                                  // ...
                                  _btnLogin.userInteractionEnabled=YES;
                                  [ind removeFromSuperview];
                                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                  NSString *USERID = [prefs stringForKey:@"USERID"];
                                  NSString *StrMoble=[self.dictData objectForKey:@"mobile"];
                                  NSString *countryCode= [prefs objectForKey:@"countryCode"];
                                  
                                  [appDelegate().socket emit:@"number_verified" with:@[USERID,countryCode,StrMoble]];
                                 self.sidePanelController.centerPanel =   [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];
                              }];
}

- (IBAction)cmdResendOTP:(id)sender {
    [self resignKeyBoard];
    [self sendMobileNum];
}

-(void)sendMobileNum{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *StrMoble=[self.dictData objectForKey:@"mobile"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *countryCode= [prefs objectForKey:@"countryCode"];
    [dict setObject:StrMoble forKey:@"mobile"];
    [self.view addSubview:ind];
    
    [[FIRPhoneAuthProvider provider] verifyPhoneNumber:[NSString stringWithFormat:@"%@%@",countryCode,StrMoble]
                                            UIDelegate:nil
                                            completion:^(NSString * _Nullable verificationID, NSError * _Nullable error) {
                                                // Dispatch asynchronously on the main thread as a temporary workaround to a known issue.
                                                dispatch_async(dispatch_get_main_queue(), ^() {
                                                    if (error) {
                                                        [ind removeFromSuperview];
                                                        [AlertView showAlertWithMessage:error.localizedDescription view:self];
                                                        //[self showMessagePrompt:error.localizedDescription];
                                                        return;
                                                    }
                                                    // Sign in using the verificationID and the code sent to the user.
                                                    // ...
                                                    [ind removeFromSuperview];
                                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                    [defaults setObject:verificationID forKey:@"authVerificationID"];
                                                    [AlertView showAlertWithMessage:@"Otp Sent successfully." view:self];
                                                });
                                            }];
}

- (IBAction)cmdBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    doneCancleKeyBoard=YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"textField:shouldChangeCharactersInRange:replacementString:");
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            [AlertView showAlertWithMessage:@"This field accepts only numeric entries." view:self];
            
            return NO;
        }
    }
    
//    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
//
//    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return YES;
    
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self resignKeyBoard];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark keyboardWillShow hide

-(void)cancelNumberPad{
    doneCancleKeyBoard=NO;
    self.txtOTP.text=@"";
    [self resignKeyBoard];
}
-(void)doneWithNumberPad{
    doneCancleKeyBoard=NO;
    [self resignKeyBoard];
}

- (void)keyboardWillShow:(NSNotification*)notification{
    // CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if(doneCancleKeyBoard){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
                         }else{
                             self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
-(void)resignKeyBoard{
    doneCancleKeyBoard=NO;
    [self.txtOTP resignFirstResponder];
}



@end

//
//  ForgotPassViewController.m
//  iBlah-Blah
//
//  Created by webHex on 10/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "ForgotPassViewController.h"
#import "LoginViewController.h"
#import "QBCore.h"

@interface ForgotPassViewController ()

@end

@implementation ForgotPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtNewPassword.inputAccessoryView = numberToolbar;
    self.txtOldPassword.inputAccessoryView = numberToolbar;
    self.txtConfirmPassword.inputAccessoryView = numberToolbar;
}
-(void)doneWithNumberPad{
    [self.view endEditing:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btnSubmit:(id)sender {
    NSString *oldPass=[_txtOldPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *newPassword=[_txtNewPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *confrimPass=[_txtConfirmPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(oldPass.length==0 || newPassword.length==0 || confrimPass.length==0){
        [AlertView showAlertWithMessage:@"All feild are mandatory." view:sender];
    
    }else if(!([_txtConfirmPassword.text isEqualToString:_txtNewPassword.text])){
         [AlertView showAlertWithMessage:@"Confirm Password did not match with new password." view:sender];
    }else{
        IndecatorView *ind=[[IndecatorView alloc]init];
        [self.view addSubview:ind];
        [[ApiClient sharedInstance]changePass:_txtOldPassword.text newPass:_txtNewPassword.text success:^(id responseObject) {
            [ind removeFromSuperview];
            _txtOldPassword.text=@"";
            _txtNewPassword.text=@"";
            _txtConfirmPassword.text=@"";
            [AlertView  showAlertWithMessage:@"Password reset successfully." view:self];
            [self resetDefaults];
            self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"LoginViewController"]];
        } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
            [ind removeFromSuperview];
            [AlertView  showAlertWithMessage:errorString view:self];
        }];
    }
}


- (void)resetDefaults {

    
    [Core logout];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

@end

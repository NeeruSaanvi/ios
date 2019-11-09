//
//  ForgotPassowrdViewController.m
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "ForgotPassowrdViewController.h"
#import "PrivacyPolicyViewController.h"
@interface ForgotPassowrdViewController ()

@end

@implementation ForgotPassowrdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _viewEmail.layer.cornerRadius=15;
    _viewEmail.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewEmail.layer.borderWidth=1;
    _btnSend.layer.cornerRadius=25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cmdSend:(id)sender {
    
    NSString *strEmail=[_txtEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strEmail.length<=0){
        [AlertView showAlertWithMessage:@"Please enter email" view:self];
    }else if(![self NSStringIsValidEmail:_txtEmail.text]){
        [AlertView showAlertWithMessage:@"Please enter valid email" view:self];
    }else {
        IndecatorView *ind=[[IndecatorView alloc]init];
        [self.view addSubview:ind];
        [[ApiClient sharedInstance]forgotPass:_txtEmail.text success:^(id responseObject) {
            [ind removeFromSuperview];
            [AlertView showAlertWithMessage:@"Please check your email to receive password." view:self];
        } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
            [ind removeFromSuperview];
            [AlertView showAlertWithMessage:errorString view:self];
        }];
    }
    
}
- (IBAction)cmdPrivacyPolicy:(id)sender {
    PrivacyPolicyViewController *cont=[[PrivacyPolicyViewController alloc]initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
- (IBAction)cmdLogin:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark Emailvalidation
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(_txtEmail==textField){
        [self.view endEditing:YES];
        [self retrunView];
    }
    return YES;
}
#pragma mark view Down
-(void)retrunView{
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self retrunView];
    [self.view endEditing:YES];
}

@end

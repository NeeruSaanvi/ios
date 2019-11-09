//
//  LoginViewController.m
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "ForgotPassowrdViewController.h"
#import "PrivacyPolicyViewController.h"
#import "AddImageViewController.h"
#import "HomeViewController.h"


#import "QBLoadingButton.h"
#import "UsersViewController.h"
#import "QBCore.h"
#import "SVProgressHUD.h"
#import "NumberVerificationViewController.h"
//NSString *const QB_DEFAULT_PASSOWORD = @"x6Bt0VDy5";
@interface LoginViewController ()<QBCoreDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _viewtxtLogin.layer.cornerRadius=15;//0,160,223
    _viewtxtLogin.layer.borderWidth=1;
    _viewTxtPassword.layer.cornerRadius=15;//0,160,223
    _viewtxtLogin.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtPassword.layer.borderWidth=1;
    _viewTxtPassword.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _btnLogin.layer.cornerRadius=25;
     self.navigationController.navigationBarHidden=YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cmdForgotPassword:(id)sender {
    ForgotPassowrdViewController *cont=[[ForgotPassowrdViewController alloc]initWithNibName:@"ForgotPassowrdViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}

- (IBAction)cmdLogin:(id)sender {
    
    [self retrunView];
    [self.view endEditing:YES];
    NSString *strEmail=[_txtEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *stPassword=[_txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strEmail.length<=0 || stPassword.length<=0){
        [AlertView showAlertWithMessage:@"Please enter email id and password" view:self];
    }else if(![self NSStringIsValidEmail:_txtEmail.text]){
        [AlertView showAlertWithMessage:@"Please enter valid email id" view:self];
    } else {
       
        
        
        IndecatorView *ind=[[IndecatorView alloc]init];
        [self.view addSubview:ind];
        [[ApiClient sharedInstance]getLogin:_txtEmail.text password:_txtPassword.text success:^(id responseObject) {
            [ind removeFromSuperview];

            NSDictionary *dict=responseObject;
            
            NSDictionary *dict1=[dict objectForKey:@"user_detail"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[dict1 objectForKey:@"user_id"] forKey:@"USERID"];
            [defaults setObject:[dict1 objectForKey:@"image"] forKey:@"profile_pic"];
            [defaults setObject:[dict1 objectForKey:@"name"] forKey:@"username"];
            [defaults setObject:[dict1 objectForKey:@"email"] forKey:@"Email"];//
            [defaults setObject:[dict1 objectForKey:@"is_contact_verified"] forKey:@"is_contact_verified"];
            [defaults synchronize];
            NSURL* url = [[NSURL alloc] initWithString:@"http://iblah-blah.com:4300"];
            appDelegate().manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO, @"compress": @NO}];
            appDelegate().socket = appDelegate().manager.defaultSocket;
            
            
            
            [appDelegate().socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
                NSLog(@"Socket connected");
            }];
            [[ApiClient sharedInstance]allAPIResponce];
            [[ApiClient sharedInstance]getAllPostResponce];
            [[ApiClient sharedInstance]uploadImageVideo];
           
            [appDelegate().socket connect];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *Email2 = [prefs stringForKey:@"Email"];
            [QBRequest usersWithEmails:@[Email2]
                                  page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                          successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                              
                              if(users.count>0){
                                  QBUUser *CurrentUser=[users objectAtIndex:0];
                                  [Core loginWithCurrentUser:CurrentUser];
//                                NSString *is_contact_verified = [prefs stringForKey:@"is_contact_verified"];
//                                  if([is_contact_verified isEqualToString:@"0"]){
//                                      NumberVerificationViewController *cont=[[NumberVerificationViewController alloc]initWithNibName:@"NumberVerificationViewController" bundle:nil];
//                                      [self.navigationController pushViewController:cont animated:YES];
//
//                                  }else{
//                                      self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
//                                  }
                                 
                                  
                              }else{
                                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                   NSString *username = [prefs stringForKey:@"username"];
                                  NSString *Email = [prefs stringForKey:@"Email"];
                                
                                  //
                                  
                                  [Core signUpWithFullName:username
                                                  roomName:Email];
//                                   NSString *is_contact_verified = [prefs stringForKey:@"is_contact_verified"];
//                                  if([is_contact_verified isEqualToString:@"0"]){
//                                      NumberVerificationViewController *cont=[[NumberVerificationViewController alloc]initWithNibName:@"NumberVerificationViewController" bundle:nil];
//                                      [self.navigationController pushViewController:cont animated:YES];
//                                  }else{
//                                       self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
//                                  }
                                  
                              }
                              
                          } errorBlock:^(QBResponse *response) {
                                  // Handle error
                               NSLog(@"responce Error %@",response);
                          }];
            
            
            NSString *is_contact_verified = [prefs stringForKey:@"is_contact_verified"];
            if([is_contact_verified isEqualToString:@"0"]){
                NumberVerificationViewController *cont=[[NumberVerificationViewController alloc]initWithNibName:@"NumberVerificationViewController" bundle:nil];
                [self.navigationController pushViewController:cont animated:YES];
            }else{
                self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];
            }
            
//               self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
            
        } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
            [ind removeFromSuperview];
            if(errorString == nil)
            {
                errorString = @"Please enter corrct username and password";
            }
            [AlertView showAlertWithMessage:errorString view:self];
        }];
    }
    
}
- (IBAction)cmdSignUp:(id)sender {
    AddImageViewController *cont=[[AddImageViewController alloc]initWithNibName:@"AddImageViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
- (IBAction)cmdPrivacyPolicy:(id)sender {
    PrivacyPolicyViewController *cont=[[PrivacyPolicyViewController alloc]initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
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

#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtEmail){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtPassword){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -40, self.view.frame.size.width, self.view.frame.size.height);
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
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
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(_txtEmail==textField){
        [_txtPassword becomeFirstResponder];
    }else if (_txtPassword==textField){
        [_btnLogin sendActionsForControlEvents:UIControlEventTouchUpInside];

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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _txtEmail.text=@"";
    _txtPassword.text=@"";
}
@end

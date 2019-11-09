    //
    //  SignUpPage2ViewController.m
    //  iBlah-Blah
    //
    //  Created by Arun on 20/03/18.
    //  Copyright © 2018 webHax. All rights reserved.
    //

#import "SignUpPage2ViewController.h"
#import "PrivacyPolicyViewController.h"
#import "HomeViewController.h"
@interface SignUpPage2ViewController ()

@end

@implementation SignUpPage2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
    [self addDesign];
    _txtCountry.text=appDelegate().Country;
    _txtCity.text=appDelegate().City;
    _txtState.text=appDelegate().State;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}



- (IBAction)cmdTermandCondition:(id)sender {
    UIImage *imgMale = [_btnTermandCondition imageForState:UIControlStateNormal];
    if(([self firstimage:[UIImage imageNamed:@"Checkbox_Tick"] isEqualTo:imgMale])){
        [_btnTermandCondition setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];
    }else if(([self firstimage:[UIImage imageNamed:@"Checkbox_Without Tick"] isEqualTo:imgMale])){
        [_btnTermandCondition setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];
    }
}
- (IBAction)cmdSignUp:(id)sender {
    UIImage *imgMale = [_btnTermandCondition imageForState:UIControlStateNormal];
    if(([self firstimage:[UIImage imageNamed:@"Checkbox_Without Tick"] isEqualTo:imgMale])){
        [AlertView showAlertWithMessage:@"Please check term and condition check box" view:self];
        return;
    }
    NSString *strPassword=[self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strConfirmPassword=[self.txtConfrimPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strPassword.length<=0 || strConfirmPassword.length<=0){
        [AlertView showAlertWithMessage:@"Please set your password" view:self];
    }else if(!([_txtConfrimPassword.text isEqualToString:_txtPassword.text])){
        [AlertView showAlertWithMessage:@"Password not matched." view:self];
    }else if(_txtPassword.text.length<6){
         [AlertView showAlertWithMessage:@"Password must be of 6 digit or greater." view:self];
    }else{
        
        
        IndecatorView *ind=[[IndecatorView alloc]init];
        [self.view addSubview:ind];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        NSString *url = [NSString stringWithFormat:@SIGNUP];
        url=[NSString stringWithFormat:@"%@action=iblahSignUp&email=%@&password=%@&name=%@",url,_strEmail,_txtPassword.text,_strfullName];
         url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.imgAvtar)];
        
        NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
                // [formData   appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoUrl] name:@"file" fileName:@"test" mimeType:@"mov"];
            [formData appendPartWithFileData:imageData name:@"image" fileName:@"image" mimeType:@"png"]; // you file to upload
                                                                                                        // [formData appendPartWithFileURL:self.videoUrl name:@"file" error:nil];
            /*appendPartWithFileURL   used if you want to upload large saved files and not data*/
            
        } error:nil];
            //    [upload_request setHTTPMethod:@"POST"];
            //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
            //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
        [upload_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [upload_request setHTTPShouldHandleCookies:NO];
            // [upload_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            // [upload_request setHTTPBody:postData];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            //  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        NSURLSessionUploadTask *uploadFileTask;
        uploadFileTask = [manager
                          uploadTaskWithStreamedRequest:upload_request
                          progress:^(NSProgress * _Nonnull uploadProgress) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                      //since the call back is not on main queue we get the main queue ourself
                                  NSLog(@"%f",uploadProgress.fractionCompleted);//Log the progress or pass it to progressview
                              });
                          }
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                               [ind removeFromSuperview];
                              if (error) {
                                  NSLog(@"OOPS!!!! %@", error);
//                                  [ind removeFromSuperview];

                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                              } else {
                                  NSLog(@"%@ %@", response, responseObject);
                                  
                                  NSError *error = nil;
                                  id jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                                  
                                  if (error != nil) {
                                      NSLog(@"Error parsing JSON.");
                                      [ind removeFromSuperview];
                                      [AlertView showAlertWithMessage:@"Please try Again" view:self];
                                  }
                                  else {
                                      if([jsonArray[@"code"] intValue] == 200)
                                      {

//                                          [ind removeFromSuperview];
                                          //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                          [AlertView showAlertWithMessage:@"You have successfully registered and Please login to app now." view:self];
                                          [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                                      }else{
                                          [AlertView showAlertWithMessage:jsonArray[@"status"] view:self];
                                      }

                                  }
                              }
                          }];
        
        [uploadFileTask resume];
    }
}

-(void)back{
     [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cmdLogin:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)cmdPrivacyPolicy:(id)sender {
    PrivacyPolicyViewController *cont=[[PrivacyPolicyViewController alloc]initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}

-(void)addDesign{
    
    _viewtxtCountry.layer.cornerRadius=15;//0,160,223
    _viewtxtCountry.layer.borderWidth=1;
    _viewtxtCountry.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtCountry.layer.cornerRadius=15;//0,160,223
    
    _viewtxtCity.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtCity.layer.borderWidth=1;
    _viewtxtCity.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtCity.layer.cornerRadius=15;//0,160,223
    
    _viewtxtState.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtState.layer.borderWidth=1;
    _viewtxtState.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtState.layer.cornerRadius=15;//0,160,223
    
    _viewtxtPassword.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtPassword.layer.borderWidth=1;
    _viewtxtPassword.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtPassword.layer.cornerRadius=15;//0,160,223
    
    _viewtxtConfrimPassword.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtConfrimPassword.layer.borderWidth=1;
    _viewtxtConfrimPassword.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtConfrimPassword.layer.cornerRadius=15;//0,160,223
    
    _btnSignup.layer.cornerRadius=25;
    
        // _scrollView.contentSize = CGSizeMake( SCREEN_SIZE.width, CGRectGetMaxY(_btnPrivacyPolicy.frame)+8);
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtCountry.inputAccessoryView = numberToolbar;
    self.txtCity.inputAccessoryView = numberToolbar;
    self.txtState.inputAccessoryView = numberToolbar;
    self.txtPassword.inputAccessoryView = numberToolbar;
    self.txtConfrimPassword.inputAccessoryView = numberToolbar;
}
-(void)doneWithNumberPad{
    [self retrunView];
    [self.view endEditing:YES];
    
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
    [self.view endEditing:YES];
}


#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtCountry){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtCity){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -40, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtState){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -70, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtPassword){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtConfrimPassword ){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -120, self.view.frame.size.width, self.view.frame.size.height);
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
        //
    if(_txtCountry==textField){
        [_txtCity becomeFirstResponder];
    }else if (_txtCity==textField){
        [_txtState becomeFirstResponder];
        
    }else if (_txtState==textField){
        [_txtPassword becomeFirstResponder];
        
    }else if (_txtPassword==textField){
        [_txtConfrimPassword becomeFirstResponder];
        
    }else if (_txtConfrimPassword==textField){
        [self retrunView];
    }
    
    return YES;
}
-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqualToData:data2];
    
}

@end

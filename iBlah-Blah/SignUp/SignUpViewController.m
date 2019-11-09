//
//  SignUpViewController.m
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "SignUpViewController.h"
#import "PrivacyPolicyViewController.h"
#import "SignUpPage2ViewController.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addDesign];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cmdNext:(id)sender {
     NSString *strfullName=[self.txtFullName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strEmail=[self.txtEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strMobNum=[self.txtPhoneNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strMonth=[self.txtMonth.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strDay=[self.txtDay.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strYear=[self.txtYear.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(strfullName.length<=0 ){
        [AlertView showAlertWithMessage:@"Please enter your name." view:self];
        return;
    }else if (strMobNum.length>10 || strMobNum.length<10){
         [AlertView showAlertWithMessage:@"Enter a 10-Digit Mobile Number." view:self];
        return;
    }else if(strMonth.length>2){
        [AlertView showAlertWithMessage:@"The month of a date must be from 1 to 12" view:self];
        return;
    }else if(strDay.length>2){
        [AlertView showAlertWithMessage:@"The day of a date must be from 1 to 31" view:self];
        return;
    }else if(strYear.length>4 || strYear.length<4){
        [AlertView showAlertWithMessage:@"Year should not exceed 4 digit or less then 4 digit" view:self];
        return;
    }else if(![self NSStringIsValidEmail:_txtEmail.text]){
        [AlertView showAlertWithMessage:@"Please enter valid email id" view:self];
    }else{
        NSString *gender=@"";
        UIImage *imgMale = [_btnMale imageForState:UIControlStateNormal];
         UIImage *imgFemale = [_btnFemale imageForState:UIControlStateNormal];
         if(([self firstimage:[UIImage imageNamed:@"Checkbox_Tick"] isEqualTo:imgMale])){
             gender=@"Male";
         }else if(([self firstimage:[UIImage imageNamed:@"Checkbox_Tick"] isEqualTo:imgFemale])){
             gender=@"Female";
         }
        
        NSString *strDate=[NSString stringWithFormat:@"%@-%@-%@",_txtDay.text,_txtMonth.text,_txtYear.text];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-mm-yyyy"];
        NSDate *date = [dateFormat dateFromString:strDate];
        NSDate *now=[NSDate date];
    //    NSComparisonResult result = [now compare:date];
//        if(result==NSOrderedAscending || result==NSOrderedSame){
//            [AlertView showAlertWithMessage:@"Invalid date" view:self];
//            return;
//        }
    
        
        SignUpPage2ViewController *cont=[[SignUpPage2ViewController alloc]initWithNibName:@"SignUpPage2ViewController" bundle:nil];
        cont.strfullName=_txtFullName.text;
        cont.strEmail=_txtEmail.text;
        cont.strMobNum=_txtPhoneNo.text;
        cont.strMonth=_txtMonth.text;
        cont.strDay=_txtDay.text;
        cont.strYear =_txtYear.text;
        cont.imgAvtar=_imgAvtar;
        cont.strGender=gender;
        [self.navigationController pushViewController:cont animated:YES];
    }
}
- (IBAction)cmdLogin:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)cmdPrivacyPolicy:(id)sender {
    PrivacyPolicyViewController *cont=[[PrivacyPolicyViewController alloc]initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}


-(void)addDesign{
    _viewtxtFullName.layer.cornerRadius=15;//0,160,223
    _viewtxtFullName.layer.borderWidth=1;
     _viewtxtFullName.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtFullName.layer.cornerRadius=15;//0,160,223
    
    _viewtxtEmail.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtEmail.layer.borderWidth=1;
    _viewtxtEmail.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtEmail.layer.cornerRadius=15;//0,160,223
    
    _viewTxtPhoneNo.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtPhoneNo.layer.borderWidth=1;
    _viewTxtPhoneNo.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtPhoneNo.layer.cornerRadius=15;//0,160,223
    
    _viewTxtMonth.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtMonth.layer.borderWidth=1;
    _viewTxtMonth.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtMonth.layer.cornerRadius=15;//0,160,223
    
    _viewtxtDay.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtDay.layer.borderWidth=1;
    _viewtxtDay.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewtxtDay.layer.cornerRadius=15;//0,160,223
    
    _viewTxtYear.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtYear.layer.borderWidth=1;
    _viewTxtYear.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewTxtYear.layer.cornerRadius=15;//0,160,223
    
    _btnNext.layer.cornerRadius=25;
    
     _scrollview.contentSize = CGSizeMake( SCREEN_SIZE.width, CGRectGetMaxY(_btnPrivacyPolicy.frame)+8);
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
     self.txtFullName.inputAccessoryView = numberToolbar;
     self.txtEmail.inputAccessoryView = numberToolbar;
     self.txtPhoneNo.inputAccessoryView = numberToolbar;
     self.txtMonth.inputAccessoryView = numberToolbar;
     self.txtDay.inputAccessoryView = numberToolbar;
     self.txtYear.inputAccessoryView = numberToolbar;
}
- (IBAction)cmdMale:(id)sender {
    [self.btnMale setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];
    [self.btnFemale setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];
}

- (IBAction)cmdFemale:(id)sender {
    [self.btnMale setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];
    [self.btnFemale setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];
}


#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtFullName){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtFullName){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -40, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtEmail){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -70, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtPhoneNo){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);
                         }else if (textField==self.txtMonth || textField==self.txtYear || textField==self.txtDay){
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
    NSString *currentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    int length = [currentString length];
    
    if(_txtMonth==textField || _txtDay==textField){
        if (length > 2) {
            return NO;
        }
    }else if(_txtYear==textField){
        if (length > 4) {
            return NO;
        }
    }
  
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
        //
    if(_txtFullName==textField){
        [_txtEmail becomeFirstResponder];
    }else if (_txtEmail==textField){
        [_txtPhoneNo becomeFirstResponder];
        
    }else if (_txtPhoneNo==textField){
        [_txtMonth becomeFirstResponder];
        
    }else if (_txtMonth==textField){
        [_txtDay becomeFirstResponder];
        
    }else if (_viewtxtDay==textField){
        [_txtYear becomeFirstResponder];
    }else if (_txtYear==textField){
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
    [self.view endEditing:YES];
}


-(void)doneWithNumberPad{
     [self retrunView];
    [self.view endEditing:YES];
    
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

-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqualToData:data2];
    
}
@end

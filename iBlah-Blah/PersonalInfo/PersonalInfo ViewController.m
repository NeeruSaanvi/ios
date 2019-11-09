//
//  PersonalInfo ViewController.m
//  iBlah-Blah
//
//  Created by webHex on 10/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PersonalInfo ViewController.h"

@interface PersonalInfo_ViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    IndecatorView *ind;
    NSDictionary *userInfo;
    BOOL checkPofile;
    NSString *imageName;
    NSString *bannerName;
}

@end

@implementation PersonalInfo_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    imageName=@"";
    bannerName=@"";
     [self addDesign];
    
    [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"USERINFO"
                                               object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllDetailOfUser" with:@[USERID,USERID]];
    
      [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
   // mSocket.emit("getAllDetailOfUser", user_id, friend_id);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"USERINFO"]) {
        
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
//        NSData *objectData1 = [[Arr objectAtIndex:2] dataUsingEncoding:NSUTF8StringEncoding];
//        NSArray *json1 = [NSJSONSerialization JSONObjectWithData:objectData1
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&jsonError];
//        NSData *objectData2 = [[Arr objectAtIndex:3] dataUsingEncoding:NSUTF8StringEncoding];
//        NSArray *json2 = [NSJSONSerialization JSONObjectWithData:objectData2
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&jsonError];
        userInfo=[json objectAtIndex:0];
        _txtFullName.text=[userInfo objectForKey:@"name"];
        _txtPhoneNo.text=[userInfo   objectForKey:@"contact"];
        _txtEmail.text=[userInfo objectForKey:@"email"];
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[userInfo objectForKey:@"image"]];
        _profilePic.imageURL=[NSURL URLWithString:strUrl];
        NSString *strUrl1=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[userInfo objectForKey:@"backImage"]];
        _bannerImage.imageURL=[NSURL URLWithString:strUrl1];
        NSString *strDOB=[userInfo  objectForKey:@"dob"];
        imageName=[userInfo objectForKey:@"image"];
        bannerName=[userInfo objectForKey:@"backImage"];
        if([strDOB   isEqualToString:@""]){
            
        }else{
            NSArray *ary = [strDOB componentsSeparatedByString:@"-"];
            _txtDay.text=[ary objectAtIndex:0];
            _txtMonth.text=[ary objectAtIndex:1];
            _txtYear.text=[ary objectAtIndex:2];

        }
        NSLog(@"heloo %@",json);
    }
}
-(void)addDesign{
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture1.numberOfTapsRequired = 1;
    [tapGesture1 setDelegate:self];
    [_profilePic addGestureRecognizer:tapGesture1];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture1:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [_bannerImage addGestureRecognizer:tapGesture];
    
    
    _profilePic.layer.cornerRadius=50;
    _profilePic.layer.borderWidth=1;
    _profilePic.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
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
                         self.view.frame=CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
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
    
    NSData *data1 = UIImageJPEGRepresentation(image1, 1);
    NSData *data2 = UIImageJPEGRepresentation(image2,1);
    return [data1 isEqualToData:data2];
    
}

- (IBAction)cmdNext:(id)sender {
    NSString *strfullName=[self.txtFullName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strEmail=[self.txtEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strMobNum=[self.txtPhoneNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strMonth=[self.txtMonth.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strDay=[self.txtDay.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strYear=[self.txtYear.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(strfullName.length<=0 || strEmail.length<=0 || strMobNum.length<=0 || strMonth.length<=0  || strDay.length<=0 || strYear.length<=0){
        [AlertView showAlertWithMessage:@"all fields are mandatory" view:self];
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
       
        
        NSString *strDate=[NSString stringWithFormat:@"%@-%@-%@",_txtDay.text,_txtMonth.text,_txtYear.text];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-mm-yyyy"];
        NSDate *date = [dateFormat dateFromString:strDate];
        NSDate *now=[NSDate date];
        NSComparisonResult result = [now compare:date];
        if(result==NSOrderedAscending || result==NSOrderedSame){
            [AlertView showAlertWithMessage:@"Invalid date" view:self];
            return;
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"updateUserInfo" with:@[USERID,_txtFullName.text,_txtPhoneNo.text,strDate,(imageName == nil ? @"": imageName),bannerName]];
       // mSocket.emit("updateUserInfo", user_id, name, contact, dateOfbirth, profile_url, banner_url);
        [AlertView showAlertWithMessage:@"Profile updated successfully." view:self];
    }
}

- (void) tapGesture: (id)sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  checkPofile=YES;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  checkPofile=YES;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"View Profile Pic"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                                  
                                  imageInfo.image = _profilePic.image;
                                  imageInfo.referenceRect = _profilePic.frame;
                                  imageInfo.referenceView = _profilePic.superview;
                                  imageInfo.referenceContentMode = _profilePic.contentMode;
                                  imageInfo.referenceCornerRadius = _profilePic.layer.cornerRadius;
                                  
                                  // Setup view controller
                                  JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                                         initWithImageInfo:imageInfo
                                                                         mode:JTSImageViewControllerMode_Image
                                                                         backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                                  
                                  // Present the view controller.
                                  [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
     [alert addAction:button3];
    
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        UIButton *btn=(UIButton *)sender;
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)tapGesture1: (id)sender
{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                  checkPofile=NO;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Choose existing"
                                  checkPofile=NO;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"View Banner Pic"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                                  
                                  imageInfo.image = _bannerImage.image;
                                  imageInfo.referenceRect = _bannerImage.frame;
                                  imageInfo.referenceView = _bannerImage.superview;
                                  imageInfo.referenceContentMode = _bannerImage.contentMode;
                                  imageInfo.referenceCornerRadius = _bannerImage.layer.cornerRadius;
                                  
                                  // Setup view controller
                                  JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                                         initWithImageInfo:imageInfo
                                                                         mode:JTSImageViewControllerMode_Image
                                                                         backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                                  
                                  // Present the view controller.
                                  [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        UIButton *btn=(UIButton *)sender;
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    NSData* data = UIImageJPEGRepresentation(chosenImage, 0.8);

    if(checkPofile){
        _profilePic.image=[UIImage imageWithData:data];
    }else{
        _bannerImage.image=[UIImage imageWithData:data];
    }
    [self performSelector:@selector(saveImage) withObject:nil afterDelay:1.5];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)saveImage{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:@"Are You Sure Want to Change Image!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self addImage];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(void)setNavigationBar{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        //        statusBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gradient_large"]];
        statusBar.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont systemFontOfSize:17.0f],
      NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title=@"INFO";
    self.navigationController.navigationBarHidden=NO;
    
}


-(void)addImage{
    
//    self.view.userInteractionEnabled=NO;
//    IndecatorView *ind=[[IndecatorView alloc]init];
//    [self.view addSubview:ind];

    [SVProgressHUD showWithStatus:@"Please, wait we are uploading your pic"];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"ios" forKey:@"device"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [dict setValue:USERID forKey:@"user_id"];

    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@?action=send_image",url];//action=iblahSignUp
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *imageData ;
    if(checkPofile){
     imageData   = [NSData dataWithData:UIImageJPEGRepresentation(self.profilePic.image,1)];
    }else{
        imageData   = [NSData dataWithData:UIImageJPEGRepresentation(self.bannerImage.image,1)];
    }
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
   
        
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"image" mimeType:@"png"];
        

        
    } error:nil];
    //    [upload_request setHTTPMethod:@"POST"];
    //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [upload_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [upload_request setHTTPShouldHandleCookies:NO];
//    [upload_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
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
                              [SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Please wait, we are uploading pic"];

                              NSLog(@"%f",uploadProgress.fractionCompleted);//Log the progress or pass it to progressview
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          [SVProgressHUD dismiss];
                          if (error) {
                              NSLog(@"OOPS!!!! %@", error);
                              [ind removeFromSuperview];
                              self.view.userInteractionEnabled=YES;
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              
                              if(checkPofile){
                                  imageName=[jsonArray objectForKey:@"image"];
                              }else{
                                  bannerName=[jsonArray objectForKey:@"image"];
                              }
                              self.view.userInteractionEnabled=YES;
                              [ind removeFromSuperview];
                              //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                              
                             
                              [AlertView showAlertWithMessage:@"Uploded" view:self];
                              
                              // }
                          }
                      }];
    
    [uploadFileTask resume];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

//
//  EditVideoViewController.m
//  iBlah-Blah
//
//  Created by Arun on 02/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "EditVideoViewController.h"

@interface EditVideoViewController (){
    NSArray *arrCategory;
    NSString *selectedValue;
    NSURL *videoURL;
    UIImage *thumb;
    NSString *srtThumb;
    NSString *strVideo;
}

@end

@implementation EditVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationBar];
    selectedValue=@"All Categories";
    arrCategory=@[@"All Categories",@"Animation",@"Talks",@"Sports",@"Reporting & Journalism",@"Personal",@"Narrative",@"Music",@"Instructionals",@"Food",@"Fashion",@"Experimental",@"Documentary",@"Camera & Techniques",@"Arts & Design",@"Travel"];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtTag.inputAccessoryView = numberToolbar;
    self.txtDescription.inputAccessoryView = numberToolbar;
    self.txtVideoTitle.inputAccessoryView = numberToolbar;
    srtThumb=@"";
    strVideo=@"";
    
    _txtDescription.text=[_dictVideoData objectForKey:@"description"];
    _txtTag.text=[_dictVideoData objectForKey:@"tags"];
    _txtVideoTitle.text=[_dictVideoData  objectForKey:@"title"];

    _lblCategory.text=[_dictVideoData  objectForKey:@"category"];
    NSString *strPrivacy=[NSString stringWithFormat:@"%@",[_dictVideoData objectForKey:@"privacy"]];
    NSString *strUrl=[NSString stringWithFormat:@"%@",[_dictVideoData objectForKey:@"video_thumb"]];
    _imgThumb.imageURL=[NSURL URLWithString:strUrl];

    if([strPrivacy isEqualToString:@"0"]){
        _lblPrivacy.text=@"Everyone";
    }else if([strPrivacy isEqualToString:@"1"]){
         _lblPrivacy.text=@"Friends";
    }else if([strPrivacy isEqualToString:@"1"]){
        _lblPrivacy.text=@"Friends of Friends";
    }else if([strPrivacy isEqualToString:@"1"]){
        _lblPrivacy.text=@"Only Me";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.title=@"ADD VIDEO";
    self.navigationController.navigationBarHidden=NO;
    
    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Save" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 40, 32);
    
    [btnClear addTarget:self action:@selector(cmdSave:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}
-(void)cmdSave:(id)sender{
    [self retrunView];
    [self.view endEditing:YES];
    NSString *strTitle=[_txtVideoTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strDescription=[_txtDescription.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     if([strTitle isEqualToString:@""] || [strDescription isEqualToString:@""]){
        [AlertView showAlertWithMessage:@"Please enter video title and description." view:self];
    }else{
        NSString *privacy=@"0";
        if([_lblPrivacy.text isEqualToString:@"0"]){
            privacy=@"0";
        }else if([_lblPrivacy.text isEqualToString:@"1"]){
            privacy=@"1";
        }else if([_lblPrivacy.text isEqualToString:@"1"]){
            privacy=@"2";
        }else if([_lblPrivacy.text isEqualToString:@"1"]){
            privacy=@"3";
        }
        NSString *idVideo=[_dictVideoData objectForKey:@"id"];
        //emit("editVideo", user_id, video_id, title, description, tag, category, privacy)
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        
        [appDelegate().socket emit:@"editVideo" with:@[USERID,idVideo,_txtVideoTitle.text,_txtDescription.text,_txtTag.text,_lblCategory.text,privacy]];
            //        _txtVideoTitle.text=@"";
            //        _txtDescription.text=@"";
            //        strVideo=@"";
            //        strVideo=@"";
         [[NSNotificationCenter defaultCenter]
          postNotificationName:@"refreshMyPlayList"
          object:self userInfo:nil];
        [AlertView showAlertWithMessage:@"Video edit successfully." view:self];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
         
    }
        //  mSocket.emit("AddNewVideo", user_id, title, desc, tags, categoruy, privacy, thumb, video, "0");
    
}
-(void)back{
   
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refreshMyPlayList"
     object:self userInfo:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)cmdSelectVideoUrl:(id)sender {
}


- (IBAction)cmdCategory:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    [self addPiker];
}

- (IBAction)cmdPrivacy:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    UIButton *btn=(UIButton *)sender;
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
                              actionWithTitle:@"Everyone"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  _lblPrivacy.text=@"Everyone";
                                  
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblPrivacy.text=@"Friends";
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Friends of Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblPrivacy.text=@"Friends of Friends";
                              }];
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Only Me"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblPrivacy.text=@"Only Me";
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    [alert addAction:button4];
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtVideoTitle){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -30, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtDescription){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -60, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtTag){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -90, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self retrunView];
    [textField resignFirstResponder];
    
    return YES;
}

-(void)doneWithNumberPad{
    [self retrunView];
    [self.view endEditing:YES];
    
}
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
}
#pragma mark - PickerView

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return arrCategory.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return arrCategory[row];
}


#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    selectedValue=arrCategory[row];
    
    NSLog(@"Hello %@",arrCategory[row]);
}


-(void)addPiker{
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-200-44, screenRect.size.width, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-200, screenRect.size.width, 200);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        // darkView.alpha = 1;
        // [darkView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker1:)] ;
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIPickerView *Picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, screenRect.size.width, 200)] ;
    Picker.tag = 10;
    Picker.backgroundColor=[UIColor whiteColor];
    Picker.delegate=self;
    [self.view addSubview:Picker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, screenRect.size.width, 44)] ;
    toolBar.tag = 11;
    toolBar.barTintColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        //toolBar.barStyle = UIBarStyleDefault;
    toolBar.tintColor=[UIColor whiteColor];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker1:)] ;
    doneButton.tag=1;
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDatePicker1:)] ;
    [toolBar setItems:[NSArray arrayWithObjects: CancelButton,spacer,doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    toolBar.frame = toolbarTargetFrame;
    Picker.frame = datePickerTargetFrame;
    [darkView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [UIView commitAnimations];
    
}
- (void)dismissDatePicker1:(id)sender {
    
    long tagValue=0;
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn=(UIBarButtonItem *)sender;
        tagValue=[btn tag];
    }
    if(tagValue==1){
        _lblCategory.text=selectedValue;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, screenRect.size.width, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, screenRect.size.width, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews1:)];
    [UIView commitAnimations];
}

- (void)removeViews1:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}




@end

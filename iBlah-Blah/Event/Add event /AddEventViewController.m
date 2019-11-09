//
//  AddEventViewController.m
//  iBlah-Blah
//
//  Created by Arun on 18/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddEventViewController.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#import "LocationSearchViewController.h"
#define OVERLAY_VIEW_TAG 121212121
@interface AddEventViewController ()<UIPickerViewDelegate, UIPickerViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DLFPhotosPickerViewControllerDelegate>{
    int checkDateTimePicker;
    NSString *DateSelectedDateObject;
    NSArray *arrCategory;
    NSString *selectedValue;
    NSMutableArray *arrImage;
    NSString *lat;
    NSString *lng;
    NSString *address;
    BOOL CheckVideoOrImage;
    BOOL checkLATLONG;
}

@end

@implementation AddEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    CheckVideoOrImage=false;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AddLocationEvent"
                                               object:nil];
    
    arrImage=[[NSMutableArray alloc]init];
    checkDateTimePicker=0;
    DateSelectedDateObject=@"";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    _lblStartingDate.text=[dateFormatter stringFromDate:[NSDate date]];
    _lblEndingDate.text=[dateFormatter stringFromDate:[NSDate date]];
     [dateFormatter setDateFormat:@"hh:mm a"];
     _lblStartingTime.text=[dateFormatter stringFromDate:[NSDate date]];
     _lblEndingTime.text=[dateFormatter stringFromDate:[NSDate date]];
    lat=appDelegate().str_lat;
    lng=appDelegate().str_lang;
    selectedValue=@"Architects";
    arrCategory=@[@"Architects",@"Models",@"General Contractors",@"Mechanics",@"Lawyers",@"Engineeers",@"Doctors",@"Churches",@"Celebrities",@"Actors",@"Nurses",@"Jewelry Designer",@"Teachers",@"Interior Designer",@"Auto Cad Drafting",@"Construction Estimator",@"Dealers",@"Constructions Development",@"Investors",@"Equipment Operators",@"Drywall Contractors",@"Stucco Contractors",@"Marketing",@"Bamks",@"Software Development",@"Boxing Agents",@"UFC Agents",@"Soccer",@"Boxing",@"UFC",@"Website Development",@"Night Clubs",@"Night Clubs Promoters",@"App Developers",@"Games",@"Pharmacy",@"Supermarket",@"Hotels",@"Model Agents",@"Movies",@"Baseball",@"Tv Directors",@"Celebrity Agents",@"Restaurants",@"Barber Shop",@"Hair Salon",@"Plumbing Contractors",@"Painting Contractors",@"Senators",@"Security",@"Arts Materials",@"Cleaning Contractors",@"Car Wash",@"Business Management",@"Car Dealers",@"Magazine",@"Hollywood Celebrity",@"Sunglass Manufacture",@"Events",@"Car Actions",@"Roof Contractors",@"A/C Contractors",@"Electric Contractors",@"Cabinet Contractors"];
    
    NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",appDelegate().str_lat,appDelegate().str_lang,appDelegate().str_lat,appDelegate().str_lang];
    _mapViewImage.imageURL=[NSURL URLWithString:strUrl];
    
    NSString *strCheckLocationExit=[NSString stringWithFormat:@"%@",appDelegate().str_lat];
    
    if([strCheckLocationExit isEqualToString:@""]){
        checkLATLONG=NO;
    }else{
        checkLATLONG=YES;
    }
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtEventName.inputAccessoryView = numberToolbar;
    self.txtDescription.inputAccessoryView = numberToolbar;
    self.txtLocation.inputAccessoryView = numberToolbar;
     [self.scrollView setContentSize:CGSizeMake(SCREEN_SIZE.width, CGRectGetMaxY(_scrollViewVideo.frame))];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [_lblLocation addGestureRecognizer:tapGestureRecognizer];
    _lblLocation.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    tapGestureRecognizer1.numberOfTapsRequired = 1;
    [_mapViewImage addGestureRecognizer:tapGestureRecognizer1];
    _mapViewImage.userInteractionEnabled = YES;

    
    
}
- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"AddLocationEvent"]) {
        NSDictionary *userInfo = notification.userInfo;
        lat=[userInfo objectForKey:@"lat"];
        lng=[userInfo objectForKey:@"lng"];
        address=[userInfo objectForKey:@"address"];
       // _txtLocation.text=address;
        
        if([lat isEqualToString:@""]){
            checkLATLONG=NO;
        }else{
            checkLATLONG=YES;
        }
        
        NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",lat,lng,lat,lng];
        _mapViewImage.imageURL=[NSURL URLWithString:strUrl];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)labelTapped{
    LocationSearchViewController *cont=[[LocationSearchViewController alloc]initWithNibName:@"LocationSearchViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
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
    
    self.title=@"ADD EVENT";
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
    NSString *strEventName=[_txtEventName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strEventInfo=[_txtDescription.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strLocation=[_txtLocation.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(!(arrImage.count>0)){
        [AlertView showAlertWithMessage:@"Event Image is compulsory." view:self];
        return;
    }else if(strEventName.length<=0 || strEventInfo.length<=0 || strLocation.length<=0){
        [AlertView showAlertWithMessage:@"All feilds are mandatory." view:self];
        return;
    }else if(!checkLATLONG){
         [AlertView showAlertWithMessage:@"Please add event location." view:self];
    }else{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        if([_strFrom isEqualToString:@"Group"]){
            [dict setValue:[_dictGroupData objectForKey:@"id"] forKey:@"group_id"];
        }
           [dict setValue:@"addNewEventios" forKey:@"action"];
        
        
        [dict setValue:USERID forKey:@"user_id"];
        [dict setValue:_txtEventName.text forKey:@"title"];
        [dict setValue:_txtDescription.text forKey:@"discription"];
        [dict setValue:_txtLocation.text forKey:@"location"];
        [dict setValue:@"1" forKey:@"type"];
        [dict setValue:@"ios" forKey:@"device"];
        [dict setValue:@"public" forKey:@"posttype"];
        [dict setValue:_lblEndingTime.text forKey:@"endTime"];
        [dict setValue:_lblEndingDate.text forKey:@"endDate"];
        [dict setValue:_lblCatogary.text forKey:@"category"];
        [dict setValue:appDelegate().Country forKey:@"country"];
        [dict setValue:_lblStartingDate.text forKey:@"startDate"];
        [dict setValue:_lblStartingTime.text forKey:@"startTime"];
        [dict setValue:lat forKey:@"lat"];
        [dict setValue:lng forKey:@"lon"];
        [self addGroup:dict];
    }
}
//action = addNewEvent
//user_id
//
//
//
//
//
//
//
//
//
//
//
- (IBAction)cmdStartingDate:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    checkDateTimePicker=1;
    [self addDatePiker:UIDatePickerModeDate];
}

- (IBAction)cmdStartingTime:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    checkDateTimePicker=2;
    [self addDatePiker:UIDatePickerModeTime];
}
- (IBAction)cmdEndingDate:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    checkDateTimePicker=3;
    [self addDatePiker:UIDatePickerModeDate];
}

- (IBAction)cmdEndingTime:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    checkDateTimePicker=4;
    [self addDatePiker:UIDatePickerModeTime];
}
- (IBAction)cmdCatogary:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    [self addPiker];
}
- (IBAction)cmdPrivacy:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
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
        UIButton *btn=(UIButton *)sender;
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)cmdMainImage:(id)sender {
    CheckVideoOrImage=false;
    [self retrunView];
    [self.view endEditing:YES];
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
                                  DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
                                  [photosPicker setPhotosPickerDelegate:self];
                                  [photosPicker setMultipleSelections:YES];
                                  [self presentViewController:photosPicker animated:YES completion:nil];
                              }];
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
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
#pragma mark date and time piker
-(void)addDatePiker:(UIDatePickerMode)mode{
    [self retrunView];
    [self.view endEditing:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, screenRect.size.width, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, screenRect.size.width, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        // darkView.alpha = 1;
        // [darkView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, screenRect.size.width, 216)] ;
    datePicker.tag = 10;
    
    datePicker.datePickerMode=mode;
    datePicker.backgroundColor=[UIColor whiteColor];
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, screenRect.size.width, 44)] ;
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    toolBar.barTintColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
     toolBar.tintColor=[UIColor whiteColor];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] ;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)] ;
    doneButton.tag=1;
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDatePicker:)] ;
    [toolBar setItems:[NSArray arrayWithObjects: CancelButton,spacer,doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    [darkView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [UIView commitAnimations];
    
}
- (void)dismissDatePicker:(id)sender {
    
    long tagValue=0;
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn=(UIBarButtonItem *)sender;
        tagValue=[btn tag];
    }
    if(![DateSelectedDateObject isEqualToString:@""]){
        if(tagValue==1){
            if(checkDateTimePicker==1){
                _lblStartingDate.text=DateSelectedDateObject;
            }else if(checkDateTimePicker==2){
                _lblStartingTime.text=DateSelectedDateObject;
            }else if(checkDateTimePicker==3){
                    //_lblStartingDate.text
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"dd-MMM-yyyy";
                NSDate *dateStart=[dateFormatter dateFromString:_lblStartingDate.text];
                NSDate *dateEnd=[dateFormatter dateFromString:DateSelectedDateObject];
                if( [dateEnd timeIntervalSinceDate:dateStart] >= 0 ) {
                    _lblEndingDate.text=DateSelectedDateObject;
                }else{
                    [AlertView  showAlertWithMessage:@"End date must be greater or equal to start date " view:self];
                    
                }
            }else if(checkDateTimePicker==4){
                
                NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateFormat = @"dd-MM-yyyy hh:mm a";
                NSDate *dateStart=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",_lblStartingDate.text,_lblStartingTime.text]];
                NSDate *dateEnd=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",_lblEndingDate.text,DateSelectedDateObject]];
                
                if( [dateEnd timeIntervalSinceDate:dateStart] >= 0 ) {
                    _lblEndingTime.text=DateSelectedDateObject;
                }else{
                    [AlertView  showAlertWithMessage:@"End date and time  must be greater or equal to start date and time " view:self];
                }
                
            }
            
        }
    }
   
    DateSelectedDateObject=@"";
    
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
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}
- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}
- (void)changeDate:(UIDatePicker *)sender {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *yourDate = sender.date;
    if(checkDateTimePicker==1){
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }else if(checkDateTimePicker==2){
        dateFormatter.dateFormat = @"hh:mm a";
    }else if(checkDateTimePicker==3){
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }else if(checkDateTimePicker==4){
        dateFormatter.dateFormat = @"hh:mm a";
    }
    
    NSLog(@"%@",[dateFormatter stringFromDate:yourDate]);
    DateSelectedDateObject=[dateFormatter stringFromDate:yourDate];
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
        _lblCatogary.text=selectedValue;
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

-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqualToData:data2];
    
}
#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtEventName){
                            // self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtDescription){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtLocation){
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
#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(CheckVideoOrImage){
      __block NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        if(!videoURL){
            videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        }
        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:[info objectForKey:UIImagePickerControllerPHAsset] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            // [self saveVideo:result];
            result=[self compressImage:result];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setValue:@"video" forKey:@"type"];
            [dict setObject:result forKey:@"thumb"];
            [dict setObject:videoURL forKey:@"videoURL"];
            [arrImage addObject:dict];
             [self addImage];
        }];
         [picker dismissViewControllerAnimated:YES completion:NULL];
    }else{
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        chosenImage=[self compressImage:chosenImage];
        if(arrImage.count>5){
            [arrImage removeObjectAtIndex:0];
        }
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:@"image" forKey:@"type"];
        [dict setObject:chosenImage forKey:@"value"];
        [arrImage addObject:dict];
       
        [self addImage];
    }
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - DLFPhotosPickerViewControllerDelegate

- (void)photosPicker:(DLFPhotosPickerViewController *)photosPicker detailViewController:(DLFDetailViewController *)detailViewController didSelectPhoto:(PHAsset *)photo {
    [photosPicker dismissViewControllerAnimated:YES completion:^{
        [self addImagesToScrollView:@[photo]];
    }];
}

- (void)photosPickerDidCancel:(DLFPhotosPickerViewController *)photosPicker {
    [photosPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photosPicker:(DLFPhotosPickerViewController *)photosPicker detailViewController:(DLFDetailViewController *)detailViewController didSelectPhotos:(NSArray *)photos {
    NSLog(@"selected %d photos", (int)photos.count);
    [photosPicker dismissViewControllerAnimated:YES completion:^{
        [self addImagesToScrollView:photos];
    }];
    
}

- (void)photosPicker:(DLFPhotosPickerViewController *)photosPicker detailViewController:(DLFDetailViewController *)detailViewController configureCell:(DLFPhotoCell *)cell indexPath:(NSIndexPath *)indexPath asset:(PHAsset *)asset {
    UIView *overlayView = [cell.contentView viewWithTag:OVERLAY_VIEW_TAG];
    if (indexPath.item%2 == 0) {
        if (!overlayView) {
            overlayView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
            [overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [overlayView setTag:OVERLAY_VIEW_TAG];
            [overlayView setBackgroundColor:[UIColor colorWithRed:1.000 green:.000 blue:0.000 alpha:0.300]];
            [cell.contentView addSubview:overlayView];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        }
        [overlayView setHidden:YES];
    } else {
        [overlayView setHidden:YES];
    }
}
- (void)addImagesToScrollView:(NSArray<PHAsset*> *)images {
    for (UIView *view in self.scrollView1.subviews) {
        [view removeFromSuperview];
    }
    
    for (PHAsset *asset in images) {
        if(arrImage.count>5){
            [arrImage removeObjectAtIndex:0];
        }
        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
           // [arrImage addObject:result];
            result=[self compressImage:result];
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setValue:@"image" forKey:@"type"];
            [dict setObject:result forKey:@"value"];
            
            [arrImage addObject:dict];
            [self addImage];
        }];
    }
    
}

-(void)addImage{
    
    for (UIView *view in self.scrollView1.subviews) {
        [view removeFromSuperview];
    }
    
    CGSize imageViewSize = CGSizeMake(self.scrollView1.frame.size.height, self.scrollView1.frame.size.height);
    CGRect previousRect = CGRectMake(-imageViewSize.width, 0, imageViewSize.width, imageViewSize.height);
    CGFloat maxX = 0;
    
    for (int i=0; i<arrImage.count; i++) {
        NSDictionary *dict=[arrImage objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectOffset(previousRect, imageViewSize.width + 10, 0);
        [self.scrollView1 addSubview:imageView];
        previousRect = imageView.frame;
        maxX = CGRectGetMaxX(imageView.frame);
        
        UIImage *img=[dict objectForKey:@"value"];
        [imageView setImage:img];
    }
    
    [self.scrollView1 setContentSize:CGSizeMake(maxX, imageViewSize.height)];
    
}


-(void)addGroup:(NSDictionary *)dict{
    
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    
    NSString *url = [NSString stringWithFormat:@ADDPOST];
    if([_strFrom isEqualToString:@"Group"]){
        url = [NSString stringWithFormat:@ADDGROUP];
    }
    url=[NSString stringWithFormat:@"%@",url];//action=iblahSignUp
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.imgMain.image)];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // [formData   appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoUrl] name:@"file" fileName:@"test" mimeType:@"mov"];
        int i=0;
        for(NSDictionary *eachImage in arrImage)
        {
            
             NSDictionary *dict=eachImage;
            NSString *type=[dict objectForKey:@"type"];
            if([type isEqualToString:@"image"]){
                NSData *imageData = UIImageJPEGRepresentation([dict objectForKey:@"value"],0.9);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"file%d.jpg",i ] mimeType:@"image/jpeg"];
                i++;
            }
           
        }
        
         i=11;
        for(NSDictionary *eachImage in arrImage)
        {
            
            NSDictionary *dict=eachImage;
            NSString *type=[dict objectForKey:@"type"];
            if(!([type isEqualToString:@"image"])){
               
               [formData appendPartWithFileData:[NSData dataWithContentsOfURL:[dict objectForKey:@"videoURL"]] name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"file%d.mov",i ] mimeType:@"mov"];
                i++;
            }
            
        }
        
        for(NSDictionary *eachImage in arrImage)
        {
            
            NSDictionary *dict=eachImage;
            NSString *type=[dict objectForKey:@"type"];
            if(!([type isEqualToString:@"image"])){
                 NSData *imageData = UIImageJPEGRepresentation([dict objectForKey:@"thumb"],0.9);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"video_thumb%d",i ] fileName:[NSString stringWithFormat:@"video_thumb%d.jpg",i ] mimeType:@"image/jpeg"];
                i++;
            }
            
        }
        
        // you file to upload
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
                          if (error) {
                              NSLog(@"OOPS!!!! %@", error);
                              [ind removeFromSuperview];
                              
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                                  
                                  [ind removeFromSuperview];
                                  //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [[NSNotificationCenter defaultCenter]
                                   postNotificationName:@"RefreshEvent"
                                   object:self userInfo:nil];
                                  [[NSNotificationCenter defaultCenter]
                                   postNotificationName:@"refreshGroupDetails"
                                   object:self userInfo:nil];
                                  
                                  [AlertView showAlertWithMessage:@"You have successfully event." view:self];
                                    [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                              
                          }
                      }];
    
    [uploadFileTask resume];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cmdAddVideo:(id)sender {
     CheckVideoOrImage=true;
    // Present videos from which to choose
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self; // ensure you set the delegate so when a video is chosen the right method can be called
    videoPicker.navigationBar.tintColor = [UIColor blackColor];
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    // This code ensures only videos are shown to the end user
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:videoPicker animated:YES completion:nil];
}

-(UIImage *)compressImage:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.7;//70 percent compression
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:imageData];
}

@end

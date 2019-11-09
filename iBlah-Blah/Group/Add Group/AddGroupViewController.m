//
//  AddGroupViewController.m
//  iBlah-Blah
//
//  Created by Arun on 17/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddGroupViewController.h"
#import "AllFrndViewController.h"
@interface AddGroupViewController ()<UIGestureRecognizerDelegate,UIPickerViewDelegate, UIPickerViewDataSource>{
    NSArray *arrCategory;
    NSString *selectedValue;
    NSString *tagedUserId;
    BOOL imageChnaged;
}

@end

@implementation AddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    imageChnaged=NO;
    [self setNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AddTagedFrnd"
                                               object:nil];
    
    _txtGroupInfo.layer.cornerRadius=8;
    _txtGroupInfo.layer.borderColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    _txtGroupInfo.layer.borderWidth=1;
    
    _imgGroup.layer.cornerRadius=8;
    _imgGroup.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _imgGroup.layer.borderWidth=1;
    selectedValue=@"Architects";
    arrCategory=@[@"Architects",@"Models",@"General Contractors",@"Mechanics",@"Lawyers",@"Engineeers",@"Doctors",@"Churches",@"Celebrities",@"Actors",@"Nurses",@"Jewelry Designer",@"Teachers",@"Interior Designer",@"Auto Cad Drafting",@"Construction Estimator",@"Dealers",@"Constructions Development",@"Investors",@"Equipment Operators",@"Drywall Contractors",@"Stucco Contractors",@"Marketing",@"Bamks",@"Software Development",@"Boxing Agents",@"UFC Agents",@"Soccer",@"Boxing",@"UFC",@"Website Development",@"Night Clubs",@"Night Clubs Promoters",@"App Developers",@"Games",@"Pharmacy",@"Supermarket",@"Hotels",@"Model Agents",@"Movies",@"Baseball",@"Tv Directors",@"Celebrity Agents",@"Restaurants",@"Barber Shop",@"Hair Salon",@"Plumbing Contractors",@"Painting Contractors",@"Senators",@"Security",@"Arts Materials",@"Cleaning Contractors",@"Car Wash",@"Business Management",@"Car Dealers",@"Magazine",@"Hollywood Celebrity",@"Sunglass Manufacture",@"Events",@"Car Actions",@"Roof Contractors",@"A/C Contractors",@"Electric Contractors",@"Cabinet Contractors"];
    
    
    if(_arryInfo){
        NSDictionary *dict=[_arryInfo objectAtIndex:0];
        _lblSelectedCategory.text=[dict objectForKey:@"catagory"];
        _txtGroupName.text=[dict objectForKey:@"name"];
        _txtGroupInfo.text=[dict objectForKey:@"description"];
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"group_image"]];
        _imgGroup.imageURL=[NSURL URLWithString:strUrl];
        [self showPeople:_arrMember];
    }
}
- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"AddTagedFrnd"]) {//
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        [self showPeople:Arr];
        tagedUserId=@"";
        for (int i=0; i<Arr.count; i++) {//user_id
            NSDictionary *dict=[Arr objectAtIndex:i];
            NSString *strUserId=[dict objectForKey:@"user_id"];
            
            
            if([tagedUserId isEqualToString:@""]){
                tagedUserId=strUserId;
            }else{
                tagedUserId=[NSString stringWithFormat:@"%@,%@",tagedUserId,strUserId];
            }
            
        }
    }
}
-(void)showPeople:(NSArray *)arrySelectedValue{
    for (UIView *view in self.frndScroll.subviews) {
        [view removeFromSuperview];
    }
    float xAxis=0;
    for (int i=0; i<arrySelectedValue.count; i++)
    {
        NSMutableDictionary *dataDict=[[arrySelectedValue objectAtIndex:i] mutableCopy] ;
        //        [dataDict setObject:@"0" forKey:@"is_host"];
        UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(xAxis, 3, [self getLabelHeight:[dataDict objectForKey:@"name"]], 40)];
        lblName.numberOfLines=2;
        lblName.lineBreakMode=NSLineBreakByWordWrapping;
        lblName.font = [UIFont boldSystemFontOfSize:14];
        lblName.textColor= [UIColor whiteColor];
        lblName.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];;
        lblName.layer.cornerRadius=8;
        lblName.clipsToBounds=YES;
        lblName.text=[dataDict objectForKey:@"name"];
        lblName.textAlignment = NSTextAlignmentCenter;
        [_frndScroll addSubview:lblName];
        xAxis=xAxis+[self getLabelHeight:[dataDict objectForKey:@"name"]]+5;
    }
    
    _frndScroll.contentSize = CGSizeMake( xAxis, 40);
    if(xAxis>320){
        CGPoint bottomOffset = CGPointMake( self.frndScroll.contentSize.width - self.frndScroll.bounds.size.width,0);
        [self.frndScroll setContentOffset:bottomOffset animated:YES];
    }
    

}

#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, 40);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cmdAddImage:(id)sender {
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
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
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

- (IBAction)cmdAddFriends:(id)sender {
    AllFrndViewController *R2VC = [[AllFrndViewController alloc]initWithNibName:@"AllFrndViewController" bundle:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
}

- (IBAction)cmdSelectCategory:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    [self addPiker];
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
    
    self.title=@"ADD GROUP";
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
    NSString *strGroupName=[_txtGroupName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *strGroupInfo=[_txtGroupInfo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(([self firstimage:[UIImage imageNamed:@"AddGroup"] isEqualTo:_imgGroup.image])){
        [AlertView showAlertWithMessage:@"Group Image is compulsory." view:self];
        return;
    }else if(strGroupName.length<=0){
        [AlertView showAlertWithMessage:@"Group name is compulsory." view:self];
        return;
    }else if(strGroupInfo.length<=0){
        [AlertView showAlertWithMessage:@"Group info is compulsory." view:self];
        return;
    }
//    else if(tagedUserId.length<=2){
//        [AlertView showAlertWithMessage:@"Please add atleast one friend." view:self];
//        return;
//    }
    else{
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];

        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        if(_arryInfo){
            NSDictionary *dict1=[_arryInfo objectAtIndex:0];
            [dict setValue:[dict1 objectForKey:@"id"] forKey:@"group_id"];
           [dict setValue:@"editGroup" forKey:@"action"];
        }else{
           [dict setValue:@"newGroup" forKey:@"action"];
        }
        [dict setValue:USERID forKey:@"user_id"];
        [dict setValue:_txtGroupName.text forKey:@"name"];
        [dict setValue:_txtGroupInfo.text forKey:@"desc"];
        [dict setValue:_lblSelectedCategory.text forKey:@"catagory"];
        [dict setValue:@"1" forKey:@"type"];
        [dict setValue:@"ios" forKey:@"device"];
        [dict setValue:tagedUserId forKey:@"members"];
        
        [self addGroup:dict];
    }
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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)] ;
    doneButton.tag=1;
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissDatePicker:)] ;
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
- (void)dismissDatePicker:(id)sender {
  
    long tagValue=0;
    if([sender isKindOfClass:[UIBarButtonItem class]])
    {
        UIBarButtonItem *btn=(UIBarButtonItem *)sender;
        tagValue=[btn tag];
    }
    if(tagValue==1){
        _lblSelectedCategory.text=selectedValue;
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
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageChnaged=YES;
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    _imgGroup.image=chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
                         if(textField==self.txtGroupName){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
        //
    [self retrunView];
    [textField resignFirstResponder];
    
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
     [self retrunView];
    [self.view endEditing:YES];
}
-(void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textView==self.txtGroupInfo){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -100, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
-(void)addGroup:(NSDictionary *)dict{
    self.view.userInteractionEnabled=NO;
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@",url];//action=iblahSignUp
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(self.imgGroup.image)];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
            // [formData   appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoUrl] name:@"file" fileName:@"test" mimeType:@"mov"];
        if(imageChnaged){
             [formData appendPartWithFileData:imageData name:@"file" fileName:@"image" mimeType:@"png"];
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
                              self.view.userInteractionEnabled=YES;
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              
//                              if (error != nil) {
//                                  NSLog(@"Error parsing JSON.");
//                                  [ind removeFromSuperview];
//                                  self.view.userInteractionEnabled=YES;
//                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
//                              }
//                              else {
                                  self.view.userInteractionEnabled=YES;
                                  [ind removeFromSuperview];
                                      //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                              
                              [[NSNotificationCenter defaultCenter]
                               postNotificationName:@"refreshGroupDetails"
                               object:self userInfo:nil];
                              [[NSNotificationCenter defaultCenter]
                               postNotificationName:@"RefreshAllGroup"
                               object:self userInfo:nil];
                                  [AlertView showAlertWithMessage:@"You have successfully edited the group" view:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                             // }
                          }
                      }];
    
    [uploadFileTask resume];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

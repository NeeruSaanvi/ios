//
//  AddVideoViewController.m
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddVideoViewController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
@interface AddVideoViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSArray *arrCategory;
    NSString *selectedValue;
    NSURL *videoURL;
    UIImage *thumb;
    NSString *srtThumb;
    NSString *strVideo;
    NSMutableArray *arryChunkData;
    
    UIImage *thumbImage;
    NSMutableDictionary *dictJson;
    BOOL UplodeVideo;
    IndecatorView *ind;
}

@end

@implementation AddVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ind=[[IndecatorView alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"VideoChunk"
                                               object:nil];
    
    
    [self setNavigationBar];
    _btnUploadVideo.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _btnUploadVideo.layer.borderWidth=1;
    _btnUploadVideo.clipsToBounds=YES;
    _btnUploadVideo.layer.cornerRadius=4;
    
    _btnSelectVideoUrl.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _btnSelectVideoUrl.layer.borderWidth=1;
    _btnSelectVideoUrl.clipsToBounds=YES;
    _btnSelectVideoUrl.layer.cornerRadius=4;
    
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
    
    
    
    
  //  mSocket.emit("getAllFriendRequest", user_id);
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"VideoChunk"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSLog(@"%@ Arry",Arr);
        if(UplodeVideo){
            if(Arr.count>1){
                NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                NSString *strPertage=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];

                [SVProgressHUD showProgress:[strPertage floatValue]/100.00 status:@"Please wait, we are uploading video"];

                if([strPertage isEqualToString:@"100"]){
                    strVideo=[NSString stringWithFormat:@"http://iblah-blah.com/iblah/videos/%@",[dictJson objectForKey:@"Name"]];
                    [SVProgressHUD dismiss];
                    UplodeVideo=false;
                    [self uploadThumb];
                    return;
                }
                if(!([strValue isEqualToString:@"0"])){
                    if(arryChunkData.count>0){
                        [arryChunkData removeObjectAtIndex:0];
                    }else{
                            //http://iblah-blah.com/iblah/images/1527957175.jpg
                            // http://iblah-blah.com/iblah/videos/1525623383_6900572568.mp4
                       
                    }
                }
                NSMutableDictionary *dict;
                
                dict=[[NSMutableDictionary alloc]init];
                [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                 //[dictJson setValue:@"false" forKey:@"IsAudio"];
                [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                
                [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
            }
        }else{
            if(Arr.count>1){
                NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                NSString *strPertage=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];
                [SVProgressHUD showProgress:[strPertage floatValue]/100.00 status:@"Please wait ..."];

                if([strPertage isEqualToString:@"100"]){
                    srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
                    [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
                    return;
                }
                
                if(!([strValue isEqualToString:@"0"])){
                    if(arryChunkData.count>1){
                        [arryChunkData removeObjectAtIndex:0];
                    }else{
                        [SVProgressHUD dismiss];
                        srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
                        [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
                        return;
                    }
                }
                NSMutableDictionary *dict;
                
                dict=[[NSMutableDictionary alloc]init];
                [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                 [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                
                [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
            }
        }
        
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
    if([strVideo isEqualToString:@""] || [strVideo isEqualToString:@""]){
        [AlertView showAlertWithMessage:@"Please Upload Video first" view:self];
        
    }else if([strTitle isEqualToString:@""] || [strDescription isEqualToString:@""]){
        [AlertView showAlertWithMessage:@"Please enter video title and description." view:self];
    }else{
        NSString *privacy=@"0";
        if([_lblPrivacy.text isEqualToString:@"Everyone"]){
            privacy=@"0";
        }else if([_lblPrivacy.text isEqualToString:@"Friends"]){
            privacy=@"1";
        }else if([_lblPrivacy.text isEqualToString:@"Friends of Friends"]){
            privacy=@"2";
        }else if([_lblPrivacy.text isEqualToString:@"Only Me"]){
            privacy=@"3";
        }
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
         [appDelegate().socket emit:@"AddNewVideo" with:@[USERID,_txtVideoTitle.text,_txtDescription.text,_txtTag.text,_lblCategory.text,privacy,srtThumb,strVideo,@"0"]];
//        _txtVideoTitle.text=@"";
//        _txtDescription.text=@"";
//        strVideo=@"";
//        strVideo=@"";
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshMyPlayList"
         object:self userInfo:nil];
        [AlertView showAlertWithMessage:@"Video saved." view:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
  //  mSocket.emit("AddNewVideo", user_id, title, desc, tags, categoruy, privacy, thumb, video, "0");
    
}
- (IBAction)cmdSelectVideoUrl:(id)sender {
}

- (IBAction)cmdUploadVideo:(id)sender {
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

- (IBAction)cmdCategory:(id)sender {
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


#pragma mark video piker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
        // This is the NSURL of the video object
    videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    if(!videoURL){
        videoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    }
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:[info objectForKey:UIImagePickerControllerPHAsset] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
       // [self saveVideo:result];
        [self divide_data_into_pieces:result];
       
    }];
    NSLog(@"VideoURL = %@", videoURL);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


-(void)saveVideo:(UIImage *)img{
    thumbImage=img;
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"send_video" forKey:@"action"];
    [dict setValue:@"ios" forKey:@"device"];
    
    NSData *data = UIImagePNGRepresentation(img);
    [dict setObject:[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] forKey:@"thumb"];
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@",url];
    
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
            // [formData   appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoUrl] name:@"file" fileName:@"test" mimeType:@"mov"];
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:videoURL] name:@"file" fileName:@"test" mimeType:@"mov"]; // you file to upload
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
                              [ind removeFromSuperview];
                              NSLog(@"OOPS!!!! %@", error);
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              [ind removeFromSuperview];
                              if (error != nil) {
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                                  NSLog(@"Error parsing JSON.");
                              }
                              else {
                                  NSLog(@"success.");
                                  srtThumb =[jsonArray objectForKey:@"thumb"];
                                  strVideo=[jsonArray objectForKey:@"video"];
                                   [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
                              }
                          }
                      }];
    
    [uploadFileTask resume];
}


// a method for dividing data into pieces.
- (void)divide_data_into_pieces:(UIImage *)img {
    [self.view addSubview:ind];
    UplodeVideo=YES;
    arryChunkData=[[NSMutableArray alloc]init];
    thumbImage=img;

    
    NSData* myBlob=[NSData dataWithContentsOfURL:videoURL];
    NSUInteger length = [myBlob length];
    NSUInteger chunkSize = 1000 * 1024;
    NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        NSString *base64String = [chunk base64EncodedStringWithOptions:0];
        
        base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
                                                               withString:@"_"];
        
        base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
                                                               withString:@"-"];

         [arryChunkData addObject:base64String];
            // do something with chunk
    } while (offset < length);
    
    if(arryChunkData.count>0){
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.mov",uuid];
       
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
       // mSocket.emit("uploadFileStart", jsonObject);
        //http://iblah-blah.com/iblah/images/1527957175.jpg
       // http://iblah-blah.com/iblah/videos/1525623383_6900572568.mp4
        dictJson=[[NSMutableDictionary alloc]init];
        [dictJson setValue:uuid forKey:@"Name"];
        [dictJson setValue:StrSize forKey:@"Size"];
        [dictJson setValue:@"true" forKey:@"IsVideo"];
        [dictJson setValue:USERID forKey:@"from_id"];
        [dictJson setValue:@"false" forKey:@"IsAudio"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
        [self uploadImageVideo];
    }

}
-(void)uploadThumb{
    
    [arryChunkData removeAllObjects];
    arryChunkData=nil;
    arryChunkData=[[NSMutableArray alloc]init];
    NSData* data = UIImagePNGRepresentation(thumbImage);
    
    NSData* myBlob=data;
    NSUInteger length = [myBlob length];
    NSUInteger chunkSize = 1000 * 1024;
    NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        NSString *base64String = [chunk base64EncodedStringWithOptions:0];
        
       // base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
                                                      //         withString:@"_"];
        
      //  base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
                                                         //      withString:@"-"];
        
        [arryChunkData addObject:base64String];
            // do something with chunk
    } while (offset < length);
    
    if(arryChunkData.count>0){
        
        dictJson=nil;

        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.png",uuid];
        
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
        //http://iblah-blah.com/iblah/images/1527957175.jpg
        // http://iblah-blah.com/iblah/videos/1525623383_6900572568.mp4
        dictJson=[[NSMutableDictionary alloc]init];
        [dictJson setValue:uuid forKey:@"Name"];
        [dictJson setValue:StrSize forKey:@"Size"];
        [dictJson setValue:@"false" forKey:@"IsVideo"];
        [dictJson setValue:USERID forKey:@"from_id"];
         [dictJson setValue:@"false" forKey:@"IsAudio"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
         [self uploadImageVideo];
    }
    
}

#pragma mark Listner
-(void)uploadImageVideo{
    NSString *USERID = [dictJson objectForKey:@"Name"];
    [appDelegate().socket on:USERID callback:^(NSArray* data, SocketAckEmitter* ack) {// 39 for get all post
        [SVProgressHUD dismiss];
        if(UplodeVideo){
            strVideo=[NSString stringWithFormat:@"http://iblah-blah.com/iblah/videos/%@",[dictJson objectForKey:@"Name"]];
            UplodeVideo=false;
            [self uploadThumb];
            return;
            
        }else{
            
            [ind removeFromSuperview];
            
            srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
            [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
            return;
        }

    }];
    
}


@end

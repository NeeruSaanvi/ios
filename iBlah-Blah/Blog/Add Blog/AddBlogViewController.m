//
//  AddBlogViewController.m
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddBlogViewController.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#define OVERLAY_VIEW_TAG 121212121
@interface AddBlogViewController ()<UIPickerViewDelegate, UIPickerViewDataSource,DLFPhotosPickerViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSArray *arrCategory;
    NSString *selectedValue;
    NSMutableArray *arrImage;
    NSMutableArray *arrImageToAddInBlog;
     NSString *strPrivacy;
    NSString *link;
}

@end

@implementation AddBlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationBar];
    strPrivacy=@"0";
    link=@"";
    arrImage=[[NSMutableArray alloc]init];
    arrImageToAddInBlog=[[NSMutableArray alloc]init];
    _btnPreview.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _btnPreview.layer.borderWidth=1;
    _btnPreview.clipsToBounds=YES;
    _btnPreview.layer.cornerRadius=4;
    
    _viewAttachment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewAttachment.layer.borderWidth=1;
    _viewAttachment.clipsToBounds=YES;
    _viewAttachment.layer.cornerRadius=4;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtPost.inputAccessoryView = numberToolbar;
    self.txtTitle.inputAccessoryView = numberToolbar;
    

     _lblStatus.text=@"Publish";
    selectedValue=@"Business";
    arrCategory=@[@"Business",@"Sports",@"Society",@"Shopiping",@"Recration",@"Health",@"Family & Home",@"Entertainment",@"Education",@"Technoogy"];
   _scrollView.contentSize = CGSizeMake( SCREEN_SIZE.width, CGRectGetMaxY(_scrollViewImage.frame )+20);
    
    
    
    _viewPreviewSubView.layer.cornerRadius=15;
    _btnOk.layer.cornerRadius=22;
    self.viewPreview.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
    if(_dictDetails){
        _lblCategory.text=[_dictDetails objectForKey:@"category"];

        NSString *strPrivacy=[NSString stringWithFormat:@"privacy"];
        
        if([strPrivacy   isEqualToString:@"0"]){
            strPrivacy=@"0";
            _lblPrivacy.text=@"Everyone";
        }else if([strPrivacy   isEqualToString:@"1"]){
            strPrivacy=@"1";
            _lblPrivacy.text=@"Friends";
        }else if([strPrivacy   isEqualToString:@"2"]){
            strPrivacy=@"2";
            _lblPrivacy.text=@"Friends of Friends";
        }else if([strPrivacy   isEqualToString:@"3"]){
            strPrivacy=@"3";
            _lblPrivacy.text=@"Only Me";
        }
        link=[_dictDetails objectForKey:@"link"];
        _lblStatus.text=[_dictDetails objectForKey:@"status"];
        _txtTitle.text=[_dictDetails objectForKey:@"title"];
        _txtViewPost.textView.text=[_dictDetails objectForKey:@"post"];
        arrImage=nil;
        arrImage =[[NSMutableArray alloc]init];
        for (int i=0; i<_imageArryDetails.count; i++) {
            NSDictionary *dictImage=[_imageArryDetails objectAtIndex:i];
            [arrImage addObject:[dictImage objectForKey:@"image"]];
            
            
        }
        [self addImage];
    }
    
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
    
    self.title=@"ADD BLOG";
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
    

    
    
    NSString *strTitle=[_txtTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strPost=[_txtViewPost.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strTitle.length<=0 || strPost.length<=0){
        [AlertView   showAlertWithMessage:@"Title and Post are mandatory." view:self];
    }else{
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
         [dict setValue:@"ios" forKey:@"device"];
         [dict setValue:@"addNewBlog" forKey:@"action"];
         [dict setValue:USERID forKey:@"user_id"];
         [dict setValue:link forKey:@"link"];
         [dict setValue:_txtTitle.text forKey:@"title"];
         [dict setValue:_txtViewPost.textView.text forKey:@"discription"];
         [dict setValue:strPrivacy forKey:@"posttype"];
         [dict setValue:_lblCategory.text forKey:@"category"];
         [dict setValue:_lblStatus.text forKey:@"status"];
         [dict setValue:appDelegate().Country forKey:@"country"];
        
        //Base Url + groupsapi
       // action - editBlog
     //   blog_id
    //    pre_loaded_images
        if(_dictDetails){
             [dict setValue:@"editBlog" forKey:@"action"];
            [dict setValue:[_dictPost objectForKey:@"id"] forKey:@"blog_id"];
            
            [self EdituploadMultipleImageInSingleRequest:dict];
        }else{
             [self uploadMultipleImageInSingleRequest:dict];
        }
        
       
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cmdCategory:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    [self addPiker];
}

- (IBAction)cmdStatus:(id)sender {
    
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
                              actionWithTitle:@"Publish"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  _lblStatus.text=@"Publish";
                                  
                              }];
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Draft"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblStatus.text=@"Draft";
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
                                   strPrivacy=@"0";
                                  _lblPrivacy.text=@"Everyone";
                                  
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                   strPrivacy=@"1";
                                  _lblPrivacy.text=@"Friends";
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Friends of Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  strPrivacy=@"2";
                                  _lblPrivacy.text=@"Friends of Friends";
                              }];
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Only Me"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              { strPrivacy=@"3";
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
- (IBAction)cmdGalary:(id)sender {
    DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
    [photosPicker setPhotosPickerDelegate:self];
    [photosPicker setMultipleSelections:YES];
    [self presentViewController:photosPicker animated:YES completion:nil];
}

- (IBAction)cmdPrivew:(id)sender {
    
    
    NSString *strPost=[_txtViewPost.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if( strPost.length<=0){
        [AlertView   showAlertWithMessage:@"Post text is mandatory." view:self];
    }else{
        
        NSString *strPost=_txtViewPost.textView.text;
        strPost= [strPost stringByReplacingOccurrencesOfString:@"11+11@img" withString:@"%1%"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%1%(.*?)%1%" options:NSRegularExpressionCaseInsensitive error:NULL];
        
        NSString *input = strPost;
        NSArray *myArray = [regex matchesInString:input options:0 range:NSMakeRange(0, [input length])] ;
        
        NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[myArray count]];
        
        for (NSTextCheckingResult *match in myArray) {
            NSRange matchRange = [match rangeAtIndex:1];
            [matches addObject:[input substringWithRange:matchRange]];
            NSLog(@"%@", [matches lastObject]);
        }
        strPost= [strPost stringByReplacingOccurrencesOfString:@"%1%" withString:@""];
        for (int i=0; i<matches.count; i++) {
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,matches[i]];
            NSString *strImage=[NSString stringWithFormat:@"<br><br/><img src='%@'/><br/>",strUrl];
            strPost= [strPost stringByReplacingOccurrencesOfString:matches[i] withString:strImage];
            
        }
        
        _viewPreview.frame=CGRectMake(0, -SCREEN_SIZE.height,SCREEN_SIZE.width, SCREEN_SIZE.height-64);
        _viewPreview.hidden=NO;
        [self.view addSubview:_viewPreview];
        [_WebView loadHTMLString:strPost baseURL:nil];
        [UIView animateWithDuration:1.0f
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:5.0
                            options:0
                         animations:^{ _viewPreview.frame = CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height-64); }
                         completion:^(BOOL finished) {
                             // slide down animation finished, remove the older view and the constraints
                             //
                         }];
        
    }
    
    
    
   
    
}

- (IBAction)cmdAttachment:(id)sender {
    [self addLink];
}


#pragma mark ---------- Text Feild delegate ------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if(textField==self.txtTitle){
                                 // self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtPost){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
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

-(void)cmdAddImageTextView{
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
     imagePickerController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:imagePickerController animated:YES completion:^{}];
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
    for (UIView *view in self.scrollViewImage.subviews) {
        [view removeFromSuperview];
    }
    
    for (PHAsset *asset in images) {
        if(arrImage.count>9){
            [arrImage removeObjectAtIndex:0];
        }
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            result=[self compressImage:result];
            [arrImage addObject:result];
            [self addImage];
        }];
    }
    
}

-(void)addImage{
    

        
        for (UIView *view in self.scrollViewImage.subviews) {
            [view removeFromSuperview];
        }
        
        CGSize imageViewSize = CGSizeMake(self.scrollViewImage.frame.size.height, self.scrollViewImage.frame.size.height);
        CGRect previousRect = CGRectMake(-imageViewSize.width, 0, imageViewSize.width, imageViewSize.height);
        CGFloat maxX = 0;
        
        for (int i=0; i<arrImage.count; i++) {
            AsyncImageView *imageView = [[AsyncImageView alloc] init];
            [imageView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius=imageViewSize.width/2;
            imageView.layer.borderWidth=1;
            imageView.clipsToBounds=YES;
            imageView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
            imageView.frame = CGRectOffset(previousRect, imageViewSize.width + 10, 0);
            [self.scrollViewImage addSubview:imageView];
            previousRect = imageView.frame;
            maxX = CGRectGetMaxX(imageView.frame);
            
            id img=[arrImage objectAtIndex:i];
            if([img isKindOfClass:[NSString class]] == YES){
                NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arrImage[i]];
                imageView.imageURL=[NSURL URLWithString:strUrl];
                
            }else{
                UIImage *img=arrImage[i];
                [imageView setImage:img];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
            [imageView addGestureRecognizer:tap];
            tap.view.tag=i;
            [imageView setUserInteractionEnabled:YES];
            
        }
        
        [self.scrollViewImage setContentSize:CGSizeMake(maxX, imageViewSize.height)];
}
    
- (void)smallButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Remove Pic"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               { AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
                                   
                                   [arrImage removeObjectAtIndex:img.tag];
                                   [self addImage];
                               }];
    
    
    UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"View Pic"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                              {
                                  AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
                                  
                                  JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                                  
                                  imageInfo.image = img.image;
                                  imageInfo.referenceRect = img.frame;
                                  imageInfo.referenceView = img.superview;
                                  imageInfo.referenceContentMode = img.contentMode;
                                  imageInfo.referenceCornerRadius = img.layer.cornerRadius;
                                  
                                  // Setup view controller
                                  JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                                         initWithImageInfo:imageInfo
                                                                         mode:JTSImageViewControllerMode_Image
                                                                         backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
                                  
                                  // Present the view controller.
                                  [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
                                  
                                  
                              }];
    [alert addAction:btnEdit];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                                 
                                 
                             }];
    
    
    [alert addAction:btnAbuse];
    [alert addAction:cancel];
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = img;
        popPresenter.sourceRect = img.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(SCREEN_SIZE.width-40, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    chosenImage=[self compressImage:chosenImage];
    [self addImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)onInsertImage:(id)sender {
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    imagePickerController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}

-(void)addImage:(UIImage *)imgg{
        // self.view.userInteractionEnabled=NO;
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"ios" forKey:@"device"];
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@?action=send_image",url];//action=iblahSignUp
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *imageData ;
    
    imageData   = [NSData dataWithData:UIImageJPEGRepresentation(imgg,0.9)];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"image" mimeType:@"png"];
        
        
        
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
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              [ind removeFromSuperview];
                              if (error != nil) {
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                                  NSLog(@"Error parsing JSON.");
                              }
                              else {
                                  NSLog(@"success.");
                                  //[jsonArray objectForKey:@"image"]
                                  NSString *strImageValue=[NSString stringWithFormat:@"11+11@img%@11+11@img",[jsonArray objectForKey:@"image"]];
                                  _txtViewPost.textView.text=[NSString stringWithFormat:@"%@%@",_txtViewPost.textView.text,strImageValue];
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
}


- (void)uploadMultipleImageInSingleRequest:(NSDictionary *)dictParm
{
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSDictionary *aParametersDic=dictParm; // It's contains other parameters.
    NSString *urlString; // an url where the request to be posted
    urlString = [NSString stringWithFormat:@ADDGROUP];//USERID
    
    urlString=[NSString stringWithFormat:@"%@",urlString];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:aParametersDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        int i=0;
        for(UIImage *eachImage in arrImage)
        {
            NSData *imageData = UIImageJPEGRepresentation(eachImage,0.9);
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"file%d.jpg",i ] mimeType:@"image/jpeg"];
            i++;
        }
        
    } error:nil];
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
                              [ind removeFromSuperview];
                              NSError *error = nil;
                              NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              
                              if (error != nil) {
                                  NSLog(@"Error parsing JSON.");
                                  [ind removeFromSuperview];
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                              }
                              else {
                                  [ind removeFromSuperview];
                               
                                      //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [AlertView showAlertWithMessage:@"You blog have successfully posted." view:self];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBlog" object:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                                  
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
    
}


- (void)EdituploadMultipleImageInSingleRequest:(NSDictionary *)dictParm
{
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSMutableDictionary *dict=[dictParm mutableCopy];
    NSString *strPreLodedImg=@"";
    
    for (int i=0; i<arrImage.count; i++) {
        id img=[arrImage objectAtIndex:i];
        if([img isKindOfClass:[NSString class]] == YES){
            if([strPreLodedImg isEqualToString:@""]){
                strPreLodedImg=arrImage[i];
            }else{
                strPreLodedImg=[NSString stringWithFormat:@"%@,%@",strPreLodedImg,arrImage[i]];
            }
        }else{
            
        }
    }
    [dict setValue:strPreLodedImg forKey:@"pre_loaded_images"];
    dictParm=dict;
    
    NSDictionary *aParametersDic=dictParm; // It's contains other parameters.
    NSString *urlString; // an url where the request to be posted
    urlString = [NSString stringWithFormat:@ADDGROUP];//USERID
    
    urlString=[NSString stringWithFormat:@"%@",urlString];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:aParametersDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (int i=0; i<arrImage.count; i++) {
            id img=[arrImage objectAtIndex:i];
            if([img isKindOfClass:[NSString class]] == YES){
            }else{
                NSData *imageData = UIImageJPEGRepresentation(img,0.9);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"file%d.jpg",i ] mimeType:@"image/jpeg"];
            }
        }
        
    } error:nil];
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
                              [ind removeFromSuperview];
                              NSError *error = nil;
                              NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              
                              if (error != nil) {
                                  NSLog(@"Error parsing JSON.");
                                  [ind removeFromSuperview];
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                              }
                              else {
                                  [ind removeFromSuperview];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBlog" object:self];
                                  //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [AlertView showAlertWithMessage:@"You blog have successfully updated." view:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                                  
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
    
}

-(void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)addLink{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Attention!"
                                                                              message: @"Please enter your link."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        
        BOOL checkUrl=[self validateUrl:namefield.text];
        if(checkUrl){
             [AlertView showAlertWithMessage:@"Link Added successfully." view:self];
             link=namefield.text;
            
        }else{
            [AlertView showAlertWithMessage:@"Url is not correct" view:self];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (BOOL) validateUrl: (NSString *) candidate {
    
    NSURL *url = [NSURL URLWithString:candidate];
    
    if (url && url.scheme && url.host) {
        return YES;
    }
    
    return NO;
}
- (IBAction)cmdOk:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _viewPreview.alpha = 0;
                     }completion:^(BOOL finished){
                         _viewPreview.alpha = 1.0f;
                         [_viewPreview removeFromSuperview];
                     }];
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

//
//  AddMarketPlaceViewController.m
//  iBlah-Blah
//
//  Created by Arun on 17/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddMarketPlaceViewController.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#import "LocationViewController.h"
#define OVERLAY_VIEW_TAG 121212121
@interface AddMarketPlaceViewController ()<DLFPhotosPickerViewControllerDelegate>{
    NSMutableArray *arrImage;
    NSString *strPrivacy;
}

@end

@implementation AddMarketPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationBar];
    strPrivacy=@"0";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MarketplaceLocation"
                                               object:nil];
   
    
    arrImage=[[NSMutableArray alloc]init];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtSelling.inputAccessoryView = numberToolbar;
    self.txtShortDescription.inputAccessoryView = numberToolbar;
    self.txtDescription.inputAccessoryView = numberToolbar;
    self.txtPrice.inputAccessoryView = numberToolbar;
    self.txtCity.inputAccessoryView = numberToolbar;
    self.txtZipCode.inputAccessoryView = numberToolbar;
    _scrollView.contentSize = CGSizeMake( SCREEN_SIZE.width, CGRectGetMaxY(_scrollViewImage.frame )+20);
    
    _viewAttachment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _viewAttachment.layer.borderWidth=1;
    _viewAttachment.clipsToBounds=YES;
    _viewAttachment.layer.cornerRadius=4;
    
    
    if(_dictDetails){
//        category = Sports;

        
        _lblCategory.text=[_dictDetails objectForKey:@"category"];
         _txtCity.text=[_dictDetails objectForKey:@"city"];
         _lblLocation.text=[_dictDetails objectForKey:@"location"];
         _txtDescription.text=[_dictDetails objectForKey:@"description"];
         _txtPrice.text=[_dictDetails objectForKey:@"price"];
         _lblPrivacyListing.text=[_dictDetails objectForKey:@"privacy"];
         _txtSelling.text=[_dictDetails objectForKey:@"title"];
         _txtZipCode.text=[_dictDetails objectForKey:@"zipcode"];
         _txtShortDescription.text=[_dictDetails objectForKey:@"shortdescription"];
        NSArray *arr=[[_dictPost objectForKey:@"images"] componentsSeparatedByString:@","];
        arrImage=[arr mutableCopy];
        [self addImage];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"MarketplaceLocation"]) {//UpdateMarketplace
         NSDictionary* userInfo = notification.userInfo;
        _lblLocation.text=[userInfo objectForKey:@"Location"];
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
    
    if(_dictPost){
         self.title=@"EDIT LIST";
    }else{
         self.title=@"ADD LIST";
    }
   
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
    NSString *strSelling = [_txtSelling.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strDescription = [_txtDescription.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strShortDescription = [_txtShortDescription.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strPrice = [_txtPrice.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strzipCode = [_txtZipCode.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strCity = [_txtCity.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strSelling.length<=0 || strDescription.length<=0 || strShortDescription.length<=0 || strPrice.length<=0 || strzipCode.length<=0 || strCity.length<=0){
        [AlertView showAlertWithMessage:@"All Feilds are mandatory." view:self];
    }else if (arrImage.count<=0){
        [AlertView showAlertWithMessage:@"Please add atleast one image." view:self];
    }else{
        
        NSMutableDictionary *dictParm=[[NSMutableDictionary alloc]init];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [dictParm setValue:USERID forKey:@"user_id"];
       
        [dictParm setValue:_txtSelling.text forKey:@"title"];
        [dictParm setValue:_txtShortDescription.text forKey:@"shortdescription"];
        [dictParm setValue:_txtDescription.text forKey:@"discription"];
        [dictParm setValue:_txtPrice.text forKey:@"price"];
        [dictParm setValue:_lblLocation.text forKey:@"location"];
        [dictParm setValue:_txtCity.text forKey:@"city"];
        [dictParm setValue:_lblCategory.text forKey:@"category"];
        [dictParm setValue:_txtZipCode.text forKey:@"zipcode"];
        [dictParm setValue:strPrivacy forKey:@"privacy"];
        [dictParm setValue:@"1" forKey:@"type"];
        [dictParm setValue:@"ios" forKey:@"device"];
        [dictParm setValue:appDelegate().Country forKey:@"country"];
        
        if(_dictDetails){
             NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
             [dictParm setValue:strPost_id forKey:@"post_id"];
             [dictParm setValue:@"editMyListing" forKey:@"action"];
            [self EdituploadMultipleImageInSingleRequest:dictParm];
        }else{
             [dictParm setValue:@"addNewListing" forKey:@"action"];
            [self uploadMultipleImageInSingleRequest:dictParm];
        }

        
    }
  
}
- (IBAction)cmdGalary:(id)sender {
    DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
    [photosPicker setPhotosPickerDelegate:self];
    [photosPicker setMultipleSelections:YES];
    [self presentViewController:photosPicker animated:YES completion:nil];
}
- (IBAction)cmdCatogary:(id)sender {
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
                              actionWithTitle:@"Sports"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  _lblCategory.text=@"Sports";
                                
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Food"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                 _lblCategory.text=@"Food";
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Travel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblCategory.text=@"Travel";
                              }];
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Photography"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  _lblCategory.text=@"Photography";
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
- (IBAction)cmdPrice:(id)sender {
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
                              actionWithTitle:@"US Dollars"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  _lblPrice.text=@"US Dollars";
                                  
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
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
- (IBAction)cmdLocation:(id)sender {
    [self retrunView];
    [self.view endEditing:YES];
    
     LocationViewController*cont=[[LocationViewController alloc]initWithNibName:@"LocationViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
- (IBAction)cmdPrivacyListing:(id)sender {
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
                                  _lblPrivacyListing.text=@"Everyone";
                                  
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  strPrivacy=@"1";
                                  _lblPrivacyListing.text=@"Friends";
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Friends of Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  strPrivacy=@"2";
                                  _lblPrivacyListing.text=@"Friends of Friends";
                              }];
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Only Me"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  strPrivacy=@"3";
                                  _lblPrivacyListing.text=@"Only Me";
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
                         if(textField==self.txtSelling){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -10, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtShortDescription){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -50, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtDescription){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -90, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtPrice){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -130, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtCity){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -170, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
                         }else if (textField==self.txtZipCode){
                             self.view.frame=CGRectMake(self.view.frame.origin.x, -170, self.view.frame.size.width, self.view.frame.size.height);//31,152,207
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
        
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = self.view.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
    
    
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
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMarketplace" object:self];
                                  //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [AlertView showAlertWithMessage:@"You Post have successfully posted." view:self];
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
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMarketplace" object:self];
                                      //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [AlertView showAlertWithMessage:@"You Post have successfully posted." view:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                                  
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
    
}

-(void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

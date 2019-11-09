//
//  EditPostViewController.m
//  iBlah-Blah
//
//  Created by Arun on 03/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "EditPostViewController.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#import "AllFrndViewController.h"

@interface EditPostViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSArray *arryImages;
    NSString *tagedName;
    NSString *tagedUserId;
}

@end

@implementation EditPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tagedName=@"";
    tagedUserId=@"";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AddTagedFrnd"
                                               object:nil];
    
    
    NSLog(@"dict post %@",_dictPost);
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[_dictPost objectForKey:@"image"]];
    _imgUser.imageURL=[NSURL URLWithString:strUrl];
    
    const char *jsonString = [[_dictPost objectForKey:@"discription"] UTF8String];
    NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    _txtStatus.text=msg;//[_dictPost objectForKey:@"discription"];
    NSString *strImageList=[_dictPost objectForKey:@"images"];
    if(![strImageList isEqualToString:@""])
    {
        NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
        arryImages=arryImageList;
    }
    _txtStatus.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _txtStatus.layer.borderWidth=1;
    _lblUserName.text=[_dictPost objectForKey:@"name"];

    [_tblImages reloadData];

    self.title=@"Edit Post";
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Done" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 50, 13);
    
    [btnClear addTarget:self action:@selector(cmdDone:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdd setTitle:@"Add" forState:UIControlStateNormal];
    btnAdd.frame = CGRectMake(0, 0, 50, 13);
    
    [btnAdd addTarget:self action:@selector(cmdAdd:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
     UIBarButtonItem *btnSearchBar1 = [[UIBarButtonItem alloc] initWithCustomView:btnAdd];
    [arrRightBarItems addObject:btnSearchBar];
    [arrRightBarItems addObject:btnSearchBar1];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------------- Table View Delegate Methods ------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryImages.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return SCREEN_SIZE.width/2+50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    
    UIImageView *banner=[[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/2)/2, 0,SCREEN_SIZE.width/2,SCREEN_SIZE.width/2)];
//    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//    banner.showActivityIndicator=YES;
//    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        //  baseUrl + "thumb/" + image_name
    id img=[arryImages objectAtIndex:indexPath.row];
    if([img isKindOfClass:[NSString class]] == YES){
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImages[indexPath.row]];
        banner.imageURL=[NSURL URLWithString:strUrl];

        [banner sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"picPlaceHolder"]];

    }else{
        banner.image=img;
    }
   
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
  
    UIButton *btnDelete=[[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(banner.frame)+5, 50, 32)];
    [btnDelete setTitle:[NSString stringWithFormat:@"Delete"] forState:UIControlStateNormal];
    btnDelete.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnDelete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnDelete.layer.cornerRadius=8;//0,160,223
    btnDelete.layer.borderWidth=1;
    btnDelete.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnDelete.tag=indexPath.row;
    [cell.contentView addSubview:btnDelete];
    [btnDelete addTarget:self
                  action:@selector(cmdDeleteImage:)
        forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)cmdDeleteImage:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSMutableArray *temp=[arryImages mutableCopy];
    [temp removeObjectAtIndex:btn.tag];
    arryImages=temp;
    [_tblImages reloadData];
    
}
-(void)cmdDone:(id)sender{
    if([_txtStatus.text isEqualToString:@""]&&arryImages.count==0){
        [AlertView showAlertWithMessage:@"Nothing to post" view:self];
        return;
    }
    [self uploadMultipleImageInSingleRequest];
}
-(void)cmdAdd:(id)sender{
    
    
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
    if(arryImages.count<10){
        UIAlertAction* button1 = [UIAlertAction
                                  actionWithTitle:@"Take a photo"
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
                                  actionWithTitle:@"Choose existing"
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
        [alert addAction:button1];
        [alert addAction:button2];
        
    }
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Tag Friend"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Choose existing"
                                  
                                  AllFrndViewController *R2VC = [[AllFrndViewController alloc]initWithNibName:@"AllFrndViewController" bundle:nil];
                                  [self.navigationController pushViewController:R2VC animated:YES];
                              }];
    [alert addAction:button0];
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
     NSMutableArray *temp=[arryImages mutableCopy];
    [temp addObject:chosenImage];
    arryImages=temp;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_tblImages reloadData];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"AddTagedFrnd"]) {//
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
            _txtStatus.text = @"";
            _txtStatus.textColor = [UIColor blackColor];
        }
        
        tagedName=@"";
        tagedUserId=@"";
        if(Arr.count==1){
            NSDictionary *dict=[Arr objectAtIndex:0];
            NSString *strName=[dict objectForKey:@"name"];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *Username = [prefs stringForKey:@"username"];
            _lblUserName.text=[NSString stringWithFormat:@"%@ is with %@",Username,strName];
        }else if (Arr.count==2){
            NSDictionary *dict=[Arr objectAtIndex:0];
            NSString *strName=[dict objectForKey:@"name"];
            NSDictionary *dict1=[Arr objectAtIndex:1];
            NSString *strName1=[dict1 objectForKey:@"name"];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *Username = [prefs stringForKey:@"username"];
            _lblUserName.text=[NSString stringWithFormat:@"%@ is with %@ and %@",Username,strName,strName1];
        }else{
            if(Arr.count>2){
                NSDictionary *dict=[Arr objectAtIndex:0];
                NSString *strName=[dict objectForKey:@"name"];
                NSDictionary *dict1=[Arr objectAtIndex:1];
              //  NSString *strName1=[dict1 objectForKey:@"name"];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *Username = [prefs stringForKey:@"username"];
                int count=Arr.count;
                count=count-1;
                _lblUserName.text=[NSString stringWithFormat:@"%@ is with %@ and %d other",Username,strName,count];
            }
        }
        
        for (int i=0; i<Arr.count; i++) {//user_id
            NSDictionary *dict=[Arr objectAtIndex:i];
            NSString *strUserId=[dict objectForKey:@"user_id"];
            NSString *strName=[dict objectForKey:@"name"];
            if([tagedUserId isEqualToString:@""]){
                tagedUserId=strUserId;
            }else{
                tagedUserId=[NSString stringWithFormat:@"%@,%@",tagedUserId,strUserId];
            }
            
            if([tagedName isEqualToString:@""]){
                tagedName=strName;
            }else{
                tagedName=[NSString stringWithFormat:@"%@,%@",tagedName,strName];
            }
            
        }
        
    }
}
- (void)uploadMultipleImageInSingleRequest
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    NSString *strDescription=_txtStatus.text;
    if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
        _txtStatus.text = @"";
        strDescription=@"";
        _txtStatus.textColor = [UIColor blackColor];
    }
    
    NSMutableDictionary *dictParm=[[NSMutableDictionary alloc]init];
    
    NSString *strPreLodedImg=@"";
    
    for (int i=0; i<arryImages.count; i++) {
        id img=[arryImages objectAtIndex:i];
        if([img isKindOfClass:[NSString class]] == YES){
            if([strPreLodedImg isEqualToString:@""]){
                strPreLodedImg=arryImages[i];
            }else{
                strPreLodedImg=[NSString stringWithFormat:@"%@,%@",strPreLodedImg,arryImages[i]];
            }
        }else{
           
        }
    }
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    [dictParm setValue:strPost_id forKey:@"post_id"];
    [dictParm setValue:strPreLodedImg forKey:@"pre_loaded_images"];
    [dictParm setValue:USERID forKey:@"user_id"];
    [dictParm setValue:@"" forKey:@"title"];
    [dictParm setValue:strDescription forKey:@"discription"];
    [dictParm setValue:@"Public" forKey:@"posttype"];
    [dictParm setValue:tagedUserId forKey:@"tagFriends"];
 
        [dictParm setValue:@"" forKey:@"location"];
        [dictParm setValue:@"" forKey:@"lat"];
        [dictParm setValue:@"" forKey:@"lon"];
    
        //0 for image //2 for location // 3 link k lea
        [dictParm setValue:@"0" forKey:@"type"];
    
    
    [dictParm setValue:@"ios" forKey:@"device"];
    [dictParm setValue:appDelegate().Country forKey:@"country"];
    [dictParm setValue:@"" forKey:@"link"];
    
    
    
    
    NSDictionary *aParametersDic=dictParm; // It's contains other parameters.
    NSString *urlString; // an url where the request to be posted
    urlString = [NSString stringWithFormat:@ADDPOST];//USERID
    
    urlString=[NSString stringWithFormat:@"%@action=editNewPost",urlString];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:aParametersDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        
        for (int i=0; i<arryImages.count; i++) {
            id img=[arryImages objectAtIndex:i];
            if([img isKindOfClass:[NSString class]] == YES){
            }else{
                NSData *imageData = UIImageJPEGRepresentation(img,0.9);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%d",i ] fileName:[NSString stringWithFormat:@"file%d.png",i ] mimeType:@"image/png"];
            }
        }
        
       
        
    } error:nil];
    [upload_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [upload_request setHTTPShouldHandleCookies:NO];
    [upload_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        // [upload_request setHTTPBody:postData];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];


    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

//    manager.responseSerializer = [AFHTTPResponseSerializer setValue:"application/json" forKey:"Content-Type"];

//    manager.responseSerializer.acceptableContentTypes=[NSSet setWithObject:@"application/json"];

//    [upload_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
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
                              id jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              
                              if (error != nil) {
                                  NSLog(@"Error parsing JSON.");
                                  [ind removeFromSuperview];
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                              }
                              else {
                                  [ind removeFromSuperview];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePost" object:self];
                                      //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
                                  [AlertView showAlertWithMessage:@"You Post have edited successfully." view:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:1.5];
                                  
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
    
}
-(void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end

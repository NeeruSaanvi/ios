//
//  AddPostViewController.m
//  iBlah-Blah
//
//  Created by Arun on 27/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddPostViewController.h"
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#import "CurrentLocationViewController.h"
#import "AllFrndViewController.h"
#import "AddPostImageCollectionViewCell.h"

#define OVERLAY_VIEW_TAG 121212121
@interface AddPostViewController ()<UITextViewDelegate,DLFPhotosPickerViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSMutableArray *arrImage;
    CLLocationCoordinate2D coordinates;
    MKMapView *mapView;
    BOOL linkPost;
    BOOL imgPost;
    BOOL locationPost;
    NSString *strlink;
    NSString *addrsss;
    NSDictionary *locationInfo;
    NSString *postType;
    NSString *tagedName;
    NSString *tagedUserId;
}
@property(nonatomic, weak) IBOutlet UICollectionView * collectionViewPostImages;
@end

@implementation AddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionViewPostImages registerNib:[UINib nibWithNibName:@"AddPostImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"postImage"];

    linkPost=NO;
    imgPost=NO;
    locationPost=NO;
    strlink=@"";
    tagedName=@"";
    tagedUserId=@"";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *profilePic = [prefs stringForKey:@"profile_pic"];
    NSString *Username = [prefs stringForKey:@"username"];

    _lblUserName.text=Username;
    _imgUser.layer.cornerRadius=30;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,profilePic];
    _imgUser.imageURL=[NSURL URLWithString:strUrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"SendLocation"
                                               object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AddTagedFrnd"
                                               object:nil];
    _txtStatus.text = @"Whats on your mind";
    _txtStatus.textColor = [UIColor lightGrayColor];
    _txtStatus.delegate = self;
    _txtStatus.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _txtStatus.layer.borderWidth=1;
    _viewAction.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _viewAction.layer.borderWidth=1;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(viewDown)],
                           nil];
    [numberToolbar sizeToFit];
    self.txtStatus.inputAccessoryView = numberToolbar;
    self.title=@"Add Post";
    
    arrImage=[[NSMutableArray alloc]init];
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Done" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 50, 13);
    
    [btnClear addTarget:self action:@selector(cmdDone:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
    if(_postImage){
        if(arrImage.count>9){
            [arrImage removeObjectAtIndex:0];
        }
        [arrImage addObject:_postImage];
        [self addImage];
    }
    
    if(_dictLocation){
        NSDictionary *userInfo =_dictLocation;
        if(addrsss.length>0){
          //  NSString *add=[NSString stringWithFormat:@"\n%@",addrsss];
            _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:addrsss withString:@""];
        }
        locationInfo=userInfo;
        addrsss=[userInfo   objectForKey:@"address"];
        if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
            _txtStatus.text = @"";
            _txtStatus.textColor = [UIColor blackColor];
        }
        _txtStatus.text=[NSString stringWithFormat:@"%@\n%@",_txtStatus.text,addrsss];
        locationPost=YES;
    }
}
- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"SendLocation"]) {//AddTagedFrnd
         NSDictionary *userInfo = notification.userInfo;
        if(addrsss.length>0){
            //NSString *add=[NSString stringWithFormat:@"\n%@",addrsss];
            _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:addrsss withString:@""];
        }
        locationInfo=userInfo;
        addrsss=[userInfo   objectForKey:@"address"];
        if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
            _txtStatus.text = @"";
            _txtStatus.textColor = [UIColor blackColor];
        }
        if([tagedName isEqualToString:@""]){
        _txtStatus.text=[NSString stringWithFormat:@"%@\n%@",_txtStatus.text,addrsss];
        }else{
            _txtStatus.text=[NSString stringWithFormat:@"%@\n%@",_txtStatus.text,addrsss];
        }
        locationPost=YES;
    }else if ([[notification name] isEqualToString:@"AddTagedFrnd"]) {//
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
                NSString *strName1=[dict1 objectForKey:@"name"];
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

-(void)cmdDone:(id)sender{
   
    if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
        if(!(linkPost) && !(linkPost) && !(imgPost)){
            [AlertView showAlertWithMessage:@"Nothing to post" view:self];
            return;
        }
        
    }
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:@"To whom you want to show this post ?"
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                      //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                 postType=@"1";
                                   [self uploadMultipleImageInSingleRequest];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Public"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Choose existing"
                                 postType=@"0";
                                   [self uploadMultipleImageInSingleRequest];
                              }];
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"FriendsOfFriends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                   postType=@"2";
                                   [self uploadMultipleImageInSingleRequest];
                                      //  The user tapped on "Choose existing"
                                
                              }];
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Private"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Choose existing"
                                  postType=@"3";
                                   [self uploadMultipleImageInSingleRequest];
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
    
    
   
   // [self uploadImage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDown{
    [self.view endEditing:YES];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
        _txtStatus.text = @"";
        _txtStatus.textColor = [UIColor blackColor];
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(_txtStatus.text.length == 0){
        _txtStatus.textColor = [UIColor lightGrayColor];
        _txtStatus.text = @"Whats on your mind";
        [_txtStatus resignFirstResponder];
    }
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(_txtStatus.text.length == 0){
        _txtStatus.textColor = [UIColor lightGrayColor];
        _txtStatus.text = @"Whats on your mind";
        [_txtStatus resignFirstResponder];
    }
    return YES;
}
- (IBAction)cmdCamera:(id)sender {
    
    if(linkPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your link post will be overridden"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        linkPost=NO;
                                        NSString *strLin=[NSString stringWithFormat:@"\n%@",strlink];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:strLin withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                        imagePickerController.delegate = self;
                                         imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                        [self presentViewController:imagePickerController animated:YES completion:^{}];
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
    }else if(locationPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your location post will be overridden."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        locationPost=NO;
                                        NSString *strLin=[NSString stringWithFormat:@"\n%@",addrsss];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:strLin withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        
                                        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                        imagePickerController.delegate = self;
                                         imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                        [self presentViewController:imagePickerController animated:YES completion:^{}];
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
    }else{
        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
         imagePickerController.navigationBar.tintColor = [UIColor blackColor];
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
  
}

- (IBAction)cmdGalary:(id)sender {
    if(linkPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your link post will be overridden"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        linkPost=NO;
                                        NSString *strLin=[NSString stringWithFormat:@"\n%@",strlink];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:strLin withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
                                        [photosPicker setPhotosPickerDelegate:self];
                                        [photosPicker setMultipleSelections:YES];
                                        [self presentViewController:photosPicker animated:YES completion:nil];
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
    }else if(locationPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your location post will be overridden."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        locationPost=NO;
                                        NSString *strLin=[NSString stringWithFormat:@"\n%@",addrsss];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:strLin withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        
                                        
                                        DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
                                        [photosPicker setPhotosPickerDelegate:self];
                                        [photosPicker setMultipleSelections:YES];
                                        [self presentViewController:photosPicker animated:YES completion:nil];
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
    }else{
        DLFPhotosPickerViewController *photosPicker = [[DLFPhotosPickerViewController alloc] init];
        [photosPicker setPhotosPickerDelegate:self];
        [photosPicker setMultipleSelections:YES];
        [self presentViewController:photosPicker animated:YES completion:nil];
    }
    
}

- (IBAction)cmdLocation:(id)sender {
    
    if(linkPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your link post will be overridden"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        linkPost=NO;
                                        NSString *strLin=[NSString stringWithFormat:@"\n%@",strlink];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:strLin withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        CurrentLocationViewController *R2VC = [[CurrentLocationViewController alloc]initWithNibName:@"CurrentLocationViewController" bundle:nil];
                                        
                                        [self.navigationController pushViewController:R2VC animated:YES];
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
    }else if(imgPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your picture post will be overridden."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        imgPost=NO;
                                        [arrImage removeAllObjects];
                                        arrImage=nil;
                                        arrImage=[[NSMutableArray alloc]init];
                                        [self addImage];
                                        
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:addrsss withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        
                                        CurrentLocationViewController *R2VC = [[CurrentLocationViewController alloc]initWithNibName:@"CurrentLocationViewController" bundle:nil];
                                        [self.navigationController pushViewController:R2VC animated:YES];
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
    }else{
        CurrentLocationViewController *R2VC = [[CurrentLocationViewController alloc]initWithNibName:@"CurrentLocationViewController" bundle:nil];
        [self.navigationController pushViewController:R2VC animated:YES];
    }
    
   
}

- (IBAction)cmdLink:(id)sender {
    if(locationPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your Location post will be overridden"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        locationPost=NO;
                                        NSString *add=[NSString stringWithFormat:@"\n%@",addrsss];
                                        _txtStatus.text=[_txtStatus.text stringByReplacingOccurrencesOfString:add withString:@""];
                                        if ( !(_txtStatus.text.length>0)) {
                                            _txtStatus.text = @"Whats on your mind";
                                            _txtStatus.textColor = [UIColor lightGrayColor];
                                        }
                                        
                                        [self performSelector:@selector(addLink) withObject:nil afterDelay:1.5];
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
    }else if(imgPost){
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Attention!"
                                     message:@"Your picture post will be overridden."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
            //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Are you sure ?"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                        imgPost=YES;
                                        
                                        imgPost=NO;
                                        [arrImage removeAllObjects];
                                        arrImage=nil;
                                        arrImage=[[NSMutableArray alloc]init];
                                        [self addImage];
                                        [self performSelector:@selector(addLink) withObject:nil afterDelay:1.5];
                                       
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
    }else{
        [self addLink];
    }
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
            if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
                _txtStatus.text = @"";
                _txtStatus.textColor = [UIColor blackColor];
            }
            linkPost=YES;
            strlink=namefield.text;
            if([tagedName isEqualToString:@""]){
               _txtStatus.text=[NSString stringWithFormat:@"%@\n%@",_txtStatus.text,namefield.text];
            }else{
                 _txtStatus.text=[NSString stringWithFormat:@"%@\n%@",_txtStatus.text,namefield.text];
                
            }
           
        }else{
            [AlertView showAlertWithMessage:@"Url is not correct" view:self];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        

    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}
- (IBAction)cmdPostOption:(id)sender {
    
  
}
#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
  //  chosenImage=[self rotateUIImage:chosenImage clockwise:YES];
    
    if(arrImage.count>9){
        [arrImage removeObjectAtIndex:0];
    }
    chosenImage=[self compressImage:chosenImage];
    [arrImage addObject:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self addImage];
}
- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:2.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.width ,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
//    for (UIView *view in self.scrollView.subviews) {
//        [view removeFromSuperview];
//    }

    for (PHAsset *asset in images) {
        if(arrImage.count>9){
            [arrImage removeObjectAtIndex:0];
        }

        
        PHImageRequestOptions *option = [PHImageRequestOptions new];
        option.synchronous = YES;
        
        
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            
            UIImage *imgCompressed=[self compressImage:result];
            [arrImage addObject:imgCompressed];
             [self addImage];
            
        }];
    }
   
}

-(void)addImage{
dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionViewPostImages reloadData];
});
//
//    for (UIView *view in self.scrollView.subviews) {
//        [view removeFromSuperview];
//    }
//
//    CGSize imageViewSize = CGSizeMake(self.scrollView.frame.size.height, self.scrollView.frame.size.height);
//    CGRect previousRect = CGRectMake(-imageViewSize.width, 0, imageViewSize.width, imageViewSize.height);
//    CGFloat maxX = 0;
//
//    for (int i=0; i<arrImage.count; i++) {
//        UIImageView *imageView = [[UIImageView alloc] init];
//        [imageView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.frame = CGRectOffset(previousRect, imageViewSize.width + 10, 0);
//        [self.scrollView addSubview:imageView];
//        previousRect = imageView.frame;
//        maxX = CGRectGetMaxX(imageView.frame);
//        UIImage *img=arrImage[i];
//        [imageView setImage:img];
//    }
    if(arrImage.count>0){
        imgPost=YES;
    }
//    [self.scrollView setContentSize:CGSizeMake(maxX, imageViewSize.height)];

}


- (void)uploadMultipleImageInSingleRequest
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
//    IndecatorView *ind=[[IndecatorView alloc]init];
//    [self.view addSubview:ind];
    NSString *strDescription=_txtStatus.text;
    if([_txtStatus.text isEqualToString:@"Whats on your mind"]){
        _txtStatus.text = @"";
        strDescription=@"";
        _txtStatus.textColor = [UIColor blackColor];
    }
    NSString *uniText = [NSString stringWithUTF8String:[strDescription UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    strDescription = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];

    NSMutableDictionary *dictParm=[[NSMutableDictionary alloc]init];
    [dictParm setValue:USERID forKey:@"user_id"];
    [dictParm setValue:@"" forKey:@"title"];
    [dictParm setValue:strDescription forKey:@"discription"];
    [dictParm setValue:@"Public" forKey:@"posttype"];
    [dictParm setValue:tagedUserId forKey:@"tagFriends"];
    if(locationPost){
        [dictParm setValue:[locationInfo objectForKey:@"address"] forKey:@"location"];
        [dictParm setValue:[locationInfo objectForKey:@"lat"] forKey:@"lat"];
        [dictParm setValue:[locationInfo objectForKey:@"lon"] forKey:@"lon"];
    }else{
        [dictParm setValue:@"" forKey:@"location"];
        [dictParm setValue:@"" forKey:@"lat"];
        [dictParm setValue:@"" forKey:@"lon"];
    }
   //0 for image //2 for location // 3 link k lea
    if(linkPost){
         [dictParm setValue:@"3" forKey:@"type"];
    }else if (locationPost){
         [dictParm setValue:@"2" forKey:@"type"];
    }else{
         [dictParm setValue:@"0" forKey:@"type"];
    }
   
    [dictParm setValue:@"ios" forKey:@"device"];
    [dictParm setValue:appDelegate().Country forKey:@"country"];
    if(strlink){
         [dictParm setValue:strlink forKey:@"link"];
    }else{
         [dictParm setValue:@"" forKey:@"link"];
    }
   if([_fromPage isEqualToString:@"EVENT"]){
       [dictParm setValue:[_dictFromPage objectForKey:@"post_id"] forKey:@"group_id"];
   }
    if([_fromPage isEqualToString:@"GROUP"]){
        [dictParm setValue:[_dictFromPage objectForKey:@"id"] forKey:@"group_id"];
    }
    
    
    NSDictionary *aParametersDic=dictParm; // It's contains other parameters.
    NSString *urlString; // an url where the request to be posted
   
    //USERID
    
    
    if([_fromPage isEqualToString:@"EVENT"]){
        urlString = [NSString stringWithFormat:@ADDGROUP];
        urlString=[NSString stringWithFormat:@"%@?action=addNewEventPost",urlString];
    }else  if([_fromPage isEqualToString:@"GROUP"]){
        urlString = [NSString stringWithFormat:@ADDGROUP];
        urlString=[NSString stringWithFormat:@"%@?action=addNewPost",urlString];
    }
    else{
        urlString = [NSString stringWithFormat:@ADDPOST];
        urlString=[NSString stringWithFormat:@"%@action=addNewPost",urlString];
    }
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:aParametersDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        int i=0;
        for(UIImage *eachImage in arrImage)
        {
            NSData *imageData = UIImageJPEGRepresentation(eachImage,0.5);
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
                              [SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Please wait.."];
                              NSLog(@"%f",uploadProgress.fractionCompleted);//Log the progress or pass it to progressview
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          [SVProgressHUD dismiss];
                          if (error) {
                              NSLog(@"OOPS!!!! %@", error);
                              
//                              [ind removeFromSuperview];
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
//                              [ind removeFromSuperview];
//                              NSError *error = nil;
//                              NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
//
//                              if (error != nil) {
//                                  NSLog(@"Error parsing JSON.");
//                                  [ind removeFromSuperview];
//                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
//                              }
//                              else {
//                                  [ind removeFromSuperview];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePost" object:self];
                                      //  self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]];
//                                  [AlertView showAlertWithMessage:@"You Post have successfully posted." view:self];
                                  [self performSelector:@selector(back) withObject:nil afterDelay:0];
                                  
                            //  }
                          }
                      }];
    
    [uploadFileTask resume];

    
}
-(void)back{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL) validateUrl: (NSString *) candidate {
    
    NSURL *url = [NSURL URLWithString:candidate];

    if (url && url.scheme && url.host) {
        return YES;
    }

    return NO;
}

- (IBAction)cmdTag:(id)sender {
    AllFrndViewController *R2VC = [[AllFrndViewController alloc]initWithNibName:@"AllFrndViewController" bundle:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
}

-(UIImage *)compressImage:(UIImage *)image{
    NSData *imgData = UIImageJPEGRepresentation(image, 1); //1 it represents the quality of the image.
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imgData length]);
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 1;//70 percent compression
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
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imageData length]);
    return [UIImage imageWithData:imageData];
}



#pragma mark collectionview delegate

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrImage.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"postImage";

    AddPostImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
//    if (cell == nil) {
        //    NSArray *nib;
        //        nib = [[NSBundle mainBundle] loadNibNamed:@"HomeFeedCustomCell" owner:self options:nil];
        //        cell = [nib objectAtIndex:1];

//        cell = (AddPostImageCollectionViewCell *)[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:identifier];

        //        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
//    }

    cell.imgPostImage.image = [arrImage objectAtIndex:indexPath.row];

//    NSString *strImageList=[dict objectForKey:@"images"];
//    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
//
//    NSInteger index = indexPath.row;
//    //    if(indexPath.row == arryImageList.count )
//    //    {
//    //        index = index -1;
//    //    }
//
//    NSString *imageName = [arryImageList objectAtIndex:index];
//
//    NSString * strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,imageName];
//
//    [cell.postImage sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil options:0];
//
//    if(arryImageList.count > 5 && indexPath.row == 3 )
//    {
//        cell.view5Plus.hidden = NO;
//    }
//    else
//    {
//        cell.view5Plus.hidden = YES;
//    }

    return cell;

}



@end

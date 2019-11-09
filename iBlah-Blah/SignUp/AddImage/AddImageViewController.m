//
//  AddImageViewController.m
//  iBlah-Blah
//
//  Created by webHex on 20/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AddImageViewController.h"
#import "PrivacyPolicyViewController.h"
#import "SignUpViewController.h"
@interface AddImageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation AddImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _btnLoad.layer.cornerRadius=25;
    _imgUserImage.layer.cornerRadius=45;
    _imgUserImage.clipsToBounds=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cmdLoad:(id)sender {
    if(([self firstimage:[UIImage imageNamed:@"defaultUser"] isEqualTo:_imgUserImage.image])){
        [AlertView showAlertWithMessage:@"User Image is compulsory." view:self];
        return;
    }else{
        SignUpViewController *cont=[[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil];
        cont.imgAvtar=_imgUserImage.image;
        [self.navigationController pushViewController:cont animated:YES];
    }

}
- (IBAction)cmdLogin:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cmdPrivacyPolicy:(id)sender {
    PrivacyPolicyViewController *cont=[[PrivacyPolicyViewController alloc]initWithNibName:@"PrivacyPolicyViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}

- (IBAction)cmdGetImage:(id)sender {
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


#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    chosenImage=[self compressImage:chosenImage];
    _imgUserImage.image=chosenImage;
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

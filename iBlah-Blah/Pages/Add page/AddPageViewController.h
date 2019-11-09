//
//  AddPageViewController.h
//  iBlah-Blah
//
//  Created by Arun on 17/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPageViewController : BaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgPage;
@property (weak, nonatomic) IBOutlet UITextField *txtPageName;
@property (weak, nonatomic) IBOutlet UITextView *txtPageInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedCategory;
- (IBAction)cmdAddImage:(id)sender;

- (IBAction)cmdSelectCategory:(id)sender;
@end

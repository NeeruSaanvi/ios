//
//  AddGroupViewController.h
//  iBlah-Blah
//
//  Created by Arun on 17/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupViewController : BaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet AsyncImageView *imgGroup;
@property (weak, nonatomic) IBOutlet UITextField *txtGroupName;
@property (weak, nonatomic) IBOutlet UITextView *txtGroupInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedCategory;
- (IBAction)cmdAddImage:(id)sender;
- (IBAction)cmdAddFriends:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *frndScroll;
- (IBAction)cmdSelectCategory:(id)sender;


@property (strong, nonatomic)NSArray *arrMember;
@property (strong, nonatomic)NSArray *arryInfo;
@end

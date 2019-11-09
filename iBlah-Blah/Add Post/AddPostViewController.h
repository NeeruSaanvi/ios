//
//  AddPostViewController.h
//  iBlah-Blah
//
//  Created by Arun on 27/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPostViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextView *txtStatus;
@property (weak, nonatomic) IBOutlet UIView *viewAction;
- (IBAction)cmdCamera:(id)sender;
- (IBAction)cmdGalary:(id)sender;
- (IBAction)cmdLocation:(id)sender;
- (IBAction)cmdLink:(id)sender;
- (IBAction)cmdPostOption:(id)sender;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImage *postImage;
@property (strong, nonatomic) NSDictionary *dictLocation;
- (IBAction)cmdTag:(id)sender;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (strong, nonatomic) NSString *fromPage;
@property (strong, nonatomic) NSDictionary *dictFromPage;
@end

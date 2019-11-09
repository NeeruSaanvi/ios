//
//  AddImageViewController.h
//  iBlah-Blah
//
//  Created by webHex on 20/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddImageViewController : UIViewController
- (IBAction)cmdLoad:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLoad;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserImage;
- (IBAction)cmdLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)cmdPrivacyPolicy:(id)sender;
- (IBAction)cmdGetImage:(id)sender;

@end

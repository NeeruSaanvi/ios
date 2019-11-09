//
//  AddVideoViewController.h
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddVideoViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *btnSelectVideoUrl;
@property (weak, nonatomic) IBOutlet UIButton *btnUploadVideo;
- (IBAction)cmdSelectVideoUrl:(id)sender;
- (IBAction)cmdUploadVideo:(id)sender;
- (IBAction)cmdCategory:(id)sender;
- (IBAction)cmdPrivacy:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacy;
@property (weak, nonatomic) IBOutlet UITextField *txtVideoTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtTag;


@end

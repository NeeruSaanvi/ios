//
//  EditVideoViewController.h
//  iBlah-Blah
//
//  Created by Arun on 02/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditVideoViewController : BaseViewController
- (IBAction)cmdCategory:(id)sender;
- (IBAction)cmdPrivacy:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacy;
@property (weak, nonatomic) IBOutlet UITextField *txtVideoTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtTag;
@property (weak, nonatomic) IBOutlet AsyncImageView *imgThumb;
@property (strong, nonatomic) NSDictionary *dictVideoData;

@end

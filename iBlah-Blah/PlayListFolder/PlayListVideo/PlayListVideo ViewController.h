//
//  PlayListVideo ViewController.h
//  iBlah-Blah
//
//  Created by webHex on 28/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListVideo_ViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tblPlayListVideo;
@property (weak, nonatomic) NSDictionary *dictPlayListValue;


@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;

- (IBAction)cmdRateCancel:(id)sender;
- (IBAction)cmdRateNow:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRateNow;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIView *viewRate;
@property (strong, nonatomic) IBOutlet UIView *viewRateSubView;


@end

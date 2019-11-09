//
//  VideoViewController.h
//  iBlah-Blah
//
//  Created by Arun on 05/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *btnAllVideo;
- (IBAction)cmdAllVideo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMyVideo;
- (IBAction)cmdMyVideo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnFavoriteVideo;
- (IBAction)cmdFavoriteVideo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnWatchLater;
- (IBAction)cmdWatchLater:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAllPlaylist;
- (IBAction)cmdAllPlaylist:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMyPlaylist;
- (IBAction)cmdMyPlaylist:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnHistory;
- (IBAction)cmdHistory:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTable;
@property (weak, nonatomic) IBOutlet UITableView *tblAllVideo;
@property (weak, nonatomic) IBOutlet UITableView *tblMyVideo;
@property (weak, nonatomic) IBOutlet UITableView *tblFavoriteVideo;
@property (weak, nonatomic) IBOutlet UITableView *tblWatchLater;
@property (weak, nonatomic) IBOutlet UITableView *tblAllPlaylist;
@property (weak, nonatomic) IBOutlet UITableView *tblMyPlaylist;
@property (weak, nonatomic) IBOutlet UITableView *tblHistory;

@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;


@property (weak, nonatomic) IBOutlet HCSStarRatingView *starView;

- (IBAction)cmdRateCancel:(id)sender;
- (IBAction)cmdRateNow:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnRateNow;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIView *viewRate;
@property (strong, nonatomic) IBOutlet UIView *viewRateSubView;


@end

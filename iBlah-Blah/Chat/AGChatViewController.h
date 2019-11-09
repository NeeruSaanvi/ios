//
//  AGChatViewController.h
//  AGChatView
//
//  Created by Ashish Gogna on 09/04/16.
//  Copyright © 2016 Ashish Gogna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AGChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>

//IBOutlets
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITableView *tblForward;
@property (strong, nonatomic) NSDictionary *dictChatData;
- (IBAction)cmdRemoveForwardView:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *forwardView;
@property (strong, nonatomic) NSArray *reasentChat;

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
- (IBAction)playTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)recordPauseTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIView *recordSubView;
- (IBAction)cmdRemoveAudio:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
- (IBAction)cmdReset:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordTime;
@property (strong, nonatomic) IBOutlet UIView *playAudioView;
@property (weak, nonatomic) IBOutlet UIView *playAudioSubView;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *currentTimeSlider;



@property (weak, nonatomic) IBOutlet UIButton *playButton1;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton1;
- (IBAction)cmdRemovePlayAudio:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)currentTimeSliderValueChanged:(id)sender;
- (IBAction)currentTimeSliderTouchUpInside:(id)sender;
@end

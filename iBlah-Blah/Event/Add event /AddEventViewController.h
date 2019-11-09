//
//  AddEventViewController.h
//  iBlah-Blah
//
//  Created by Arun on 18/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtEventName;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
- (IBAction)cmdStartingDate:(id)sender;
- (IBAction)cmdStartingTime:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblStartingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblStartingTime;
- (IBAction)cmdEndingDate:(id)sender;
- (IBAction)cmdEndingTime:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblEndingDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEndingTime;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
- (IBAction)cmdCatogary:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCatogary;
- (IBAction)cmdPrivacy:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgMain;
- (IBAction)cmdMainImage:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacy;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView1;
@property (weak, nonatomic) IBOutlet UIImageView *mapViewImage;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) NSString *strFrom;
@property (strong, nonatomic) NSDictionary *dictGroupData;

- (IBAction)cmdAddVideo:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewVideo;


@end

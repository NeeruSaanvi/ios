//
//  AttendingViewController.h
//  iBlah-Blah
//
//  Created by webHex on 13/07/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblAttending;
@property (strong,nonatomic) NSDictionary *dictPost;
@property (weak, nonatomic) IBOutlet UISegmentedControl *btnSegment;
- (IBAction)cmdSegment:(id)sender;
- (IBAction)cmdValueChanged:(id)sender;

@end

//
//  EventViewController.h
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : BaseViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITableView *tblEvent;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (weak, nonatomic) IBOutlet UITableView *tblMyEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnMyEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnEvent;
- (IBAction)cmdMyEvent:(id)sender;
- (IBAction)cmdEvent:(id)sender;
@end

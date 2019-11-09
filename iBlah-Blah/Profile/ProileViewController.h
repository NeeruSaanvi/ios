//
//  ProileViewController.h
//  iBlah-Blah
//
//  Created by webHex on 10/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProileViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTable;
@property (weak, nonatomic) IBOutlet UIButton *btnActivity;
@property (weak, nonatomic) IBOutlet UIButton *btnAbout;
@property (weak, nonatomic) IBOutlet UIButton *btnFriends;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotos;
- (IBAction)cmdAbout:(id)sender;
- (IBAction)cmdActivity:(id)sender;
- (IBAction)cmdFriends:(id)sender;
- (IBAction)cmdPhotos:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tblAbout;
@property (weak, nonatomic) IBOutlet UITableView *tblActivity;
@property (weak, nonatomic) IBOutlet UITableView *tblFriends;
@property (weak, nonatomic) IBOutlet UITableView *tblPhotos;
@property (strong, nonatomic) IBOutlet UIView *viewAnimation;
@property (strong, nonatomic) NSDictionary *dictData;
@end

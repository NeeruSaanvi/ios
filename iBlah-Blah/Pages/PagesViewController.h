//
//  PagesViewController.h
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagesViewController : BaseViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (weak, nonatomic) IBOutlet UITableView *tblPages;
@property (weak, nonatomic) IBOutlet UITableView *tblMyPages;
@property (weak, nonatomic) IBOutlet UIButton *btnMyPages;
@property (weak, nonatomic) IBOutlet UIButton *btPages;
- (IBAction)cmdMyPages:(id)sender;
- (IBAction)cmdPages:(id)sender;

@end

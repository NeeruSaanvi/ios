//
//  GroupViewController.h
//  iBlah-Blah
//
//  Created by webHex on 23/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : BaseViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITableView *tblGroup;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (weak, nonatomic) IBOutlet UITableView *tblMyGroup;
@property (weak, nonatomic) IBOutlet UIButton *btnMyGroup;
@property (weak, nonatomic) IBOutlet UIButton *btnGroup;
- (IBAction)cmdMyGroup:(id)sender;
- (IBAction)cmdGroup:(id)sender;

@end

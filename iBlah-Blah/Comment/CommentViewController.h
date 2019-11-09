//
//  CommentViewController.h
//  iBlah-Blah
//
//  Created by Arun on 30/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : BaseViewController

@property (nonatomic, strong)NSDictionary *dictPost;
@property (weak, nonatomic) IBOutlet UITableView *tblComment;
- (IBAction)cmdBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewHeadder;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadder;

@property (nonatomic, strong)NSString *fromProfile;
@end

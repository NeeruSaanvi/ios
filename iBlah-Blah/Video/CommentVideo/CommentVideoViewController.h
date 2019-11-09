//
//  CommentVideoViewController.h
//  iBlah-Blah
//
//  Created by Arun on 06/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentVideoViewController : BaseViewController
@property (nonatomic, strong)NSDictionary *dictPost;
@property (weak, nonatomic) IBOutlet UITableView *tblComment;
- (IBAction)cmdBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewHeadder;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadder;

@end

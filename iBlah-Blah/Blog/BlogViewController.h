//
//  BlogViewController.h
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogViewController : BaseViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITableView *tblBlog;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (weak, nonatomic) IBOutlet UITableView *tblMyBlog;
@property (weak, nonatomic) IBOutlet UIButton *btnMyBlog;
@property (weak, nonatomic) IBOutlet UIButton *btnBlog;
- (IBAction)cmdMyBlog:(id)sender;
- (IBAction)cmdBlog:(id)sender;
@end

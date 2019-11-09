//
//  EditPostViewController.h
//  iBlah-Blah
//
//  Created by Arun on 03/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPostViewController : BaseViewController
@property (weak, nonatomic) IBOutlet AsyncImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UITextView *txtStatus;
@property (weak, nonatomic) IBOutlet UITableView *tblImages;
@property (strong, nonatomic) NSDictionary *dictPost;
@end

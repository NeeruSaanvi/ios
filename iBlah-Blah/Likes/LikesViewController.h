//
//  LikesViewController.h
//  iBlah-Blah
//
//  Created by webHex on 12/07/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblLikes;
@property (strong,nonatomic) NSDictionary *dictPost;

@end

//
//  PlayListFolderViewController.h
//  iBlah-Blah
//
//  Created by webHex on 28/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayListFolderViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblPlaylist;
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (weak, nonatomic) NSDictionary *dictVideoData;


@end

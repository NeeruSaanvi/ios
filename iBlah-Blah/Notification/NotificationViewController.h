//
//  NotificationViewController.h
//  iBlah-Blah
//
//  Created by webHex on 06/06/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tblNotification;
- (IBAction)cmdClearAll:(id)sender;

@end

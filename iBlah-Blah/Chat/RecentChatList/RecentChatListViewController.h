//
//  RecentChatListViewController.h
//  iBlah-Blah
//
//  Created by webHex on 13/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentChatListViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *chatList;
@property (strong, nonatomic) NSString *strFromMarketPlace;
@property (nonatomic, strong)NSDictionary *dictPost;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

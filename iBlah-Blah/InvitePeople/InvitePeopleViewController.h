//
//  InvitePeopleViewController.h
//  iBlah-Blah
//
//  Created by webHex on 08/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitePeopleViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tblInvite;
@end

//
//  AllFrndViewController.h
//  iBlah-Blah
//
//  Created by Arun on 02/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllFrndViewController : BaseViewController
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tblFrnd;

@end

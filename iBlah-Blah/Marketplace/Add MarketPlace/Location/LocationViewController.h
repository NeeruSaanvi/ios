//
//  LocationViewController.h
//  iBlah-Blah
//
//  Created by Arun on 24/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tblLocation;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic)NSString *strSelectedCountry;
@end

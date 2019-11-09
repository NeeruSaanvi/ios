//
//  MarketplaceViewController.h
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarketplaceViewController : BaseViewController<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITableView *tblAllListing;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (weak, nonatomic) IBOutlet UITableView *tblMyListing;
@property (weak, nonatomic) IBOutlet UIButton *btnAllListing;
@property (weak, nonatomic) IBOutlet UIButton *btnMyListing;
- (IBAction)cmdAllListing:(id)sender;
- (IBAction)cmdMyListing:(id)sender;

@end

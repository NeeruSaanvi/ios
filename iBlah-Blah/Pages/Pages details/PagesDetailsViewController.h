//
//  PagesDetailsViewController.h
//  iBlah-Blah
//
//  Created by Arun on 12/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagesDetailsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewTable;
@property (weak, nonatomic) IBOutlet UIButton *btnInformation;
@property (weak, nonatomic) IBOutlet UIButton *btnActivity;
@property (weak, nonatomic) IBOutlet UIButton *btnEvents;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotos;
- (IBAction)cmdInformation:(id)sender;
- (IBAction)cmdActivity:(id)sender;
- (IBAction)cmdEvents:(id)sender;
- (IBAction)cmdPhotos:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tblInformation;
@property (weak, nonatomic) IBOutlet UITableView *tblActivity;
@property (weak, nonatomic) IBOutlet UITableView *tblEvents;
@property (weak, nonatomic) IBOutlet UITableView *tblPhotos;
@property (strong,nonatomic) NSDictionary *dictPages;
@property (strong, nonatomic) IBOutlet UIView *viewAnimation;
@end

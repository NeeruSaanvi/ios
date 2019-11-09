//
//  EventDetails ViewController.h
//  iBlah-Blah
//
//  Created by Arun on 06/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetails_ViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tblInformation;
@property (weak, nonatomic) IBOutlet UITableView *tblActivity;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIButton *btnInformation;
@property (weak, nonatomic) IBOutlet UIButton *btnActivity;
- (IBAction)cmdInformation:(id)sender;
- (IBAction)cmdActivity:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *SelectedTabanimation;
@property (nonatomic, strong)NSDictionary *dictPost;

@end

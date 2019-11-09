//
//  FMenuViewController.h
//  FootballApp
//
//  Created by Ambika on 22/07/14.
//  Copyright (c) 2014 Manpreet Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
@interface FMenuViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    BOOL chkenable;
    int indxrow;
}
@property (strong, nonatomic) IBOutlet UITableView *menuTbleVw;
@property (strong, nonatomic) IBOutlet UIImageView *bgImgVw;
@property (weak, nonatomic) IBOutlet UIButton *btnback;
- (IBAction)cmdBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indecator;

@end

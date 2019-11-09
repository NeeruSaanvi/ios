//
//  ShareViewController.h
//  iBlah-BlahEX
//
//  Created by webHex on 17/08/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface ShareViewController : UIViewController
- (IBAction)cmdCancle:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tblChat;

@end

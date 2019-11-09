//
//  BaseViewController.h
//  iBlah-Blah
//
//  Created by webHex on 17/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsersDataSource.h"

@interface BaseViewController : UIViewController
@property (strong, nonatomic) UsersDataSource *dataSource;
-(void)sendTextMsg:(NSDictionary *)dict1;
-(void)uploadThumb1:(NSDictionary *)dict;
@end

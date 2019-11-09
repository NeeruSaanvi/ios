//
//  AppDelegate.h
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@class JASidePanelController;
@import SocketIO;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) JASidePanelController *viewController;

@property(nonnull,nonatomic,strong)NSString *str_lat;
@property(nonnull,nonatomic,strong)NSString *str_lang;
@property(nonnull,nonatomic,strong)NSString *Country;
@property(nonnull,nonatomic,strong)NSString *State;
@property(nonnull,nonatomic,strong)NSString *City;
AppDelegate *appDelegate(void);
@property(nonnull,nonatomic,strong)SocketManager*manager;
@property(nonnull,nonatomic,strong)SocketIOClient* socket;
AppDelegate *appDelegate(void);

@end

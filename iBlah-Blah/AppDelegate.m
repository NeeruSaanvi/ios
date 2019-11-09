//
//  AppDelegate.m
//  iBlah-Blah
//
//  Created by webHex on 19/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AppDelegate.h"
#import "JASidePanelController.h"
#import "FMenuViewController.h"
#import "LoginViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "HomeViewController.h"
#import "NumberVerificationViewController.h"
#import "SVProgressHUD.h"
#import "QBCore.h"
#import "Settings.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@import Firebase;
const CGFloat kQBRingThickness = 1.f;
const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;
@interface AppDelegate ()<CLLocationManagerDelegate,FIRMessagingDelegate>{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocationManager *locationManager;
    CLGeocoder *myGeoCoder;
}

@end

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";
// com.googleusercontent.apps.757501644390-po3ghqplsp7heh3j505lkiohp8h4imc8 verification key change it for client
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;

    _str_lat=@"";
    _str_lang=@"";

    // add fabric
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];

    [QBSettings setAccountKey:@"EzgotYXEE1DDFAjCN3Jj"];
    [QBSettings setApplicationID:69839];
    [QBSettings setAuthKey:@"mgPvJFdNPguUEGr"];
    [QBSettings setAuthSecret:@"kfQ9GCwfxCn9Nd-"];
    
    [QBSettings setLogLevel:QBLogLevelDebug];
    [QBSettings enableXMPPLogging];
    
    [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
    [QBRTCConfig setStatsReportTimeInterval:1.f];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    
    [QBRTCClient initializeRTC];
    
        // loading settings
    [Settings instance];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         if( !error ) {
             dispatch_async(dispatch_get_main_queue(), ^() {
             [[UIApplication sharedApplication] registerForRemoteNotifications];
             });
                 // required to get the app to do anything at all about push notifications
             NSLog( @"Push registration success." );
         } else {
             NSLog( @"Push registration FAILED" );
             NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
             NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
         }
     }];
    
    
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
             // ...
         }];
    } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingLocation];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    self.viewController.leftPanel = [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"FMenuViewController"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if(USERID){
        self.viewController.centerPanel = [[SupportClass getNavigationController]  initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];
        
        NSString *Email2 = [prefs stringForKey:@"Email"];
        [QBRequest usersWithEmails:@[Email2]
                              page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10]
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          
                          if(users.count>0){
                              QBUUser *CurrentUser=[users objectAtIndex:0];
                              [Core loginWithCurrentUser:CurrentUser];
                              
                              
                              
                          }else{
                              NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                              NSString *username = [prefs stringForKey:@"username"];
                              NSString *Email = [prefs stringForKey:@"Email"];
                                  //
                             
                              [Core signUpWithFullName:username
                                              roomName:Email];
                              
                          }
                          
                      } errorBlock:^(QBResponse *response) {
                              // Handle error
                          NSLog(@"responce Error %@",response);
                      }];
        
    }
    else{
        self.viewController.centerPanel =  [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    }
    NSURL* url = [[NSURL alloc] initWithString:@"http://iblah-blah.com:4300"];
    _manager = [[SocketManager alloc] initWithSocketURL:url config:@{@"log": @NO, @"compress": @NO}];
    _socket = _manager.defaultSocket;
   
    
    
    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"Socket connected");
        
    }];
    [[ApiClient sharedInstance]allAPIResponce];
    [[ApiClient sharedInstance]getAllPostResponce];
    [[ApiClient sharedInstance]uploadImageVideo];
     [_socket connect];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if(USERID)
    [_socket emit:@"sendOfflineStatus" with:@[USERID]];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    //
//    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
//        NSLog(@"One two three");
//       
//    }];
//SocketIOStatus
    
    NSLog(@"%ld",(long)_socket.status);
    if (![QBChat instance].isConnected
        && [QBCore instance].isAuthorized) {
        [[QBCore instance] loginWithCurrentUser];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"ShareImages"
//     object:self userInfo:nil];
   
    NSString *valueToSave = @"Start";
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"ShareExtensionValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"Socket connected");
//mSocket.emit("getOnline", user_id);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        if(USERID)
        [_socket emit:@"getOnline" with:@[USERID]];
        
        //ShareImages
    }];
    [_socket connect];
    if (![QBChat instance].isConnected
        && [QBCore instance].isAuthorized) {
        [[QBCore instance] loginWithCurrentUser];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if(USERID)
    [_socket emit:@"getOnline" with:@[USERID]];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [_socket emit:@"sendOfflineStatus" with:@[USERID]];
}

#pragma mark - Convenience contructor
AppDelegate *appDelegate(void)
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        if([_str_lat isEqualToString:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]] &&[_str_lang isEqualToString:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]]){
            
        }else{
            _str_lang = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            _str_lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
            }
        }
    
        // Stop Location Manager
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    locationManager=nil;
    
            [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                    _Country=placemark.country;
                    _State=placemark.locality;
                    _City=placemark.subLocality;
                    
                } else {
                    NSLog(@"%@", error.debugDescription);
                }
            }];
}

// MARK: - Remote Notifictions

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        
        NSLog(@"Did register user notificaiton settings");
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [FIRMessaging messaging].APNSToken = deviceToken;
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenStr = [deviceTokenStr substringWithRange:NSMakeRange(1, [deviceTokenStr length]-1)];
    deviceTokenStr = [deviceTokenStr substringToIndex:[deviceTokenStr length]-1];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@", deviceTokenStr);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceTokenStr forKey:@"deviceTokenStrKey"];
    [defaults synchronize];
    
    NSLog(@"Did register for remote notifications with device token");
    [Core registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"tataMessage ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllNotificationsCount" with:@[USERID]];
    // Print full message.
    NSLog(@"%@", userInfo);
    NSLog(@"Did receive remote notification %@", userInfo);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Did fail to register for remote notification with error %@", error.localizedDescription);
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"hello%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"bye%@", userInfo);
    NSString *strMsg=[userInfo objectForKey:@"msg"];
    if([strMsg isEqualToString:@"has send you a friend request"]){
         NSLog(@"wow%@", userInfo);
        [self performSelector:@selector(showRequestPage) withObject:nil afterDelay:1];
    }
   
    completionHandler();
}
-(void)showRequestPage{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowRequest"
     object:self userInfo:nil];
}
// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]



@end

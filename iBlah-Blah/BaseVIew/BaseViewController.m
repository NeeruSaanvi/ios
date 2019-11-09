//
//  BaseViewController.m
//  iBlah-Blah
//
//  Created by webHex on 17/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "BaseViewController.h"


#import <Quickblox/Quickblox.h>
#import <PushKit/PushKit.h>

#import "QBCore.h"
#import "UsersDataSource.h"
#import "PlaceholderGenerator.h"
#import "QBAVCallPermissions.h"
#import "SessionSettingsViewController.h"
#import "SVProgressHUD.h"
#import "CallViewController.h"
#import "IncomingCallViewController.h"
#import "RecordsViewController.h"
#import "CallKitManager.h"
//const NSUInteger kQBPageSize = 50;
static NSString * const kVoipEvent = @"VOIPCall";

@interface BaseViewController ()<QBCoreDelegate, QBRTCClientDelegate, SettingsViewControllerDelegate, IncomingCallViewControllerDelegate, PKPushRegistryDelegate>{
    NSMutableArray *arryChunkData1;
    NSMutableDictionary *dictJson1;
}

@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) RecordsViewController *recordsViewController;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@property (strong, nonatomic) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation BaseViewController
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

- (void)viewDidLoad {
    [super viewDidLoad];
    _backgroundTask = UIBackgroundTaskInvalid;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification1:)
                                                 name:@"GetChatList"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification1:)
                                                 name:@"VideoChunk1"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
  //  [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
    [Core addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    _dataSource = [[UsersDataSource alloc] initWithCurrentUser:Core.currentUser];
    CallKitManager.instance.usersDatasource = _dataSource;
    
    _dataSource = [[UsersDataSource alloc] initWithCurrentUser:Core.currentUser];
    CallKitManager.instance.usersDatasource = _dataSource;
    //[self loadUsers];
}


- (void)receivedNotification1:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"GetChatList"]){
//        /[ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
      
        [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"CHATLIST"];
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
        [myDefaults setObject:json forKey:@"CHATLIST"];
        
        NSMutableArray *arryTemp=[[NSMutableArray alloc]init];
        for (int i=0; i<json.count; i++) {
            NSDictionary *dict=[json objectAtIndex:i];
            NSString *strCallerId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"caller_id"]];
            if(![strCallerId isEqualToString:@""]){
                [arryTemp addObject:strCallerId];
            }
        }
        
        __weak __typeof(self)weakSelf = self;
        QBGeneralResponsePage *responsePage =
        [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:10000];
        [QBRequest usersWithIDs:arryTemp page:responsePage successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nonnull page, NSArray<QBUUser *> * _Nonnull users) {
            NSLog(@"USer %@",users);
           
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:users] forKey:@"FriendList"];

            BOOL isUpdated = [weakSelf.dataSource setUsers:users];
        } errorBlock:^(QBResponse * _Nonnull response) {
            NSLog(@"response %@",response);
        }];
        
    }else if ([[notification name] isEqualToString:@"VideoChunk1"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSLog(@"%@ Arry",Arr);
        if(!(arryChunkData1.count>0)){
            //[AlertView showAlertWithMessage:@"Somthing went wrong, Please try again." view:self];
        }
        
            if(Arr.count>1){
                NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                
                
                if(!([strValue isEqualToString:@"0"])){
                    if(arryChunkData1.count>0){
                        [arryChunkData1 removeObjectAtIndex:0];
                    }
                }
                NSMutableDictionary *dict;
                
                dict=[[NSMutableDictionary alloc]init];
                [dict setValue:[dictJson1 objectForKey:@"Name"] forKey:@"Name"];
                [dict setValue:[dictJson1 objectForKey:@"Size"] forKey:@"Size"];
                [dict setValue:[dictJson1 objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                [dict setValue:[dictJson1 objectForKey:@"from_id"] forKey:@"from_id"];
                [dict setValue:[dictJson1 objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                
                [dict setValue:[arryChunkData1 objectAtIndex:0] forKey:@"Data"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                   options:0
                                                                     error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                
                [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
            }
        
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)loadUsers {
    
    __block void(^t_request) (QBGeneralResponsePage *, NSMutableArray *);
    __weak __typeof(self)weakSelf = self;
    
    void(^request) (QBGeneralResponsePage *, NSMutableArray *) =
    ^(QBGeneralResponsePage *page, NSMutableArray *allUsers) {
        
        [QBRequest usersWithTags:Core.currentUser.tags
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBUUser *> *users)
         {
             page.currentPage++;
             [allUsers addObjectsFromArray:users];
             
             BOOL cancel = NO;
             if (page.currentPage * page.perPage >= page.totalEntries) {
                 cancel = YES;
             }
             
             if (!cancel) {
                 t_request(page, allUsers);
             }
             else {
                
                 BOOL isUpdated = [weakSelf.dataSource setUsers:allUsers];
                 
                 t_request = nil;
             }
             
         } errorBlock:^(QBResponse *response) {
            
             t_request = nil;
         }];
    };
    
    t_request = [request copy];
    
    QBGeneralResponsePage *responsePage =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100];
    NSMutableArray *allUsers = [NSMutableArray array];
    
    request(responsePage, allUsers);
}
- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = Core.networkStatus != QBNetworkStatusNotReachable;
    
    if (!hasConnectivity) {
        [self showAlertViewWithMessage:NSLocalizedString(@"Please check your Internet connection", nil)];
    }
    
    return hasConnectivity;
}

- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)didPressSettingsButton:(UIBarButtonItem *)item {
    
    [self performSegueWithIdentifier:@"PresentSettingsViewController" sender:item];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PresentSettingsViewController"]) {
        
        SessionSettingsViewController *settingsViewController =
        (id)((UINavigationController *)segue.destinationViewController).topViewController;
        settingsViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"PresentRecordsViewController"]) {
        self.recordsViewController = segue.destinationViewController;
    }
}
#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewController:(SessionSettingsViewController *)vc didPressLogout:(id)sender {
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Logout...", nil)];
    [Core logout];
}

#pragma mark - UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    [self.dataSource selectUserAtIndexPath:indexPath];
//
//    [self setToolbarButtonsEnabled:self.dataSource.selectedUsers.count > 0];
//
//    if (self.dataSource.selectedUsers.count > 4) {
//        self.videoCallButton.enabled = NO;
//    }
//
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//}

#pragma mark - QBSampleCoreDelegate

- (void)core:(QBCore *)core loginStatus:(NSString *)loginStatus {
    [SVProgressHUD showWithStatus:loginStatus];
}

- (void)coreDidLogin:(QBCore *)core {
    [SVProgressHUD dismiss];
}

- (void)coreDidLogout:(QBCore *)core {
    [SVProgressHUD dismiss];
    //Dismiss Settings view controller
    [self dismissViewControllerAnimated:NO completion:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:NO];
    });
}

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain {
    [SVProgressHUD dismiss];
    if (domain == ErrorDomainLogOut) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

#pragma mark - QBCallKitDataSource

- (NSString *)userNameForUserID:(NSNumber *)userID sender:(id)sender {
    
    QBUUser *user = [self.dataSource userWithID:userID.unsignedIntegerValue];
    return user.fullName;
}

#pragma mark - Helpers

- (void)setToolbarButtonsEnabled:(BOOL)enabled {
    
    for (UIBarButtonItem *item in self.toolbarItems) {
        item.enabled = enabled;
    }
}

#pragma mark - QBWebRTCChatDelegate



- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session) {
        if (_backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground
                && _backgroundTask == UIBackgroundTaskInvalid) {
                // dispatching chat disconnect in 1 second so message about call end
                // from webrtc does not cut mid sending
                // checking for background task being invalid though, to avoid disconnecting
                // from chat when another call has already being received in background
                [QBChat.instance disconnectWithCompletionBlock:nil];
            }
        });
        
        if (self.nav != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.nav.view.userInteractionEnabled = NO;
                [self.nav dismissViewControllerAnimated:NO completion:nil];
                self.session = nil;
                self.nav = nil;
            });
        }
        else if (CallKitManager.isCallKitAvailable) {
           // [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
            self.callUUID = nil;
            self.session = nil;
        }
    }
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session {
    
    CallViewController *callViewController =
    [[UIStoryboard storyboardWithName:@"Call" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    callViewController.session = session;
    callViewController.usersDatasource = self.dataSource;
    self.nav.viewControllers = @[callViewController];
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session {
    
    [session rejectCall:nil];
    [self.nav dismissViewControllerAnimated:NO completion:nil];
    self.nav = nil;
}

// MARK: - PKPushRegistryDelegate protocol

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    
    //  New way, only for updated backend
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = [self.voipRegistry pushTokenForType:PKPushTypeVoIP];
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Create Subscription request - Success");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Create Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"Unregister Subscription request - Success");
    } errorBlock:^(QBError * _Nonnull error) {
        NSLog(@"Unregister Subscription request - Error");
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    if (CallKitManager.isCallKitAvailable) {
        if ([payload.dictionaryPayload objectForKey:kVoipEvent] != nil) {
            UIApplication *application = [UIApplication sharedApplication];
            if (application.applicationState == UIApplicationStateBackground
                && _backgroundTask == UIBackgroundTaskInvalid) {
                _backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:_backgroundTask];
                    _backgroundTask = UIBackgroundTaskInvalid;
                }];
            }
            if (![QBChat instance].isConnected) {
                [[QBCore instance] loginWithCurrentUser];
            }
        }
    }
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    
    if (self.session != nil
        || self.recordsViewController.playerPresented) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    NSString *name=@"";
        if (CallKitManager.isCallKitAvailable) {
            self.callUUID = [NSUUID UUID];
            NSMutableArray *opponentIDs = [@[session.initiatorID] mutableCopy];
            for (NSNumber *userID in session.opponentsIDs) {
                if ([userID integerValue] != [QBCore instance].currentUser.ID) {
                    [opponentIDs addObject:userID];
                    
                }
            }
            __weak __typeof(self)weakSelf = self;
            [CallKitManager.instance reportIncomingCallWithUserIDs:[opponentIDs copy] session:session uuid:self.callUUID onAcceptAction:^{
                __typeof(weakSelf)strongSelf = weakSelf;
                CallViewController *callViewController =
                [[UIStoryboard storyboardWithName:@"Call" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CallViewController"];
    
                callViewController.session = session;
                
                NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"FriendList"];
                if (dataRepresentingSavedArray != nil)
                {
                    NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
                    if (oldSavedArray != nil)
                        [strongSelf.dataSource setUsers:oldSavedArray];
                }
                
                callViewController.usersDatasource = strongSelf.dataSource;
                callViewController.callUUID = self.callUUID;
                strongSelf.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
                [strongSelf presentViewController:strongSelf.nav animated:NO completion:nil];
    
            } completion:nil];
        }
        else {
    
    NSParameterAssert(!self.nav);
    
    IncomingCallViewController *incomingViewController =
    [[UIStoryboard storyboardWithName:@"Call" bundle:[NSBundle mainBundle]]
     instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
    incomingViewController.delegate = self;
    incomingViewController.session = session;
           
            NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
            NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"FriendList"];
            if (dataRepresentingSavedArray != nil)
            {
                NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
                if (oldSavedArray != nil)
                     [self.dataSource setUsers:oldSavedArray];
               
                   
            }
            
            
    incomingViewController.usersDatasource = self.dataSource;
    
    self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
    [self presentViewController:self.nav animated:NO completion:nil];
     }
}

-(void)sendTextMsg:(NSDictionary *)dict1{
    NSString *strText=[dict1 objectForKey:@"TextMsg"];
    NSString *uniText = [NSString stringWithUTF8String:[strText UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *username = [prefs stringForKey:@"username"];
    NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[dict1 objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[dict1 objectForKey:@"user_id"]];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSTimeZone *timeZone=[NSTimeZone localTimeZone];
    NSDate *now=[NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTimeString = [dateFormatter stringFromDate:now];
    
    NSMutableDictionary *dict=[[NSMutableDictionary  alloc]init];
    [dict setValue:USERID forKey:@"from_id"];
    [dict setValue:goodMsg forKey:@"message"];
    [dict setValue:struser_id forKey:@"to_id"];
    [dict setValue:uuid forKey:@"message_id"];
    [dict setValue:@"0" forKey:@"have_media"];
    [dict setValue:@"" forKey:@"video_url"];
    [dict setValue:@"" forKey:@"video_thumb"];
    [dict setValue:@"0" forKey:@"readStatus"];
    [dict setValue:@"" forKey:@"lat"];
    [dict setValue:@"" forKey:@"log"];
    [dict setValue:username forKey:@"sender_name"];
    [dict setValue:username forKey:@"group_name"];
    [dict setValue:profile_pic forKey:@"sender_image"];
    [dict setValue:profile_pic forKey:@"group_image"];
    [dict setValue:dateTimeString forKey:@"msg_time"];
    [dict setValue:timeZone.name forKey:@"time_zone_id"];
    [dict setValue:@"1" forKey:@"type"];
    [dict setValue:@"" forKey:@"image_url"];
    
    [dict setValue:strFriendId forKey:@"friendship_ID"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    
    //"yyyy-MM-dd HH:mm:ss"
    //mSocket.emit("sendMessageRoom", friend_id, messageObject.toString(), friendshipID);
    
    [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
    NSMutableArray *tempArry =[[myDefaults objectForKey:@"ShareMSG"] mutableCopy];
    [tempArry removeObject:dict];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
    [defaults setObject:tempArry forKey:@"ShareMSG"];
    [defaults synchronize];
    for (int i=0; i<tempArry.count;) {
        NSDictionary *dict=[tempArry objectAtIndex:i];
        NSString *strText=[dict objectForKey:@"TextMsg"];
        if(strText){
            [self sendTextMsg:dict];
            
        }
        NSData *imageData=[dict objectForKey:@"imgData"];
        
        if(imageData){
            [self uploadThumb1:dict];
            
        }
        break;
    }
}


-(void)uploadThumb1:(NSDictionary *)dict{
    [arryChunkData1 removeAllObjects];
    arryChunkData1=nil;
    arryChunkData1=[[NSMutableArray alloc]init];
    NSData *imageData=[dict objectForKey:@"imgData"];
    UIImage *img =    [UIImage imageWithData:imageData];

    img=[self compressImage:img];
    NSData *imgData = UIImageJPEGRepresentation(img, 0.9);

    NSData* myBlob=imgData;
    NSUInteger length = [myBlob length];
    NSUInteger chunkSize = 1000 * 1024;
    NSUInteger offset = 0;
    do {//750103
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        NSString *base64String = [chunk base64EncodedStringWithOptions:0];
        
        [arryChunkData1 addObject:base64String];
        // do something with chunk
    } while (offset < length);
    
    if(arryChunkData1.count>0){//872360
        
        dictJson1=nil;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.png",uuid];
        
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
        
        dictJson1=[[NSMutableDictionary alloc]init];
        [dictJson1 setValue:uuid forKey:@"Name"];
        [dictJson1 setValue:StrSize forKey:@"Size"];
        [dictJson1 setValue:@"false" forKey:@"IsVideo"];
        [dictJson1 setValue:USERID forKey:@"from_id"];
         [dictJson1 setValue:@"false" forKey:@"IsAudio"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson1
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
        [self uploadImageVideo1:dict];
    }
    
}
-(UIImage *)compressImage:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.7;//70 percent compression
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:imageData];
}


#pragma mark Listner
-(void)uploadImageVideo1:(NSDictionary *)dict{
    NSString *USERID = [dictJson1 objectForKey:@"Name"];
    __block NSDictionary *dictData=dict;
    [appDelegate().socket on:USERID callback:^(NSArray* data, SocketAckEmitter* ack) {// 39 for get all post
        
        
        
            NSString *uniText = [NSString stringWithUTF8String:[@"" UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *USERID = [prefs stringForKey:@"USERID"];
            NSString *username = [prefs stringForKey:@"username"];
            NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
            NSString *strFriendId=[NSString stringWithFormat:@"%@",[dictData objectForKey:@"myFriend_id"]];
            NSString *struser_id=[NSString stringWithFormat:@"%@",[dictData objectForKey:@"user_id"]];
            NSString *uuid = [[NSUUID UUID] UUIDString];
            NSTimeZone *timeZone=[NSTimeZone localTimeZone];
            NSDate *now=[NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateTimeString = [dateFormatter stringFromDate:now];
            
            NSMutableDictionary *dict=[[NSMutableDictionary  alloc]init];
            [dict setValue:USERID forKey:@"from_id"];
            [dict setValue:goodMsg forKey:@"message"];
            [dict setValue:struser_id forKey:@"to_id"];
            [dict setValue:uuid forKey:@"message_id"];
            [dict setValue:@"1" forKey:@"have_media"];
            [dict setValue:@"" forKey:@"video_url"];
            [dict setValue:@"" forKey:@"video_thumb"];
            [dict setValue:@"0" forKey:@"readStatus"];
            [dict setValue:@"" forKey:@"lat"];
            [dict setValue:@"" forKey:@"log"];
            [dict setValue:username forKey:@"sender_name"];
            [dict setValue:username forKey:@"group_name"];
            [dict setValue:profile_pic forKey:@"sender_image"];
            [dict setValue:profile_pic forKey:@"group_image"];
            [dict setValue:dateTimeString forKey:@"msg_time"];
            [dict setValue:timeZone.name forKey:@"time_zone_id"];
            [dict setValue:@"1" forKey:@"type"];
            [dict setValue:[dictJson1 objectForKey:@"Name"] forKey:@"image_url"];
            
            [dict setValue:strFriendId forKey:@"friendship_ID"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                               options:0
                                                                 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
            [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
        NSMutableArray *tempArry =[[myDefaults objectForKey:@"ShareMSG"] mutableCopy];
        [tempArry removeObject:dictData];
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
        [defaults setObject:tempArry forKey:@"ShareMSG"];
        [defaults synchronize];
        for (int i=0; i<tempArry.count;) {
            NSDictionary *dict=[tempArry objectAtIndex:i];
            NSString *strText=[dict objectForKey:@"TextMsg"];
            if(strText){
                [self sendTextMsg:dict];
                
            }
            NSData *imageData=[dict objectForKey:@"imgData"];
            
            if(imageData){
                [self uploadThumb1:dict];
                
            }
            break;
        }
        
    }];
    
}



@end

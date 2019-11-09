//
//  AGChatViewController.m
//  AGChatView
//
//  Created by Ashish Gogna on 09/04/16.
//  Copyright © 2016 Ashish Gogna. All rights reserved.
//

#import "AGChatViewController.h"
#import "HPGrowingTextView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DLFPhotosPickerViewController.h"
#import "DLFPhotoCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ChatLocationViewController.h"

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
//static NSString * const kAps = @"aps";
//static NSString * const kAlert = @"alert";
static NSString * const kVoipEvent = @"VOIPCall";


@interface AGChatViewController ()<HPGrowingTextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBCoreDelegate, QBRTCClientDelegate, SettingsViewControllerDelegate, IncomingCallViewControllerDelegate, PKPushRegistryDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
     NSURL *videoURL;
    BOOL checkImgVideo;
    
    NSMutableArray *arryChunkData;
    NSMutableDictionary *dictJson;
    IndecatorView *indd;
    UIImage *thumbImage;
    BOOL UplodeVideo;
    BOOL checkVideoImage;
    BOOL checkAudio;
    NSString *srtThumb;
    NSString *strVideo;
    NSIndexPath *indexPathforSelectedRow;
    BOOL deleteRow;
    NSMutableArray *selectedDeletedRows;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
}


@property (nonatomic, strong) AVAudioPlayer* player1;
@property (nonatomic, strong) NSTimer* timer;

- (void)updateDisplay;
- (void)updateSliderLabels;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error;

@property (strong, nonatomic) UsersDataSource *dataSource;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) RecordsViewController *recordsViewController;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@property (strong, nonatomic) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;




//All messages array (contains UIViews)
@property (nonatomic) NSMutableArray *allMessages;
@property (nonatomic) NSMutableArray *allMessagesFromApi;
//Subview(s)
@property (nonatomic) UIView *viewBar;
@property (nonatomic) UITextView *messageTV;
@property (nonatomic) UIButton *sendButton;

@end

@implementation AGChatViewController

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    deleteRow=NO;
    checkAudio=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"VideoChunk"
                                               object:nil];
    _backgroundTask = UIBackgroundTaskInvalid;
    indd=[[IndecatorView alloc]init];
    [Core addDelegate:self];
    [QBRTCClient.instance addDelegate:self];
    self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    self.voipRegistry.delegate = self;
    self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];

    
    
        //Example title
    self.navigationItem.title = [_dictChatData objectForKey:@"name"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.backgroundImageView.backgroundColor = Rgb2UIColor(211, 211, 211);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GetChat"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"SendChatLocation"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getNewMsg"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"startTyping"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"stopTyping"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UpdateStatus"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"BlockedUser"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];

    [appDelegate().socket emit:@"getAllMsgs" with:@[strFriendId,USERID,@""]];
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    containerView.backgroundColor=[UIColor colorWithRed:31/255.0 green:152/255.0 blue:207/255.0 alpha:1.0];//31,152,207
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(46, 3, self.view.frame.size.width-109, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];//0,153,204
    textView.placeholder = @"Type...";
    
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(6, 4, 40, 40);
    [btnClear addTarget:self action:@selector(cmdAddMedia:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:btnClear];
    
    [self.view addSubview:containerView];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
        // view hierachy
    
    [containerView addSubview:textView];
        //[containerView addSubview:entryImageView];
    
    
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    [doneBtn addTarget:self
                action:@selector(sendAction:)
      forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//0,153,204
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    [textView.layer setShadowColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1.0].CGColor];
    [textView.layer setShadowOpacity:1.0];
    [textView.layer setShadowRadius:3.0];
    [textView.layer setCornerRadius:5];
    [textView.layer setShadowOffset:CGSizeMake(1, 1)];
    textView.layer.masksToBounds = NO;
    
    [containerView.layer setShadowColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0].CGColor];
    [containerView.layer setShadowOpacity:1.0];
    [containerView.layer setShadowRadius:3.0];
    [containerView.layer setCornerRadius:0];
    [containerView.layer setShadowOffset:CGSizeMake(1, 1)];
    containerView.layer.masksToBounds = YES;;
    
    [self addCallButton];
    

    
    _dataSource = [[UsersDataSource alloc] initWithCurrentUser:Core.currentUser];
    CallKitManager.instance.usersDatasource = _dataSource;
    [self.view addSubview:indd];
//    UIMenuItem *testMenuItem = [[UIMenuItem alloc] initWithTitle:@"Test" action:@selector(test:)];
//    [[UIMenuController sharedMenuController] setMenuItems: @[testMenuItem]];
//    [[UIMenuController sharedMenuController] update];
    
     [self setAudio];
    
}

- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"GetChat"]) {
        [indd removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        
        self.allMessages = [[NSMutableArray alloc] init];
        for (int i=0; i<json.count; i++) {
            
            
            NSDictionary *dict=[json objectAtIndex:i];
            
            NSString *message_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"message_id"]];
            NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *USERID = [prefs stringForKey:@"USERID"];
            NSString *username = [prefs stringForKey:@"username"];
            NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
            NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
            NSString *isVideo=@"no";
            NSString *latLong=[NSString stringWithFormat:@"%@",[dict objectForKey:@"lat"]];
            if(!([latLong isEqualToString:@""])){
                strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_url"]];
            }
            NSString *have_media=[NSString stringWithFormat:@"%@",[dict objectForKey:@"have_media"]];
            if(!([strvideo_thumb isEqualToString:@""])){
                isVideo=@"yes";
                strUrl=strvideo_thumb;
            }
            NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
            NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
            if([strFromId isEqualToString:USERID]){
                
                
                
                NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                [dictForMsg setValue:strUrl forKey:@"Image"];
                [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                [dictForMsg setValue:@"0" forKey:@"isReceived"];
                [dictForMsg setValue:isVideo forKey:@"isVideo"];
                [dictForMsg setValue:username forKey:@"name"];
                [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                if([have_media isEqualToString:@"6"]){
                      [dictForMsg setValue:@"6" forKey:@"have_media"];
                }
                
                [self.allMessages addObject:dictForMsg];
                
            }
            else{
                NSString *strmyFriend_id=[NSString stringWithFormat:@"myFriend_id"];
                if(!([strread_status isEqualToString:@"3"])){
                [appDelegate().socket emit:@"updateMessageReadStatus" with:@[strmyFriend_id,message_id,@"3",struser_id]];
                }
                
                NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                [dictForMsg setValue:strUrl forKey:@"Image"];
                [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                [dictForMsg setValue:@"1" forKey:@"isReceived"];
                [dictForMsg setValue:isVideo forKey:@"isVideo"];
                [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
                [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                if([have_media isEqualToString:@"6"]){
                    [dictForMsg setValue:@"6" forKey:@"have_media"];
                }
                [self.allMessages addObject:dictForMsg];
                
            }
            
        }
        
        self.allMessagesFromApi = [json mutableCopy];
       // self.allMessages = bubbles;
        [self.chatTableView reloadData];
        [self scrollToTheBottom:YES];
        
    }else if([[notification name] isEqualToString:@"getNewMsg"]){//
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        NSString *strDictfriendship_ID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"friendship_ID"]];
        NSString *strmyFriend_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"] ];
        
        if(!([strDictfriendship_ID isEqualToString:strmyFriend_id])){
            return;
        }
        [self.allMessagesFromApi addObject:dict];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSString *username = [prefs stringForKey:@"username"];
        NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
        NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
        NSString *isVideo=@"no";
        NSString *latLong=[NSString stringWithFormat:@"%@",[dict objectForKey:@"lat"]];
        if(!([latLong isEqualToString:@""])){
            strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_url"]];
        }
        if(!([strvideo_thumb isEqualToString:@""])){
            isVideo=@"yes";
            strUrl=strvideo_thumb;
        }
        NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
        NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
         NSString *have_media=[NSString stringWithFormat:@"%@",[dict objectForKey:@"have_media"]];
        if([strFromId isEqualToString:USERID]){
            
            
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"0" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
            [dictForMsg setValue:username forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
            if([have_media isEqualToString:@"6"]){
                [dictForMsg setValue:@"6" forKey:@"have_media"];
            }
            [self.allMessages addObject:dictForMsg];
            
            
           
            
        }else{
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"1" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
           [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
            if([have_media isEqualToString:@"6"]){
                [dictForMsg setValue:@"6" forKey:@"have_media"];
            }
            [self.allMessages addObject:dictForMsg];
            
            NSString *message_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"message_id"]];
            
            if(!([strread_status isEqualToString:@"3"])){
                [appDelegate().socket emit:@"updateMessageReadStatus" with:@[strDictfriendship_ID,message_id,@"3",struser_id]];
            }

            
        }
        [self.chatTableView reloadData];
        [self scrollToTheBottom:YES];
    }else if([[notification name] isEqualToString:@"startTyping"]){//
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];

        NSString *strDictfriendship_ID=[Arr objectAtIndex:1];
        NSString *strmyFriend_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];

        if(!([strDictfriendship_ID isEqualToString:strmyFriend_id])){
            return;
        }else{
            self.title=@"Typing...";
        }
        
    }else if([[notification name] isEqualToString:@"stopTyping"]){//
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];

        NSString *strDictfriendship_ID=[Arr objectAtIndex:1];
        NSString *strmyFriend_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
        
        if(!([strDictfriendship_ID isEqualToString:strmyFriend_id])){
            return;
        }else{
            self.title=[_dictChatData objectForKey:@"name"];
        }
      
    }else if([[notification name] isEqualToString:@"UpdateStatus"]){//
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
         NSString *strFriendShipId=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];
        
        if(!([strFriendShipId isEqualToString:strFriendId])){
            return;
        }
        NSArray *matches = [self.allMessagesFromApi valueForKey: @"message_id"];
        if (![matches containsObject:[Arr objectAtIndex:2]]) {
            return;
        }
        NSInteger msgPostion=[matches indexOfObject:[Arr objectAtIndex:2]];
        
        NSMutableDictionary *temp=[[self.allMessagesFromApi objectAtIndex:msgPostion] mutableCopy];
        [temp setValue:[Arr objectAtIndex:3] forKey:@"read_status"];
        
        
        [self.allMessagesFromApi replaceObjectAtIndex:msgPostion withObject:temp];
        
        NSString *username = [prefs stringForKey:@"username"];
        
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[temp objectForKey:@"image_url"]];
        NSString *latLong=[NSString stringWithFormat:@"%@",[temp objectForKey:@"lat"]];
        if(!([latLong isEqualToString:@""])){
            strUrl=[NSString stringWithFormat:@"%@",[temp objectForKey:@"image_url"]];
        }
        NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[temp objectForKey:@"video_thumb"]];
        NSString *isVideo=@"no";
        if(!([strvideo_thumb isEqualToString:@""])){
            isVideo=@"yes";
            strUrl=strvideo_thumb;
        }
        NSString *strread_status=[NSString stringWithFormat:@"%@",[temp objectForKey:@"read_status"]];
        NSString *strFromId=[NSString stringWithFormat:@"%@",[temp objectForKey:@"from_id"]];
        NSString *have_media=[NSString stringWithFormat:@"%@",[temp objectForKey:@"have_media"]];
        if([strFromId isEqualToString:USERID]){
            
            
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[temp objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[temp objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"0" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
            [dictForMsg setValue:username forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",msgPostion] forKey:@"tagValue"];
            if([have_media isEqualToString:@"6"]){
                [dictForMsg setValue:@"6" forKey:@"have_media"];
            }
            [self.allMessages replaceObjectAtIndex:msgPostion withObject:dictForMsg];
            

            
        }else{
            
            
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[temp objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[temp objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"1" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
            [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",msgPostion] forKey:@"tagValue"];
            if([have_media isEqualToString:@"6"]){
                [dictForMsg setValue:@"6" forKey:@"have_media"];
            }
           [self.allMessages replaceObjectAtIndex:msgPostion withObject:dictForMsg];
            

            
        }
        [self.chatTableView reloadData];
        [self scrollToTheBottom:YES];
       
    }else if ([[notification name] isEqualToString:@"SendChatLocation"]) {//AddTagedFrnd
        NSDictionary *userInfo = notification.userInfo;
        
        
        //[userInfo   objectForKey:@"address"];
        //  lat = "51.50998000";
      //  lon = "-0.13370000";
         NSString *strUrl11=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[userInfo objectForKey:@"lat"],[userInfo objectForKey:@"lon"],[userInfo objectForKey:@"lat"],[userInfo objectForKey:@"lon"]];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSString *username = [prefs stringForKey:@"username"];
        NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
        NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
        NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSTimeZone *timeZone=[NSTimeZone localTimeZone];
        NSDate *now=[NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateTimeString = [dateFormatter stringFromDate:now];
        
        NSMutableDictionary *dict=[[NSMutableDictionary  alloc]init];
        [dict setValue:USERID forKey:@"from_id"];
        [dict setValue:[userInfo   objectForKey:@"address"] forKey:@"message"];
        [dict setValue:struser_id forKey:@"to_id"];
        [dict setValue:uuid forKey:@"message_id"];
        [dict setValue:@"5" forKey:@"have_media"];
        [dict setValue:@"" forKey:@"video_url"];
        [dict setValue:@"" forKey:@"video_thumb"];
        [dict setValue:@"0" forKey:@"readStatus"];
        [dict setValue:[userInfo   objectForKey:@"lat"] forKey:@"lat"];
        [dict setValue:[userInfo   objectForKey:@"lon"] forKey:@"log"];
        [dict setValue:username forKey:@"sender_name"];
        [dict setValue:username forKey:@"group_name"];
        [dict setValue:profile_pic forKey:@"sender_image"];
        [dict setValue:profile_pic forKey:@"group_image"];
        [dict setValue:dateTimeString forKey:@"msg_time"];
        [dict setValue:timeZone.name forKey:@"time_zone_id"];
        [dict setValue:@"1" forKey:@"type"];
        [dict setValue:strUrl11 forKey:@"image_url"];
        
        [dict setValue:strFriendId forKey:@"friendship_ID"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        //"yyyy-MM-dd HH:mm:ss"
        //mSocket.emit("sendMessageRoom", friend_id, messageObject.toString(), friendshipID);
        
        [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
        
        
        
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
        NSString *latLong=[NSString stringWithFormat:@"%@",[dict objectForKey:@"lat"]];
        if(!([latLong isEqualToString:@""])){
            strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_url"]];
        }
        NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
        NSString *isVideo=@"no";
        if(!([strvideo_thumb isEqualToString:@""])){
            isVideo=@"yes";
            strUrl=strvideo_thumb;
        }
        NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
        NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
        if([strFromId isEqualToString:USERID]){
            
            
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"0" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
            [dictForMsg setValue:username forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
            
            [self.allMessages addObject:dictForMsg];
            
   
            
        }else{
            NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
            [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
            [dictForMsg setValue:strUrl forKey:@"Image"];
            [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
            [dictForMsg setValue:@"1" forKey:@"isReceived"];
            [dictForMsg setValue:isVideo forKey:@"isVideo"];
            [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
            [dictForMsg setValue:strread_status forKey:@"msgStatus"];
            [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
            
            [self.allMessages addObject:dictForMsg];
            
           
            
            
        }
        [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
        
        [self.chatTableView reloadData];
        [self scrollToTheBottom:YES];
        
        
        [textView resignFirstResponder];
        textView.text = @"";
         [self resignTextView];
        [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
        
        
        
    }else if([[notification name] isEqualToString:@"BlockedUser"]){
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
   
        
        NSString *strBlockUser=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];
       
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *USERID = [prefs stringForKey:@"USERID"];
            
            if([strBlockUser isEqualToString:USERID]){
                NSString *strMsg=[NSString stringWithFormat:@"Cannot send message to this user. You are blocked to send messages to this user."];
                [AlertView  showAlertWithMessage:strMsg view:self];
            }else{
                NSString *strMsg=[NSString stringWithFormat:@"You have blocked this user. Please unblock to send messages"];
                [AlertView  showAlertWithMessage:strMsg view:self];
            }
        
        
      //  NSLog(@"json %@",json);
    }else if ([[notification name] isEqualToString:@"VideoChunk"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSLog(@"%@ Arry",Arr);
        if(!(arryChunkData.count>0)){
            [indd removeFromSuperview];
            [AlertView showAlertWithMessage:@"Somthing went wrong, Please try again." view:self];
        }
        
        if(checkAudio){
            if(Arr.count>1){
                NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                
                
                if(!([strValue isEqualToString:@"0"])){
                    if(arryChunkData.count>0){
                        [arryChunkData removeObjectAtIndex:0];
                    }
                    
                }
                NSMutableDictionary *dict;
                
                dict=[[NSMutableDictionary alloc]init];
                [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                   options:0
                                                                     error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                
                [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
            }
        }else{
            if(checkVideoImage){
                if(Arr.count>1){
                    NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                    
                    
                    if(!([strValue isEqualToString:@"0"])){
                        if(arryChunkData.count>0){
                            [arryChunkData removeObjectAtIndex:0];
                        }
                        
                    }
                    NSMutableDictionary *dict;
                    
                    dict=[[NSMutableDictionary alloc]init];
                    [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                    [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                    [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                    [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                     [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                    [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                       options:0
                                                                         error:nil];
                    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                    
                    [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
                }
            }else{
                if(UplodeVideo){
                    if(Arr.count>1){
                        NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                        NSString *strPertage=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];
                        if([strPertage isEqualToString:@"100"]){
                            strVideo=[NSString stringWithFormat:@"http://iblah-blah.com/iblah/videos/%@",[dictJson objectForKey:@"Name"]];
                            UplodeVideo=false;
                            [self uploadThumb:thumbImage];
                            return;
                        }
                        if(!([strValue isEqualToString:@"0"])){
                            if(arryChunkData.count>0){
                                [arryChunkData removeObjectAtIndex:0];
                            }else{
                                //http://iblah-blah.com/iblah/images/1527957175.jpg
                                // http://iblah-blah.com/iblah/videos/1525623383_6900572568.mp4
                                
                            }
                        }
                        NSMutableDictionary *dict;
                        
                        dict=[[NSMutableDictionary alloc]init];
                        [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                        [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                        [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                        [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                         [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                        [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                           options:0
                                                                             error:nil];
                        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                        
                        [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
                    }
                }else{
                    if(Arr.count>1){
                        NSString *strValue=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:0]];
                        NSString *strPertage=[NSString stringWithFormat:@"%@",[Arr objectAtIndex:1]];
                        if([strPertage isEqualToString:@"100"]){
                            srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
                            [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
                            return;
                        }
                        
                        if(!([strValue isEqualToString:@"0"])){
                            if(arryChunkData.count>0){
                                [arryChunkData removeObjectAtIndex:0];
                            }else{
                                srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
                                [AlertView showAlertWithMessage:@"successfully uploaded video, Now please save the video." view:self];
                                return;
                            }
                        }
                        
                        NSMutableDictionary *dict;
                        
                        dict=[[NSMutableDictionary alloc]init];
                        [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"Name"];
                        [dict setValue:[dictJson objectForKey:@"Size"] forKey:@"Size"];
                        [dict setValue:[dictJson objectForKey:@"IsVideo"] forKey:@"IsVideo"];
                        [dict setValue:[dictJson objectForKey:@"from_id"] forKey:@"from_id"];
                         [dict setValue:[dictJson objectForKey:@"IsAudio"] forKey:@"IsAudio"];
                        [dict setValue:[arryChunkData objectAtIndex:0] forKey:@"Data"];
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                           options:0
                                                                             error:nil];
                        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                        
                        [appDelegate().socket emit:@"uploadFileChuncksIOS" with:@[str]];
                    }
                }
            }
        }
        
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //[self createExampleChat];

}
-(void)resignTextView
{
    [textView resignFirstResponder];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
    [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
    // mSocket.emit("sendStopTypingStatusRoom", friendship_ID, friend_id);
}

-(void)cmdAddMedia:(id)sender{
    UIButton *btn=(UIButton *)sender;
    [textView resignFirstResponder];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
    [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                      //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  checkImgVideo=YES;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Choose existing"
                                  checkImgVideo=YES;
                                  UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
                                  imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  imagePickerController.delegate = self;
                                  imagePickerController.navigationBar.tintColor = [UIColor blackColor];
                                  [self presentViewController:imagePickerController animated:YES completion:^{}];
                              }];
    
    UIAlertAction* button3 = [UIAlertAction
                              actionWithTitle:@"Video"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  checkImgVideo=NO;
                                  UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
                                  videoPicker.delegate = self; // ensure you set the delegate so when a video is chosen the right method can be called
                                  videoPicker.navigationBar.tintColor = [UIColor blackColor];
                                  videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
                                      // This code ensures only videos are shown to the end user
                                  videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
                                  
                                  videoPicker.videoQuality = UIImagePickerControllerQualityTypeLow;
                                  [self presentViewController:videoPicker animated:YES completion:nil];
                              }];
    
    UIAlertAction* button4 = [UIAlertAction
                              actionWithTitle:@"Share Location"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  ChatLocationViewController *R2VC = [[ChatLocationViewController alloc]initWithNibName:@"ChatLocationViewController" bundle:nil];
                                  [self.navigationController pushViewController:R2VC animated:YES];
                              }];
    
    UIAlertAction* button5 = [UIAlertAction
                              actionWithTitle:@"Send Audio"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  [self performSelector:@selector(startRecording:) withObject:sender afterDelay:0.5];
                                  
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:button3];
    [alert addAction:button4];
    [alert addAction:button5];
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)startRecording:(id)sender{
    
    
    _recordView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.4];
    _recordView.frame=CGRectMake(0, -SCREEN_SIZE.height,SCREEN_SIZE.width, SCREEN_SIZE.height);
    _recordSubView.layer.cornerRadius=4;
    [self.view addSubview:_recordView];
    [UIView animateWithDuration:1.0f
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5.0
                        options:0
                     animations:^{ _recordView.frame = CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height); }
                     completion:^(BOOL finished) {
                         // slide down animation finished, remove the older view and the constraints
                         
                     }];
    
    
}
- (BOOL)canBecomeFirstResponder{
    
    return YES;
}

- (UIView *)inputAccessoryView{
    
    return self.viewBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView ==_tblForward){
        return _reasentChat.count;
    }
    return self.allMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//
//    if (cell == nil) {
//
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    if(_tblForward==tableView){
        NSDictionary *dict=[_reasentChat objectAtIndex:indexPath.row];
        //
        
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 15,50,50)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
        banner.imageURL=[NSURL URLWithString:strUrl];
        banner.clipsToBounds=YES;
        banner.layer.cornerRadius=25;
        [banner setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:banner];
        
        
        NSString *strOnline=[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_online"]];
        if([strOnline isEqualToString:@"1"]){
            AsyncImageView *bannerOnline=[[AsyncImageView alloc]initWithFrame:CGRectMake(24, 15,9,9)];
            bannerOnline.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            bannerOnline.image=[UIImage imageNamed:@"onile"];
            bannerOnline.clipsToBounds=YES;
            [bannerOnline setContentMode:UIViewContentModeScaleAspectFill];
            [cell.contentView addSubview:bannerOnline];
        }
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 15,self.view.frame.size.width-190,50)];
        [name setFont:[UIFont boldSystemFontOfSize:16]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textColor=[UIColor blackColor];
        name.text=[dict objectForKey:@"name"];
        [cell.contentView addSubview:name];
        

        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 79, SCREEN_SIZE.width-40, 1)];
        sepView.backgroundColor=[UIColor blackColor];
        [cell.contentView addSubview:sepView];
        return cell;
    }
    
    NSDictionary *dict=[self.allMessages objectAtIndex:indexPath.row];
    NSString *have_media=[dict objectForKey:@"have_media"];
    UIView *chatBubble;
    if([have_media isEqualToString:@"6"]){
         chatBubble = [self createMessageWithText:@"Play Audio" Image:[dict objectForKey:@"Image"] DateTime:[dict objectForKey:@"DateTime"] isReceived:[[dict objectForKey:@"isReceived"] intValue] isVideo:@"audio" name:[dict objectForKey:@"name"] msgStatus:[dict objectForKey:@"msgStatus"] tagValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else{
         chatBubble = [self createMessageWithText:[dict objectForKey:@"Text"] Image:[dict objectForKey:@"Image"] DateTime:[dict objectForKey:@"DateTime"] isReceived:[[dict objectForKey:@"isReceived"] intValue] isVideo:[dict objectForKey:@"isVideo"] name:[dict objectForKey:@"name"] msgStatus:[dict objectForKey:@"msgStatus"] tagValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
   //[self.allMessages objectAtIndex:indexPath.row];
    chatBubble.tag = indexPath.row;

//    for (int i=0; i<cell.contentView.subviews.count; i++)
//    {
//        UIView *subV = cell.contentView.subviews[i];
//
//        if (subV.tag != chatBubble.tag)
//            [subV removeFromSuperview];
//
//    }
    
    [cell.contentView addSubview:chatBubble];
    
    cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    UILongPressGestureRecognizer *tapGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTapGesture:)];
    [cell addGestureRecognizer:tapGesture];
    
    
    if(deleteRow){
        NSNumber *rowNsNum = [NSNumber numberWithUnsignedInt:indexPath.row];
         if ( [selectedDeletedRows containsObject:rowNsNum] )
        cell.backgroundColor=[UIColor lightGrayColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_tblForward == tableView){
        return 80;
    }
    NSDictionary *dict=[self.allMessages objectAtIndex:indexPath.row];
    NSString *have_media=[dict objectForKey:@"have_media"];
    UIView *chatBubble;
    if([have_media isEqualToString:@"6"]){
        chatBubble = [self createMessageWithText:@"Play Audio" Image:[dict objectForKey:@"Image"] DateTime:[dict objectForKey:@"DateTime"] isReceived:[[dict objectForKey:@"isReceived"] intValue] isVideo:@"audio" name:[dict objectForKey:@"name"] msgStatus:[dict objectForKey:@"msgStatus"] tagValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else{
        chatBubble = [self createMessageWithText:[dict objectForKey:@"Text"] Image:[dict objectForKey:@"Image"] DateTime:[dict objectForKey:@"DateTime"] isReceived:[[dict objectForKey:@"isReceived"] intValue] isVideo:[dict objectForKey:@"isVideo"] name:[dict objectForKey:@"name"] msgStatus:[dict objectForKey:@"msgStatus"] tagValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    
   
    return chatBubble.frame.size.height+20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_tblForward == tableView){
        NSInteger rowVal=indexPath.row;
        [self forwardMsg:rowVal];
        return;
    }
    
    [textView resignFirstResponder];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
    [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
    
    if ( !deleteRow )
        return;
    
    [self.chatTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *rowNsNum = [NSNumber numberWithUnsignedInt:indexPath.row];
    if ( [selectedDeletedRows containsObject:rowNsNum] )
        [selectedDeletedRows removeObject:rowNsNum];
    else
        [selectedDeletedRows addObject:rowNsNum];
    
    [_chatTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     UIView *hedderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 50)];
    hedderView.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 5,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[_dictChatData objectForKey:@"image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    banner.layer.cornerRadius=25;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [hedderView addSubview:banner];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 5,self.view.frame.size.width-90,50)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor whiteColor];
    name.text=@"Last login at  2 hours ago.";//[_dictChatData objectForKey:@"name"];
    [hedderView addSubview:name];
    
    return hedderView;
}

#pragma mark - Buttons' Actions

- (void)sendAction: (id)selector
{
    NSString *strMSg=[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strMSg.length==0){
        return;
    }
    
    
    
    NSString *uniText = [NSString stringWithUTF8String:[textView.text UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *username = [prefs stringForKey:@"username"];
    NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
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
    
    

    NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
    NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
    NSString *isVideo=@"no";
    if(!([strvideo_thumb isEqualToString:@""])){
        isVideo=@"yes";
        strUrl=strvideo_thumb;
    }
    NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
    NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
    if([strFromId isEqualToString:USERID]){
        
        
        
        
        NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
        [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
        [dictForMsg setValue:strUrl forKey:@"Image"];
        [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
        [dictForMsg setValue:@"0" forKey:@"isReceived"];
        [dictForMsg setValue:isVideo forKey:@"isVideo"];
        [dictForMsg setValue:username forKey:@"name"];
        [dictForMsg setValue:strread_status forKey:@"msgStatus"];
        [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
        
        [self.allMessages addObject:dictForMsg];
      
        
    }else{
        
        NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
        [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
        [dictForMsg setValue:strUrl forKey:@"Image"];
        [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
        [dictForMsg setValue:@"1" forKey:@"isReceived"];
        [dictForMsg setValue:isVideo forKey:@"isVideo"];
        [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
        [dictForMsg setValue:strread_status forKey:@"msgStatus"];
        [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
        
        [self.allMessages addObject:dictForMsg];
        
        
    }
    [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
   
    [self.chatTableView reloadData];
    [self scrollToTheBottom:YES];

    
    [textView resignFirstResponder];
    textView.text = @"";
    [self resignTextView];
    [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
}

#pragma mark - Message UI creation function(s)

- (UIView*)createMessageWithText: (NSString*)text Image: (NSString*)image DateTime: (NSString*)dateTimeString isReceived: (BOOL)isReceived isVideo:(NSString *)isVideo name:(NSString *)name msgStatus:(NSString *)msgStatus tagValue:(NSString *)tagValue
{
    
    const char *jsonString = [text UTF8String];
    NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    text=msg;
        //Get screen width
    double screenWidth = self.view.frame.size.width;

    CGFloat maxBubbleWidth = screenWidth-50;
    
    UIView *outerView = [[UIView alloc] init];
    
    UIView *chatBubbleView = [[UIView alloc] init];
    chatBubbleView.backgroundColor = [UIColor whiteColor];
    chatBubbleView.layer.masksToBounds = YES;
    chatBubbleView.clipsToBounds = NO;
    chatBubbleView.layer.cornerRadius = 4;
    chatBubbleView.layer.shadowOffset = CGSizeMake(0, 0.7);
    chatBubbleView.layer.shadowRadius = 4;
    chatBubbleView.layer.shadowOpacity = 0.4;
    
    UIView *chatBubbleContentView = [[UIView alloc] init];
    chatBubbleContentView.backgroundColor = [UIColor whiteColor];
    chatBubbleContentView.clipsToBounds = YES;
    
    //Add time
    UILabel *lblName;
    if (dateTimeString != nil)
    {
        lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 16)];
        lblName.font = [UIFont systemFontOfSize:10];
        lblName.text = name;
        lblName.textColor = [UIColor blackColor];
        
        [chatBubbleContentView addSubview:lblName];
    }
    
    //Add Image
    AsyncImageView *chatBubbleImageView;
    AsyncImageView *playicon;
    if (!([image isEqualToString:@"http://iblah-blah.com/iblah/images/"]))
    {
        
        
        if([isVideo isEqualToString:@"audio"]){
            //
 
            
            
            
            chatBubbleImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 26, maxBubbleWidth-30, 30)];
            chatBubbleImageView.image=[UIImage imageNamed:@"playIcon"];
            chatBubbleImageView.contentMode = UIViewContentModeScaleAspectFit;
            chatBubbleImageView.layer.masksToBounds = YES;
            
            chatBubbleImageView.tag=[tagValue integerValue];
            [chatBubbleContentView addSubview:chatBubbleImageView];
            
            chatBubbleImageView.userInteractionEnabled=YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPlayAudio:)];
            [chatBubbleImageView addGestureRecognizer:tap];
            [chatBubbleImageView setUserInteractionEnabled:YES];
            
           
        }else{
            chatBubbleImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 26, maxBubbleWidth-30, maxBubbleWidth-30)];
            chatBubbleImageView.imageURL = [NSURL URLWithString:image];
            chatBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
            chatBubbleImageView.layer.masksToBounds = YES;
            chatBubbleImageView.layer.cornerRadius = 4;
            chatBubbleImageView.tag=[tagValue integerValue];
            [chatBubbleContentView addSubview:chatBubbleImageView];
            
            if([isVideo isEqualToString:@"yes"]){
                playicon=[[AsyncImageView alloc]init];
                playicon.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                playicon.image=[UIImage imageNamed:@"playIcon"];
                playicon.clipsToBounds=YES;
                [playicon setContentMode:UIViewContentModeScaleAspectFill];
                [chatBubbleContentView addSubview:playicon];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTappedVideo:)];
                [chatBubbleImageView addGestureRecognizer:tap];
                [chatBubbleImageView setUserInteractionEnabled:YES];
            }
            else{
                chatBubbleImageView.userInteractionEnabled=YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
                [chatBubbleImageView addGestureRecognizer:tap];
                [chatBubbleImageView setUserInteractionEnabled:YES];
            }
        }
     
        
    }
    
    //Add Text
    UILabel *chatBubbleLabel;
    if (text != nil)
    {
        UIFont *messageLabelFont = [UIFont systemFontOfSize:16];
        
        CGSize maximumLabelSize;
        if (chatBubbleImageView != nil)
        {
            maximumLabelSize = CGSizeMake(chatBubbleImageView.frame.size.width, 1000);

            CGSize expectedLabelSize = [text sizeWithFont:messageLabelFont constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
            
            chatBubbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 21+chatBubbleImageView.frame.size.height, expectedLabelSize.width, expectedLabelSize.height+10)];
        }
        else
        {
            maximumLabelSize = CGSizeMake(maxBubbleWidth, 1000);
            
            CGSize expectedLabelSize = [text sizeWithFont:messageLabelFont constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
            
            chatBubbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, expectedLabelSize.width, expectedLabelSize.height)];
        }
        
        chatBubbleLabel.frame = CGRectMake(chatBubbleLabel.frame.origin.x, chatBubbleLabel.frame.origin.y+5, chatBubbleLabel.frame.size.width, chatBubbleLabel.frame.size.height+10);
        
        chatBubbleLabel.text = text;
        chatBubbleLabel.font = messageLabelFont;
        chatBubbleLabel.numberOfLines = 100;
        
        [chatBubbleContentView addSubview:chatBubbleLabel];
   
        
    }
    UIButton *btnEdit;
    if([text isEqualToString:@""]){
        NSString *strread_status=[NSString stringWithFormat:@"%@",msgStatus];
        btnEdit = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(chatBubbleImageView.frame), 100, 32)];
        
        if([strread_status isEqualToString:@"1"]){
            
            [btnEdit setImage:[UIImage imageNamed:@"tick_grey"] forState:UIControlStateNormal];
        }else if([strread_status isEqualToString:@"3"]){
            [btnEdit setImage:[UIImage imageNamed:@"tick_pink"] forState:UIControlStateNormal];
        }else if([strread_status isEqualToString:@"2"]){
            [btnEdit setImage:[UIImage imageNamed:@"tick_blue"] forState:UIControlStateNormal];
        }
        btnEdit.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnEdit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        NSString *strDate=[NSString stringWithFormat:@"%@",dateTimeString];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *date = [dateFormat dateFromString:strDate];
        [dateFormat setDateFormat:@"hh:mm"];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strDatetoShow=[dateFormat stringFromDate:date];
        
        
        [btnEdit setTitle:strDatetoShow forState:UIControlStateNormal];
        [chatBubbleContentView addSubview:btnEdit];
    }else{
        NSString *strread_status=[NSString stringWithFormat:@"%@",msgStatus];
        btnEdit = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(chatBubbleLabel.frame), 100, 32)];
        
        if([strread_status isEqualToString:@"1"]){
            
            [btnEdit setImage:[UIImage imageNamed:@"tick_grey"] forState:UIControlStateNormal];
        }else if([strread_status isEqualToString:@"3"]){
            [btnEdit setImage:[UIImage imageNamed:@"tick_pink"] forState:UIControlStateNormal];
            
        }else if([strread_status isEqualToString:@"2"]){
            [btnEdit setImage:[UIImage imageNamed:@"tick_blue"] forState:UIControlStateNormal];
        }
        btnEdit.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnEdit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        NSString *strDate=[NSString stringWithFormat:@"%@",dateTimeString];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *date = [dateFormat dateFromString:strDate];
        [dateFormat setDateFormat:@"hh:mm"];
        [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
        NSString *strDatetoShow=[dateFormat stringFromDate:date];
        
        
        [btnEdit setTitle:strDatetoShow forState:UIControlStateNormal];
        [chatBubbleContentView addSubview:btnEdit];
    }
   // [chatBubbleContentView bringSubviewToFront:chatBubbleImageView];
    [chatBubbleView addSubview:chatBubbleContentView];
    
    CGFloat totalHeight = 0;
    CGFloat decidedWidth = 0;
    for (UIView *subView in chatBubbleContentView.subviews)
    {
        totalHeight += subView.frame.size.height;
        
        CGFloat width = subView.frame.size.width;
        if (decidedWidth < width)
            decidedWidth = width;
    }
    
    chatBubbleContentView.frame = CGRectMake(5, 5, decidedWidth, totalHeight);
    chatBubbleView.frame = CGRectMake(10, 10, chatBubbleContentView.frame.size.width+10, chatBubbleContentView.frame.size.height+10);
    
    playicon.frame=CGRectMake((chatBubbleContentView.frame.size.width/2)-16, (chatBubbleContentView.frame.size.height/2)-16,32,32);
    
    outerView.frame = CGRectMake(7, 0, chatBubbleView.frame.size.width, chatBubbleView.frame.size.height);
    
    UIImageView *arrowIV = [[UIImageView alloc] init];
    [outerView addSubview:chatBubbleView];
    arrowIV.image = [UIImage imageNamed:@"chat_arrow"];
    arrowIV.clipsToBounds = NO;
    arrowIV.layer.shadowRadius = 4;
    arrowIV.layer.shadowOpacity = 0.4;
    arrowIV.layer.shadowOffset = CGSizeMake(-7.0, 0.7);
    arrowIV.layer.zPosition = 1;
    arrowIV.frame = CGRectMake(chatBubbleView.frame.origin.x-7, chatBubbleView.frame.size.height-10, 11, 14);

    if (isReceived == 0)
    {
        chatBubbleContentView.frame = CGRectMake(5, 5, decidedWidth, totalHeight);
        chatBubbleView.frame = CGRectMake(screenWidth-(chatBubbleContentView.frame.size.width+10)-10, 10, chatBubbleContentView.frame.size.width+10, chatBubbleContentView.frame.size.height+10);
        
        
        chatBubbleView.backgroundColor = Rgb2UIColor(0,160,223);
        lblName.textColor = [UIColor whiteColor];
        chatBubbleLabel.textColor = [UIColor whiteColor];
       chatBubbleContentView.backgroundColor = Rgb2UIColor(0,160,223);
        //[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]
        [btnEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        arrowIV.transform = CGAffineTransformMakeScale(-1, 1);
        arrowIV.frame = CGRectMake(chatBubbleView.frame.origin.x+chatBubbleView.frame.size.width-4, chatBubbleView.frame.size.height-10, 11, 14);
        
        outerView.frame = CGRectMake(screenWidth-((screenWidth+chatBubbleView.frame.size.width)-chatBubbleView.frame.size.width)-7, 0, chatBubbleView.frame.size.width, chatBubbleView.frame.size.height);

        arrowIV.image = [arrowIV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [arrowIV setTintColor:Rgb2UIColor(0,160,223)];
    }
    
    [outerView addSubview:arrowIV];
    
    return outerView;
}

#pragma mark - Other functions



- (void)scrollToTheBottom:(BOOL)animated
{
    if (self.allMessages.count>0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (NSString*)getDateTimeStringFromNSDate: (NSDate*)date
{
    NSString *dateTimeString = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM, hh:mm a"];
    dateTimeString = [dateFormatter stringFromDate:date];
    
    return dateTimeString;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    [_chatTableView setFrame:CGRectMake(_chatTableView.frame.origin.x
                                     , _chatTableView.frame.origin.y, _chatTableView.frame.size.width, SCREEN_SIZE.height-114)];
    
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

    // set views with new info
    containerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardDidShow:(NSNotification *)note{
    
    
    
    NSDictionary* info = [note userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= kbSize.height;
    
    float height =20;
    float yPoint = aRect.size.height-height;
    
    
    [_chatTableView setFrame:CGRectMake(_chatTableView.frame.origin.x
                                     , _chatTableView.frame.origin.y, _chatTableView.frame.size.width, yPoint)];
    
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    
   // mSocket.emit("startTyoing", friendship_ID, friend_id);
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
    [appDelegate().socket emit:@"startTyoing" with:@[strFriendId,struser_id]];
    
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}

- (void)smallButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    
    imageInfo.image = img.image;
    imageInfo.referenceRect = img.frame;
    imageInfo.referenceView = img.superview;
    imageInfo.referenceContentMode = img.contentMode;
    imageInfo.referenceCornerRadius = img.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}

- (void)addPlayAudio:(UITapGestureRecognizer *)tapRecognizer {
    NSLog(@"Hello Bye");
    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
    NSInteger tagValue=img.tag;
    NSDictionary *dict=[self.allMessagesFromApi objectAtIndex:tagValue];
    
//    _playAudioView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.4];
//    _playAudioView.frame=CGRectMake(0, -SCREEN_SIZE.height,SCREEN_SIZE.width, SCREEN_SIZE.height);
//    [self.view addSubview:_playAudioView];
//    [UIView animateWithDuration:1.0f
//                          delay:0.0
//         usingSpringWithDamping:0.5
//          initialSpringVelocity:5.0
//                        options:0
//                     animations:^{ _playAudioView.frame = CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height); }
//                     completion:^(BOOL finished) {
//                         // slide down animation finished, remove the older view and the constraints
//
//                     }];
    
    NSString *strVideoUrl=[NSString stringWithFormat:@"http://iblah-blah.com/iblah/audio/%@",[dict objectForKey:@"image_url"]];
   // NSURL  *url = [NSURL URLWithString:strVideoUrl];
    
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:strVideoUrl]];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
    
    
//    NSData *soundData = [NSData dataWithContentsOfURL:url];
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                               NSUserDomainMask, YES) objectAtIndex:0]
//                          stringByAppendingPathComponent:@"sound.caf"];
//    [soundData writeToFile:filePath atomically:YES];
//
//    // get the file from directory
//    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//    NSString *documentsDirectory = [pathArray objectAtIndex:0];
//    NSString *soundPath = [documentsDirectory stringByAppendingPathComponent:@"sound.caf"];
//
//    NSURL *soundUrl;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
//    {
//        soundUrl = [NSURL fileURLWithPath:soundPath isDirectory:NO];
//    }
//    NSError* error = nil;
//
//    self.player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
//    if(!self.player1)
//    {
//        NSLog(@"Error creating player: %@", error);
//    }
//    self.player1.delegate = self;
//    [self.player1 prepareToPlay];
//    // Fill in the labels that do not change
//   // self.durationLabel.text = [NSString stringWithFormat:@"%.02fs",self.player.duration];
//  //  self.numberOfChannelsLabel.text = [NSString stringWithFormat:@"%d", self.player.numberOfChannels];
//    self.currentTimeSlider.minimumValue = 0.0f;
//    self.currentTimeSlider.maximumValue = self.player1.duration;
//    [self updateDisplay];
    
    
}
- (void)smallButtonTappedVideo:(UITapGestureRecognizer *)tapRecognizer {
    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
    NSInteger tagValue=img.tag;
    NSDictionary *dict=[self.allMessagesFromApi objectAtIndex:tagValue];

    
    
    NSString *strVideoUrl=[dict objectForKey:@"video_url"];
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:strVideoUrl]];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
     checkAudio=NO;
    if(checkImgVideo){
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
        checkVideoImage=YES;
        chosenImage=[self compressImage:chosenImage];
        [self uploadThumb:chosenImage];
            // _imgUserImage.image=chosenImage;
    }else{
        videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        if(videoURL){
            PHImageRequestOptions *option = [PHImageRequestOptions new];
            option.synchronous = YES;
            [[PHImageManager defaultManager] requestImageForAsset:[info objectForKey:UIImagePickerControllerPHAsset] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage *result, NSDictionary *info) {
               // [self saveVideo:result];
                [self divide_data_into_pieces:result];
            }];
        }
        
        NSLog(@"VideoURL = %@", videoURL);
    }
  [picker dismissViewControllerAnimated:YES completion:NULL];
        // This is the NSURL of the video object
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
-(void)saveVideo:(UIImage *)img{
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"send_video" forKey:@"action"];
    [dict setValue:@"ios" forKey:@"device"];
    
    NSData *data = UIImagePNGRepresentation(img);
    [dict setObject:[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] forKey:@"thumb"];
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@",url];
    
    NSData *VideoData=[NSData dataWithContentsOfURL:videoURL];
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
            // [formData   appendPartWithFileData:[NSData dataWithContentsOfURL:self.videoUrl] name:@"file" fileName:@"test" mimeType:@"mov"];
        [formData appendPartWithFileData:VideoData name:@"file" fileName:@"test" mimeType:@"mov"]; // you file to upload
                                                                                                                                 // [formData appendPartWithFileURL:self.videoUrl name:@"file" error:nil];
        /*appendPartWithFileURL   used if you want to upload large saved files and not data*/
        
    } error:nil];
        //    [upload_request setHTTPMethod:@"POST"];
        //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
        //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [upload_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [upload_request setHTTPShouldHandleCookies:NO];
        // [upload_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        // [upload_request setHTTPBody:postData];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSURLSessionUploadTask *uploadFileTask;
    uploadFileTask = [manager
                      uploadTaskWithStreamedRequest:upload_request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                                  //since the call back is not on main queue we get the main queue ourself
                              NSLog(@"%f",uploadProgress.fractionCompleted);//Log the progress or pass it to progressview
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              [ind removeFromSuperview];
                              NSLog(@"OOPS!!!! %@", error);
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              [ind removeFromSuperview];
                              if (error != nil) {
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                                  NSLog(@"Error parsing JSON.");
                              }
                              else {
                                  NSLog(@"success.");
                                  //srtThumb =[jsonArray objectForKey:@"thumb"];
                                  //strVideo=[jsonArray objectForKey:@"video"];
                                  NSString *uniText = [NSString stringWithUTF8String:[textView.text UTF8String]];
                                  NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
                                  NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
                                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                  NSString *USERID = [prefs stringForKey:@"USERID"];
                                  NSString *username = [prefs stringForKey:@"username"];
                                  NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
                                  NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
                                  NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
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
                                  [dict setValue:@"2" forKey:@"have_media"];
                                  [dict setValue:[jsonArray objectForKey:@"video"] forKey:@"video_url"];
                                  [dict setValue:[jsonArray objectForKey:@"thumb"] forKey:@"video_thumb"];
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
                                  [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
                                  
                                  NSString *strUrl=[NSString stringWithFormat:@"%images/%@",BASEURl,[dict objectForKey:@"image_url"]];
                                  NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
                                  NSString *isVideo=@"no";
                                  if(!([strvideo_thumb isEqualToString:@""])){
                                      isVideo=@"yes";
                                      strUrl=strvideo_thumb;
                                  }
                                  NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
                                  NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
                                  if([strFromId isEqualToString:USERID]){
                                      
                                      
                                      NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                                      [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                                       [dictForMsg setValue:strUrl forKey:@"Image"];
                                       [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                                       [dictForMsg setValue:@"0" forKey:@"isReceived"];
                                       [dictForMsg setValue:isVideo forKey:@"isVideo"];
                                       [dictForMsg setValue:username forKey:@"name"];
                                       [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                                       [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                                      
                                      [self.allMessages addObject:dictForMsg];
                                      

                                      
                                  }else{
                                      
                                      
                                      NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                                      [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                                      [dictForMsg setValue:strUrl forKey:@"Image"];
                                      [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                                      [dictForMsg setValue:@"1" forKey:@"isReceived"];
                                      [dictForMsg setValue:isVideo forKey:@"isVideo"];
                                     [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
                                      [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                                      [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                                      
                                      [self.allMessages addObject:dictForMsg];
                                      
                                      
                                      
                                      
                                  }
                                  [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
                                  
                                  [self.chatTableView reloadData];
                                  [self scrollToTheBottom:YES];
                                  
                                  
                                  [textView resignFirstResponder];
                                  textView.text = @"";
                                  [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
                                  textView.text=@"";
                                  
                              }
                              
                              
                          }
                      }];
    
    [uploadFileTask resume];
}


-(void)addImage:(UIImage *)imgg{
   // self.view.userInteractionEnabled=NO;
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"ios" forKey:@"device"];
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    url=[NSString stringWithFormat:@"%@?action=send_image",url];//action=iblahSignUp
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *imageData ;
   
        imageData   = [NSData dataWithData:UIImageJPEGRepresentation(imgg,0.8)];
    
    NSMutableURLRequest *upload_request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"image" mimeType:@"png"];
        
        
        
    } error:nil];
        //    [upload_request setHTTPMethod:@"POST"];
        //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
        //    [upload_request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [upload_request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [upload_request setHTTPShouldHandleCookies:NO];
        // [upload_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        // [upload_request setHTTPBody:postData];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSURLSessionUploadTask *uploadFileTask;
    uploadFileTask = [manager
                      uploadTaskWithStreamedRequest:upload_request
                      progress:^(NSProgress * _Nonnull uploadProgress) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                                  //since the call back is not on main queue we get the main queue ourself
                              NSLog(@"%f",uploadProgress.fractionCompleted);//Log the progress or pass it to progressview
                          });
                      }
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              NSLog(@"OOPS!!!! %@", error);
                              [ind removeFromSuperview];
                              self.view.userInteractionEnabled=YES;
                              [AlertView showAlertWithMessage:@"Please try Again" view:self];
                          } else {
                              NSLog(@"%@ %@", response, responseObject);
                              
                              NSError *error = nil;
                              NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
                              [ind removeFromSuperview];
                              if (error != nil) {
                                  [AlertView showAlertWithMessage:@"Please try Again" view:self];
                                  NSLog(@"Error parsing JSON.");
                              }
                              else {
                                  NSLog(@"success.");
                                      //srtThumb =[jsonArray objectForKey:@"thumb"];
                                      //strVideo=[jsonArray objectForKey:@"video"];
                                 
                              }
                          }
                      }];
    
    [uploadFileTask resume];
    
}

-(void)cmdVideoCall:(id)sender{
     [self callWithConferenceType:QBRTCConferenceTypeVideo];
}
-(void)cmdCall:(id)sender{
    
    [self callWithConferenceType:QBRTCConferenceTypeAudio];

}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    
    if (self.session) {
        return;
    }
    
    if ([self hasConnectivity]) {
        
        [QBAVCallPermissions checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
            
            if (granted) {
                NSNumber *IDOpp=[NSNumber numberWithInteger:[[_dictChatData objectForKey:@"caller_id"]integerValue]];
                
                NSArray *opponentsIDs = @[IDOpp];
                    //Create new session
                QBRTCSession *session =
                [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                                 withConferenceType:conferenceType];
                if (session) {
                    
                    self.session = session;
                    
                    NSUUID *uuid = nil;
                    if (CallKitManager.isCallKitAvailable) {
                        uuid = [NSUUID UUID];
                        [CallKitManager.instance startCallWithUserIDs:opponentsIDs session:session uuid:uuid];
                    }
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Call" bundle:nil];
                    CallViewController *callViewController = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
                    callViewController.session = self.session;
                    callViewController.usersDatasource = self.dataSource;
                    callViewController.callUUID = uuid;
                   // [self.navigationController pushViewController:callViewController animated:YES];
                    self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
                    self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

                  //  [self.navigationController presentViewController:callViewController animated:NO completion:nil];
                    
                    [self presentViewController:self.nav animated:NO completion:nil];
                    
                    NSDictionary *payload = @{
                                              @"message"  : [NSString stringWithFormat:@"%@ is calling you.", Core.currentUser.fullName],
                                              @"ios_voip" : @"1",
                                              kVoipEvent  : @"1",
                                              //@"sound"    : @"ringtone.wav"
                                              };
                    NSData *data =
                    [NSJSONSerialization dataWithJSONObject:payload
                                                    options:NSJSONWritingPrettyPrinted
                                                      error:nil];
                    NSString *message =
                    [[NSString alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
                    
                    QBMEvent *event = [QBMEvent event];
                    event.notificationType = QBMNotificationTypePush;
                    event.usersIDs = [opponentsIDs componentsJoinedByString:@","];
                    event.type = QBMEventTypeOneShot;
                    
                    event.message = message;
                    
                    [QBRequest createEvent:event
                              successBlock:^(QBResponse *response, NSArray<QBMEvent *> *events) {
                                  NSLog(@"Send voip push - Success");
                                  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                  NSString *USERID = [prefs stringForKey:@"USERID"];
                                  NSString *profile_pic = [prefs stringForKey:@"profile_pic"];
                                  NSString *username = [prefs stringForKey:@"username"];
                                  [appDelegate().socket emit:@"startCall" with:@[USERID,username,profile_pic]];
                                 // mSocket.emit("startCall", friend_id, sender_name, sender_img);
                              } errorBlock:^(QBResponse * _Nonnull response) {
                                  NSLog(@"Send voip push - Error");
                              }];
                }
                else {
                    
                    [SVProgressHUD showErrorWithStatus:@"Session hasn’t been created. Please try again."];
                }
            }
        }];
    }
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
            [CallKitManager.instance endCallWithUUID:self.callUUID completion:nil];
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
        incomingViewController.usersDatasource = self.dataSource;
        
        self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
        [self presentViewController:self.nav animated:NO completion:nil];
    }
}

-(void)uploadThumb:(UIImage *)thumbImage{
    [self.view addSubview:indd];
    [arryChunkData removeAllObjects];
    arryChunkData=nil;
    arryChunkData=[[NSMutableArray alloc]init];
    
    NSData* myBlob=UIImagePNGRepresentation(thumbImage);
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
        
        [arryChunkData addObject:base64String];
        // do something with chunk
    } while (offset < length);
    
    if(arryChunkData.count>0){//872360
        
        dictJson=nil;
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.png",uuid];
        
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];

        dictJson=[[NSMutableDictionary alloc]init];
        [dictJson setValue:uuid forKey:@"Name"];
        [dictJson setValue:StrSize forKey:@"Size"];
        [dictJson setValue:@"false" forKey:@"IsVideo"];
        [dictJson setValue:@"false" forKey:@"IsAudio"];
        [dictJson setValue:USERID forKey:@"from_id"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
        [self uploadImageVideo];
    }
    
}

#pragma mark Listner
-(void)uploadImageVideo{
   __block NSString *USERID = [dictJson objectForKey:@"Name"];
    [appDelegate().socket on:USERID callback:^(NSArray* data, SocketAckEmitter* ack) {// 39 for get all post
        
       [appDelegate().socket off:USERID];
        
        if(checkAudio){
            NSString *uniText = [NSString stringWithUTF8String:[textView.text UTF8String]];
            NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *USERID = [prefs stringForKey:@"USERID"];
            NSString *username = [prefs stringForKey:@"username"];
            NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
            NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
            NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
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
            [dict setValue:@"6" forKey:@"have_media"];
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
            [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"image_url"];
            
            [dict setValue:strFriendId forKey:@"friendship_ID"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                               options:0
                                                                 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
            [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
            
            NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
            NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
            NSString *isVideo=@"no";
            if(!([strvideo_thumb isEqualToString:@""])){
                isVideo=@"yes";
                strUrl=strvideo_thumb;
            }
            NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
            NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
            if([strFromId isEqualToString:USERID]){
                
                
                NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                [dictForMsg setValue:strUrl forKey:@"Image"];
                [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                [dictForMsg setValue:@"0" forKey:@"isReceived"];
                [dictForMsg setValue:isVideo forKey:@"isVideo"];
                [dictForMsg setValue:@"6" forKey:@"have_media"];
                [dictForMsg setValue:username forKey:@"name"];
                [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                
                [self.allMessages addObject:dictForMsg];
                
            }else{
                
                
                NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                [dictForMsg setValue:strUrl forKey:@"Image"];
                [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                [dictForMsg setValue:@"1" forKey:@"isReceived"];
                [dictForMsg setValue:isVideo forKey:@"isVideo"];
                [dictForMsg setValue:@"6" forKey:@"have_media"];
                [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
                [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                
                
            }
            [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
            [self.chatTableView reloadData];
            [self scrollToTheBottom:YES];
            
            [textView resignFirstResponder];
            textView.text = @"";
            [self resignTextView];
            [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
            textView.text=@"";
            [indd removeFromSuperview];

        }else{
            if(checkImgVideo){
                NSString *uniText = [NSString stringWithUTF8String:[textView.text UTF8String]];
                NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
                NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *USERID = [prefs stringForKey:@"USERID"];
                NSString *username = [prefs stringForKey:@"username"];
                NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
                NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
                NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
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
                [dict setValue:[dictJson objectForKey:@"Name"] forKey:@"image_url"];
                
                [dict setValue:strFriendId forKey:@"friendship_ID"];
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                                   options:0
                                                                     error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
                [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
                
                NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image_url"]];
                NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
                NSString *isVideo=@"no";
                if(!([strvideo_thumb isEqualToString:@""])){
                    isVideo=@"yes";
                    strUrl=strvideo_thumb;
                }
                NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
                NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
                if([strFromId isEqualToString:USERID]){
                    
                    
                    NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                    [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                    [dictForMsg setValue:strUrl forKey:@"Image"];
                    [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                    [dictForMsg setValue:@"0" forKey:@"isReceived"];
                    [dictForMsg setValue:isVideo forKey:@"isVideo"];
                    [dictForMsg setValue:username forKey:@"name"];
                    [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                    [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                    
                    [self.allMessages addObject:dictForMsg];
                    
                }else{
                    
                    
                    NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                    [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                    [dictForMsg setValue:strUrl forKey:@"Image"];
                    [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                    [dictForMsg setValue:@"1" forKey:@"isReceived"];
                    [dictForMsg setValue:isVideo forKey:@"isVideo"];
                    [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
                    [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                    [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                    
                    
                }
                [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
                [self.chatTableView reloadData];
                [self scrollToTheBottom:YES];
                
                [textView resignFirstResponder];
                textView.text = @"";
                 [self resignTextView];
                [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
                textView.text=@"";
                [indd removeFromSuperview];
            }else{
                if(UplodeVideo){
                    strVideo=[NSString stringWithFormat:@"http://iblah-blah.com/iblah/videos/%@",[dictJson objectForKey:@"Name"]];
                    UplodeVideo=false;
                    [self uploadThumb:thumbImage];
                    return;
                    
                }else{
                    
                    [indd removeFromSuperview];
                    srtThumb =[NSString stringWithFormat:@"http://iblah-blah.com/iblah/images/%@",[dictJson objectForKey:@"Name"]];
                    
                    
                    
                    NSLog(@"success.");
                    //srtThumb =[jsonArray objectForKey:@"thumb"];
                    //strVideo=[jsonArray objectForKey:@"video"];
                    NSString *uniText = [NSString stringWithUTF8String:[textView.text UTF8String]];
                    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
                    NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
                    NSString *username = [prefs stringForKey:@"username"];
                    NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
                    NSString *strFriendId=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"myFriend_id"]];
                    NSString *struser_id=[NSString stringWithFormat:@"%@",[_dictChatData objectForKey:@"user_id"]];
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
                    [dict setValue:@"2" forKey:@"have_media"];
                    [dict setValue:strVideo forKey:@"video_url"];
                    [dict setValue:srtThumb forKey:@"video_thumb"];
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
                    [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
                    
                    NSString *strUrl=[NSString stringWithFormat:@"%images/%@",BASEURl,[dict objectForKey:@"image_url"]];
                    NSString *strvideo_thumb=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
                    NSString *isVideo=@"no";
                    if(!([strvideo_thumb isEqualToString:@""])){
                        isVideo=@"yes";
                        strUrl=strvideo_thumb;
                    }
                    NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
                    NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
                    if([strFromId isEqualToString:USERID]){
                        
                        
                        NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                        [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                        [dictForMsg setValue:strUrl forKey:@"Image"];
                        [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                        [dictForMsg setValue:@"0" forKey:@"isReceived"];
                        [dictForMsg setValue:isVideo forKey:@"isVideo"];
                        [dictForMsg setValue:username forKey:@"name"];
                        [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                        [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                        
                        [self.allMessages addObject:dictForMsg];
                        
                    }else{
                        
                        NSMutableDictionary *dictForMsg=[[NSMutableDictionary alloc]init];
                        [dictForMsg setValue:[dict objectForKey:@"message"] forKey:@"Text"];
                        [dictForMsg setValue:strUrl forKey:@"Image"];
                        [dictForMsg setValue:[dict objectForKey:@"msg_time"] forKey:@"DateTime"];
                        [dictForMsg setValue:@"1" forKey:@"isReceived"];
                        [dictForMsg setValue:isVideo forKey:@"isVideo"];
                        [dictForMsg setValue:[_dictChatData objectForKey:@"name"] forKey:@"name"];
                        [dictForMsg setValue:strread_status forKey:@"msgStatus"];
                        [dictForMsg setValue:[NSString stringWithFormat:@"%lu",self.allMessagesFromApi.count] forKey:@"tagValue"];
                        
                        [self.allMessages addObject:dictForMsg];
                        
                    }
                    [self.allMessagesFromApi insertObject:dict atIndex:self.allMessagesFromApi.count];
                    
                    [self.chatTableView reloadData];
                    [self scrollToTheBottom:YES];
                    
                    
                    [textView resignFirstResponder];
                    textView.text = @"";
                     [self resignTextView];
                    [appDelegate().socket emit:@"sendStopTypingStatusRoom" with:@[strFriendId,struser_id]];
                    textView.text=@"";
                    
                    
                    
                    
                    return;
                }
            }
        }
        
        
        
        
    }];
    
}

- (void)divide_data_into_pieces:(UIImage *)img {
    [self.view addSubview:indd];
    UplodeVideo=YES;
    checkVideoImage=NO;
    arryChunkData=[[NSMutableArray alloc]init];
    thumbImage=img;
    
    
    NSData* myBlob=[NSData dataWithContentsOfURL:videoURL];
    NSUInteger length = [myBlob length];
    NSUInteger chunkSize = 1000 * 1024;
    NSUInteger offset = 0;
    do {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[myBlob bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        NSString *base64String = [chunk base64EncodedStringWithOptions:0];
        
        base64String = [base64String stringByReplacingOccurrencesOfString:@"/"
                                                               withString:@"_"];
        
        base64String = [base64String stringByReplacingOccurrencesOfString:@"+"
                                                               withString:@"-"];
        
        [arryChunkData addObject:base64String];
        // do something with chunk
    } while (offset < length);
    
    if(arryChunkData.count>0){
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.mov",uuid];
        
        
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
        // mSocket.emit("uploadFileStart", jsonObject);
        //http://iblah-blah.com/iblah/images/1527957175.jpg
        // http://iblah-blah.com/iblah/videos/1525623383_6900572568.mp4
        dictJson=[[NSMutableDictionary alloc]init];
        [dictJson setValue:uuid forKey:@"Name"];
        [dictJson setValue:StrSize forKey:@"Size"];
        [dictJson setValue:@"true" forKey:@"IsVideo"];
        [dictJson setValue:USERID forKey:@"from_id"];
        [dictJson setValue:@"false" forKey:@"IsAudio"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
        [self uploadImageVideo];
    }
    
}



- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(copy:) == action ||
       @selector(cmdDelete:) == action ||
       @selector(cmdForwardMsg:) == action) {
        result = YES;
    }
    return result;
}

// UIMenuController Methods

// Default copy method
- (void)copy:(id)sender {
    NSLog(@"Copy");
    NSDictionary *dict=[self.allMessages objectAtIndex:indexPathforSelectedRow.row];
    [UIPasteboard generalPasteboard].string = [dict objectForKey:@"Text"];

}

// Our custom method
- (void)cmdDelete:(id)sender {
    deleteRow=YES;
    selectedDeletedRows=nil;
    selectedDeletedRows=[[NSMutableArray alloc]init];
    [self addDeleteButton];
    
}

-(void)addDeleteButton{
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnCall.frame = CGRectMake(0, 0, 32, 32);
    [btnCall setTitle:@"Cancel" forState:UIControlStateNormal];
    //[btnCall setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
    [btnCall addTarget:self action:@selector(cmdCancelDelete:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnCall];
    [arrRightBarItems addObject:btnSearchBar];
    
    UIButton *btnVideoCall = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVideoCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVideoCall.frame = CGRectMake(0, 0, 32, 32);
    [btnVideoCall setTitle:@"Delete" forState:UIControlStateNormal];
    //[btnVideoCall setImage:[UIImage imageNamed:@"camera_on_ic"] forState:UIControlStateNormal];
    [btnVideoCall addTarget:self action:@selector(cmdDeleteMsg:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnBarVideoCall = [[UIBarButtonItem alloc] initWithCustomView:btnVideoCall];
    [btnBarVideoCall setTintColor:[UIColor whiteColor]];
    [arrRightBarItems addObject:btnBarVideoCall];
    
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}

-(void)addCallButton{
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnCall = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnCall.frame = CGRectMake(0, 0, 32, 32);
    //[btnCall setTitle:@"Call" forState:UIControlStateNormal];
    [btnCall setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
    [btnCall addTarget:self action:@selector(cmdCall:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnCall];
    [arrRightBarItems addObject:btnSearchBar];
    
    UIButton *btnVideoCall = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnVideoCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVideoCall.frame = CGRectMake(0, 0, 32, 32);
    //[btnCall setTitle:@"Call" forState:UIControlStateNormal];
    [btnVideoCall setImage:[UIImage imageNamed:@"camera_on_ic"] forState:UIControlStateNormal];
    [btnVideoCall addTarget:self action:@selector(cmdVideoCall:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnBarVideoCall = [[UIBarButtonItem alloc] initWithCustomView:btnVideoCall];
    [btnBarVideoCall setTintColor:[UIColor whiteColor]];
    [arrRightBarItems addObject:btnBarVideoCall];
    
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}
-(void)cmdCancelDelete:(id)sender{
    deleteRow=NO;
    selectedDeletedRows=nil;
    [_chatTableView reloadData];
    [self addCallButton];
}
-(void)cmdDeleteMsg:(id)sender{
    
    NSMutableArray *msgToDelete=[[NSMutableArray alloc]init];
    NSMutableArray *msgToDeletefromApi=[[NSMutableArray alloc]init];
    
    for (int i=0; i<selectedDeletedRows.count; i++) {
        
         NSString *str=[NSString stringWithFormat:@"%@",selectedDeletedRows[i]];
        NSDictionary *dictApi=[self.allMessagesFromApi objectAtIndex:[str integerValue]];
        NSDictionary *dictMgs=[self.allMessages objectAtIndex:[str integerValue]];
         [msgToDeletefromApi addObject:dictApi];
        [msgToDelete addObject:dictMgs];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"deleteMessages" with:@[USERID,[dictApi objectForKey:@"message_id"]]];
        
        
 //
    }
    for (int i=0; i<selectedDeletedRows.count; i++) {
        NSString *str=[NSString stringWithFormat:@"%@",selectedDeletedRows[i]];
        NSDictionary *dictApi=msgToDeletefromApi[[str integerValue]];
         NSDictionary *dictMgs=msgToDelete[[str integerValue]];
        
        [self.allMessages removeObject:dictMgs];
        [self.allMessagesFromApi removeObject:dictApi];
        
    }
    deleteRow=NO;
    selectedDeletedRows=nil;
    [_chatTableView reloadData];
    [self addCallButton];
}
-(void)cmdForwardMsg:(id)sender{
    _forwardView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.4];
    _forwardView.frame=CGRectMake(0, -SCREEN_SIZE.height,SCREEN_SIZE.width, SCREEN_SIZE.height);
    _tblForward.layer.cornerRadius=4;
    [self.view addSubview:_forwardView];
    [UIView animateWithDuration:1.0f
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5.0
                        options:0
                     animations:^{ _forwardView.frame = CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height); }
                     completion:^(BOOL finished) {
                         // slide down animation finished, remove the older view and the constraints
                         
                     }];
}

- (void)handleTapGesture:(UILongPressGestureRecognizer *)tapGesture {
    NSLog(@"tapGesture:");
    UITableViewCell *cell = (UITableViewCell *)tapGesture.view;
    //    CGRect targetRectangle = CGRectMake(100, 100, 100, 100);
    indexPathforSelectedRow = [self.chatTableView indexPathForCell:cell];
    [[UIMenuController sharedMenuController] setTargetRect:cell.frame
                                                    inView:_chatTableView];
    
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                      action:@selector(cmdDelete:)];
    
    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"Forward"
                                                      action:@selector(cmdForwardMsg:)];
    [[UIMenuController sharedMenuController]
     setMenuItems:@[menuItem,menuItem1]];
    [[UIMenuController sharedMenuController]
     setMenuVisible:YES animated:YES];
    
}
- (IBAction)cmdRemoveForwardView:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _forwardView.alpha = 0;
                     }completion:^(BOOL finished){
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         _forwardView.alpha = 1.0f;
                         // [self bringFront];
                         [_forwardView removeFromSuperview];
                     }];
    
}

-(void)forwardMsg:(NSInteger )row{
    
     NSDictionary *dictDetails=[self.allMessages objectAtIndex:indexPathforSelectedRow.row];
    NSDictionary *dictForward=[self.reasentChat objectAtIndex:row];
    NSDictionary *dictApi=[self.allMessagesFromApi objectAtIndex:indexPathforSelectedRow.row];

    NSString *uniText = [NSString stringWithUTF8String:[[dictDetails objectForKey:@"Text"] UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodMsg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *username = [prefs stringForKey:@"username"];
    NSString *profile_pic =[prefs stringForKey:@"profile_pic"];
    NSString *strFriendId=[NSString stringWithFormat:@"%@",[dictForward objectForKey:@"myFriend_id"]];
    NSString *struser_id=[NSString stringWithFormat:@"%@",[dictForward objectForKey:@"user_id"]];
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
    NSString *strImage=[dictDetails objectForKey:@"Image"];
    
    NSString *strhave_media=[dictDetails objectForKey:@"have_media"];
    if([strhave_media isEqualToString:@"6"]){
        [dict setValue:@"6" forKey:@"have_media"];
        [dict setValue:@"1" forKey:@"type"];
        strImage=[strImage  stringByReplacingOccurrencesOfString:@"http://iblah-blah.com/iblah/images/" withString:@""];
        [dict setValue:strImage forKey:@"image_url"];
    }else{
        if([strImage isEqualToString:@"http://iblah-blah.com/iblah/images/"] ){
            [dict setValue:@"0" forKey:@"have_media"];
            [dict setValue:@"1" forKey:@"type"];
            [dict setValue:@"" forKey:@"image_url"];
        }else if(!([strImage rangeOfString:@"https://maps.googleapis.com/maps/api/staticmap"].location == NSNotFound)){
            [dict setValue:@"1" forKey:@"have_media"];
            [dict setValue:@"5" forKey:@"type"];
            [dict setValue:strImage forKey:@"image_url"];
            [dict setValue:@"0.00" forKey:@"lat"];
            [dict setValue:@"0.00" forKey:@"log"];
        }else if([[dictDetails objectForKey:@"isVideo"] isEqualToString:@"yes"]){
            [dict setValue:@"1" forKey:@"have_media"];
            [dict setValue:@"2" forKey:@"type"];
            [dict setValue:@"" forKey:@"image_url"];
            [dict setValue:[dictApi objectForKey:@"video_url"] forKey:@"video_url"];
            [dict setValue:[dictApi objectForKey:@"video_thumb"] forKey:@"video_thumb"];
        }
        else{
            [dict setValue:@"1" forKey:@"have_media"];
            [dict setValue:@"1" forKey:@"type"];
            strImage=[strImage  stringByReplacingOccurrencesOfString:@"http://iblah-blah.com/iblah/images/" withString:@""];
            [dict setValue:strImage forKey:@"image_url"];
        }
    }
    
    
    
   
    
    [dict setValue:strFriendId forKey:@"friendship_ID"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:nil];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    
    //"yyyy-MM-dd HH:mm:ss"
    //mSocket.emit("sendMessageRoom", friend_id, messageObject.toString(), friendshipID);
    
    [appDelegate().socket emit:@"sendMessageRoom" with:@[struser_id,str,strFriendId]];
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _forwardView.alpha = 0;
                     }completion:^(BOOL finished){
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         _forwardView.alpha = 1.0f;
                         // [self bringFront];
                         [_forwardView removeFromSuperview];
                     }];
}

-(void)setAudio{
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (IBAction)playTapped:(id)sender {
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [recorder stop];
    [_playButton setEnabled:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    if (!recorder.recording){
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (IBAction)stopTapped:(id)sender {
    
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    if (!recorder.recording){

        NSData *theData = [[NSData alloc] initWithContentsOfURL:recorder.url];
        [self uploadAudio:theData];
        
        
        [UIView animateWithDuration:1.0f
                              delay:0.0
                            options: UIViewAnimationOptionTransitionCrossDissolve
                         animations:^{
                             _recordView.alpha = 0;
                         }completion:^(BOOL finished){
                             [self.navigationController setNavigationBarHidden:NO animated:YES];
                             _recordView.alpha = 1.0f;
                             // [self bringFront];
                             [_recordView removeFromSuperview];
                             _lblRecordTime.text=@"";
                             [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
                             [recorder stop];
                             [_playButton setEnabled:YES];
                             AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                             [audioSession setActive:NO error:nil];
                         }];
        
    }
  
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
       
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_recordPauseButton setTitle:@"Recording..." forState:UIControlStateNormal];
        [self showLengthOfAudio:@"0"];
        
    } else {
        
        // Pause recording
        //[recorder pause];
        [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [_stopButton setEnabled:YES];
    [_playButton setEnabled:YES];
}

-(void)showLengthOfAudio:(NSString *)time{
     if (recorder.recording) {
         _lblRecordTime.text=[NSString stringWithFormat:@"%@ Sec",time];
         int timeIncrease= [time intValue];
         timeIncrease++;
         [self performSelector:@selector(showLengthOfAudio:) withObject:[NSString stringWithFormat:@"%d",timeIncrease] afterDelay:1.0];
     }
}
- (IBAction)cmdRemoveAudio:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _recordView.alpha = 0;
                     }completion:^(BOOL finished){
                         [self.navigationController setNavigationBarHidden:NO animated:YES];
                         _recordView.alpha = 1.0f;
                         // [self bringFront];
                         [_recordView removeFromSuperview];
                         _lblRecordTime.text=@"";
                         [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
                         [recorder stop];
                         [_playButton setEnabled:YES];
                         AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                         [audioSession setActive:NO error:nil];
                     }];
}
- (IBAction)cmdReset:(id)sender {

    _lblRecordTime.text=@"";
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [recorder stop];
    [_playButton setEnabled:YES];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}


#pragma mark - Actions

- (IBAction)cmdRemovePlayAudio:(id)sender {
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _playAudioView.alpha = 0;
                     }completion:^(BOOL finished){
                         _playAudioView.alpha = 1.0f;
                         [_playAudioView removeFromSuperview];
                         
                     }];
}

- (IBAction)play:(id)sender {
    [self.player1 play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
}

- (IBAction)pause:(id)sender {

    [self.player1 pause];
    [self stopTimer];
    [self updateDisplay];
}

- (IBAction)stop:(id)sender {

    [self.player1 stop];
    [self stopTimer];
    self.player1.currentTime = 0;
    [self.player1 prepareToPlay];
    [self updateDisplay];
}

- (IBAction)currentTimeSliderValueChanged:(id)sender
{
    if(self.timer)
        [self stopTimer];
    [self updateSliderLabels];
}

- (IBAction)currentTimeSliderTouchUpInside:(id)sender
{
    [self.player1 stop];
    self.player1.currentTime = self.currentTimeSlider.value;
    [self.player1 prepareToPlay];
    [self play:self];
}

#pragma mark - Display Update
- (void)updateDisplay
{
    NSTimeInterval currentTime = self.player1.currentTime;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.currentTimeSlider.value = currentTime;
    [self updateSliderLabels];
    
}

- (void)updateSliderLabels
{
    NSTimeInterval currentTime = self.currentTimeSlider.value;
    NSString* currentTimeString = [NSString stringWithFormat:@"%.02f", currentTime];
    
    self.elapsedTimeLabel.text =  currentTimeString;
    self.remainingTimeLabel.text = [NSString stringWithFormat:@"%.02f", self.player1.duration - currentTime];
}

#pragma mark - Timer
- (void)timerFired:(NSTimer*)timer
{
    [self updateDisplay];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
    [self updateDisplay];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"%s successfully=%@", __PRETTY_FUNCTION__, flag ? @"YES"  : @"NO");
    [self stopTimer];
    [self updateDisplay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s error=%@", __PRETTY_FUNCTION__, error);
    [self stopTimer];
    [self updateDisplay];
}
-(void)uploadAudio:(NSData *)thumbImage{
    checkAudio=YES;
    [self.view addSubview:indd];
    [arryChunkData removeAllObjects];
    arryChunkData=nil;
    arryChunkData=[[NSMutableArray alloc]init];
    
    NSData* myBlob=thumbImage;
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
        
        [arryChunkData addObject:base64String];
        // do something with chunk
    } while (offset < length);
    
    if(arryChunkData.count>0){//872360
        
        dictJson=nil;
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid=[NSString stringWithFormat:@"%@.caf",uuid];
        
        NSString *StrSize=[NSString stringWithFormat:@"%ld",myBlob.length];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
        
        dictJson=[[NSMutableDictionary alloc]init];
        [dictJson setValue:uuid forKey:@"Name"];
        [dictJson setValue:StrSize forKey:@"Size"];
        [dictJson setValue:@"true" forKey:@"IsAudio"];
        [dictJson setValue:USERID forKey:@"from_id"];
        [dictJson setValue:@"false" forKey:@"IsVideo"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictJson
                                                           options:0
                                                             error:nil];
        NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
        
        [appDelegate().socket emit:@"uploadFileStartIOS" with:@[str]];
        [self uploadImageVideo];
    }
    
}


@end

    //
    //  HomeViewController.m
    //  iBlah-Blah
    //
    //  Created by Arun on 20/03/18.
    //  Copyright © 2018 webHax. All rights reserved.
    //

#import "HomeViewController.h"
#import "AddPostViewController.h"
#import "CommentViewController.h"
#import "CurrentLocationViewController.h"
#import "EditPostViewController.h"
#import "AllImagesViewController.h"
#import "ProileViewController.h"
#import "RecentChatListViewController.h"
#import "NotificationViewController.h"
#import "QBLoadingButton.h"
#import "UsersViewController.h"
#import "QBCore.h"
#import "SearchPostViewController.h"
#import "PreviewOfPicViewController.h"

#import "HomeFeedTableViewCell.h"
#import "FeedImagesCollectionViewCell.h"
#import "OCTGalleryLayout_v2.h"
#import "WebViewViewController.h"
#import "FriendRequestViewController.h"

@import SocketIO;
@interface HomeViewController ()<UIViewControllerPreviewingDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QBCoreDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, TTTAttributedLabelDelegate>{
    NSMutableArray *arryAllPost;
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;
    UIImage *chosenImage;
    IndecatorView *ind;
    UIButton *btnMessage;
    UIButton *btnNotification;
}
@property (nonatomic)float previousScrollOffset;
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@property (strong, nonatomic) NSArray *imgURLs;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    currentAllPostPage=@"0";


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UpdatePost"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getAllPost"
                                               object:nil];//
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"LikeClicked"
                                               object:nil];//LikeClicked
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getCommentCount"
                                               object:nil];//LikeClicked
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getNotificationCount"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"ShareImages"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UPDATEAPP"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"ShowRequest"
                                               object:nil];
    self.noMoreResultsAvailAllPost =NO;
    [self setNavigationBar];

    ind=[[IndecatorView alloc]init];
    
    
    NSArray *savedValue = [[NSUserDefaults standardUserDefaults]
                           objectForKey:@"ALLPOSTDATA"];
    
    if(savedValue){
        arryAllPost=[savedValue mutableCopy];
        [_tblAllPost reloadData];
    }else{
        [SVProgressHUD showWithStatus:@"Please wait"];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"Socket connected");
        [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];
        [appDelegate().socket emit:@"getAllNotificationsCount" with:@[USERID]];
        [appDelegate().socket emit:@"getCurrentVersion" with:@[USERID]];

    }];
    [appDelegate().socket connect];

    [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];
    
    //emit("getAllNotificationsCount", user_id)

    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    
//    NSString *username = [prefs stringForKey:@"username"];
//    NSString *Email = [prefs stringForKey:@"Email"];
//    QBUUser *newUser = [QBUUser user];
//    
//   
//    newUser.fullName = username;
//    newUser.email = Email;
//    newUser.tags=@[@"iblahBlah"].mutableCopy;
//    newUser.password = @"x6Bt0VDy5";
//    [Core loginWithCurrentUser:newUser];
    
    //
   // 
        // Do any additional setup after loading the view from its nib.
}

-(void)hideIndecatorView{
     [ind removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllNotificationsCount" with:@[USERID]];
     NSLog(@"Status one two %ld",(long)appDelegate().socket.status);
   
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"ShareExtensionValue"];
    if(appDelegate().socket.status==3){
        if([savedValue isEqualToString:@"Start"]){
            NSString *valueToSave = @"Stop";
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"ShareExtensionValue"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
            NSMutableArray *tempArry =[[myDefaults objectForKey:@"ShareMSG"] mutableCopy];
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
    }
    
   //  [socket emit:@"getAllPost" with:@[@"123456" ,@"", @"0"]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
- (void)receivedNotification:(NSNotification *) notification {
    [SVProgressHUD dismiss];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if ([[notification name] isEqualToString:@"UpdatePost"]) {
         currentAllPostPage=@"0";
         [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];
    }else if ([[notification name] isEqualToString:@"getAllPost"]){
         NSDictionary* userInfo = notification.userInfo;
//        [ind removeFromSuperview];
//        if([currentAllPostPage isEqualToString:@"0"]){

            NSArray *Arr=[userInfo objectForKey:@"DATA"];
            
            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];

            //NSDictionary *dict=json;
        NSInteger lastcount = arryAllPost.count -1;

            if(arryAllPost == nil || [currentAllPostPage isEqualToString:@"0"])
            {
                arryAllPost = [[NSMutableArray alloc] init];
                lastcount = 0;
            }
            [arryAllPost addObjectsFromArray:json];
//            arryAllPost=[json mutableCopy];//[[dict objectForKey:@"posts"] mutableCopy];
            [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"ALLPOSTDATA"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if(Arr.count>=2){
                 totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }

        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:lastcount inSection:0];
//        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lastcount inSection:0];

//        [_tblAllPost ]
//        if(lastcount == 0)
dispatch_async(dispatch_get_main_queue(), ^() {
        [_tblAllPost reloadData];
    if(arryAllPost.count > 0)
    [_tblAllPost scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    [_tblAllPost setContentOffset:CGPointZero animated:YES];
});

//        else
//        [_tblAllPost beginUpdates];
//        [_tblAllPost insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                        [_tblAllPost endUpdates];


//        [_tblAllPost insertRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];


//            [_tblAllPost reloadData];

        self.loadingAllPost=NO;
        /*}else{
            self.loadingAllPost=NO;

            NSArray *Arr=[userInfo objectForKey:@"DATA"];
        //    NSDictionary *dict=[Arr objectAtIndex:1];

            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
            
            int countAllPost=[totalAllPostPage intValue];
            int currentPageAll=[currentAllPostPage intValue];
            if(currentPageAll<countAllPost-1){
                
//                NSUInteger rowCount = [_tblAllPost numberOfRowsInSection:0];
//                NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                for (int i=0; i<json.count; i++) {
                    // NSString *s = [[NSString alloc] initWithFormat:@"%d",i];
                    [arryAllPost addObject:[json objectAtIndex:i]];
                    // The new index path is the original number of rows plus i - 1 to leave the last row where it is.
//                    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i+rowCount - 1 inSection:0];
//                    [indexPaths addObject:indexpath];
                }
                
//                [_tblAllPost beginUpdates];
//                [_tblAllPost insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                [_tblAllPost endUpdates];

                [_tblAllPost reloadData];

//                [arryAllPost addObjectsFromArray:[json mutableCopy]];
//                [_tblAllPost reloadData];
            }else{
                if(currentPageAll==0){
                    arryAllPost=[json mutableCopy];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"ALLPOSTDATA"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }else{
//                    NSUInteger rowCount = [_tblAllPost numberOfRowsInSection:0];
//                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    for (int i=0; i<json.count; i++) {
                       // NSString *s = [[NSString alloc] initWithFormat:@"%d",i];
                        [arryAllPost addObject:[json objectAtIndex:i]];
                        // The new index path is the original number of rows plus i - 1 to leave the last row where it is.
//                        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i+rowCount - 1 inSection:0];
//                        [indexPaths addObject:indexpath];
                    }
                    
//                    [_tblAllPost beginUpdates];
//                    [_tblAllPost insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                    [_tblAllPost endUpdates];

                    [_tblAllPost reloadData];
                   // [arryAllPost addObjectsFromArray:[json mutableCopy]];
                }
            }
            if(Arr.count>=2){
                totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            
          
           
        }*/
    }else if([[notification name] isEqualToString:@"LikeClicked"]){//getCommentCount
         NSDictionary* userInfo = notification.userInfo;
         [self likeUpdate:userInfo];
    }else if([[notification name] isEqualToString:@"getCommentCount"]){//getNotificationCount
        NSDictionary* userInfo = notification.userInfo;
        [self commentCountUpdate:userInfo];
    }else if([[notification name] isEqualToString:@"getNotificationCount"]){//
        NSDictionary* userInfo = notification.userInfo;
         NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSArray *notificationCount=[Arr objectAtIndex:1];
        NSDictionary *DictNotiCount=[notificationCount objectAtIndex:0];
        
        NSString *strCountNoti=[NSString stringWithFormat:@"%@",[DictNotiCount objectForKey:@"count"]];
        if([strCountNoti isEqualToString:@"0"]){
            btnNotification.badgeValue=@"";
            btnNotification.badgeBGColor=[UIColor clearColor];
        }else{
            btnNotification.badgeValue=[NSString stringWithFormat:@"%@",[DictNotiCount objectForKey:@"count"]];
            btnNotification.badgeBGColor=[UIColor redColor];
        }
       
        
        NSArray *msgCount=[Arr objectAtIndex:2];
        NSDictionary *DictMsg=[msgCount objectAtIndex:0];
        NSString *strCountMsg=[NSString stringWithFormat:@"%@",[DictMsg objectForKey:@"msgCount"]];
        int totalCount=[strCountNoti intValue]+[strCountMsg intValue];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalCount];
        if([strCountMsg isEqualToString:@"0"]){
            btnMessage.badgeValue=@"";
            btnMessage.badgeBGColor=[UIColor clearColor];
        }else{
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *USERID = [prefs stringForKey:@"USERID"];
            [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
            btnMessage.badgeValue=strCountMsg;
            btnMessage.badgeBGColor=[UIColor redColor];
        }
        // [self commentCountUpdate:userInfo];
    }else if([[notification name] isEqualToString:@"UPDATEAPP"]){
        
          NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        //    NSDictionary *dict=[Arr objectAtIndex:1];
        
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        if(json.count>0 && json){
            NSDictionary *dict=[json objectAtIndex:0];
            NSString *strIOS=[dict objectForKey:@"ios"];
            NSString* requiredVersion = strIOS;
            NSString *actualVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

           
            if ([requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedDescending) {
                // actualVersion is lower than the requiredVersion
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update" message:@"A new version of app is available." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Update :)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    // Ok action examplehttps://itunes.apple.com/us/app/iblah-blah/id1192127152?mt=8
                    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1192127152&mt=8&uo=6"]];

                    //NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id1192127152?mt=8";
                   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                    
                }];
                UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"Not Now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                    // Other action
                }];
                [alert addAction:okAction];
                [alert addAction:otherAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
      
    }else if([[notification name] isEqualToString:@"ShowRequest"]){//
        self.sidePanelController.centerPanel = [[UINavigationController alloc]initWithRootViewController:[[FriendRequestViewController alloc]init]];
    }
}

-(void)insertDownloadedActions:(NSMutableArray *)dataToAdd
{
    // don't need this
    //__weak CurrentViewController *weakSelf = self;
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        // build the index paths for insertion
        // since you're adding to the end of datasource, the new rows will start at count
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger currentCount = arryAllPost.count;
        for (int i = 0; i < dataToAdd.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
        }
        
        // do the insertion
        [arryAllPost addObjectsFromArray:dataToAdd];
        
        // tell the table view to update (at all of the inserted index paths)
        [self.tblAllPost beginUpdates];
        [self.tblAllPost insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tblAllPost endUpdates];
    });
}

#pragma mark ------------- Table View Delegate Methods ------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView==self.tblAllPost){
        if(arryAllPost.count>0){
            return arryAllPost.count + 1;
        }else{
            return 0;
        }
    }
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(tableView==self.tblAllPost){
        if(indexPath.row>=arryAllPost.count){
            return 50;
        }
        NSDictionary *dict=[arryAllPost objectAtIndex:indexPath.row];

        const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        float msgHeight = [self getLabelHeight:msg] + 20;
        float profileViewHeight = 80;
        float postImageHeight = 360;
        float commentHeight = 55;

        if(![[dict objectForKey:@"images"] isEqualToString:@""]){
//            const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
//            NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
//            NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

            
            
            return postImageHeight + msgHeight + profileViewHeight + commentHeight;
            
        }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
            
//            const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
//            NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
//            NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
//
             return postImageHeight + msgHeight + profileViewHeight + commentHeight;
        }else if([[dict objectForKey:@"type"] isEqualToString:@"3"]){
            
//            const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
//            NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
//            NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

          return   130 + msgHeight + commentHeight + 100;
        }
        
//        const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
//        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
//        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

        return  profileViewHeight+ commentHeight + msgHeight + 10;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";


    if(indexPath.row>=arryAllPost.count){
        HomeFeedTableViewCell * cell  = nil;


        cell = [tableView dequeueReusableCellWithIdentifier:
                @"activity"];
        if (cell == nil) {
            cell = (HomeFeedTableViewCell *)[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
//        if()
        [cell.activityIndicator startAnimating];
        return cell;

    }

    HomeFeedTableViewCell * cell  = nil;


    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
//        NSArray *nib;
//        nib = [[NSBundle mainBundle] loadNibNamed:@"HomeFeedCustomCell" owner:self options:nil];
//        cell = [nib objectAtIndex:0];

        cell = (HomeFeedTableViewCell *)[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    NSDictionary *dict;

    UITapGestureRecognizer *gestureProfilePic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openProfilePic:)];

    [cell.viewDetailsOfUser addGestureRecognizer:gestureProfilePic];
    cell.viewDetailsOfUser.tag = indexPath.row;

    cell.lblDescription.enabledTextCheckingTypes = NSTextCheckingAllTypes;
    cell.lblDescription.delegate = self;
     if(indexPath.row>=arryAllPost.count){

     }
   /* if(tableView==_tblAllPost){
        
        
        if(indexPath.row>=arryAllPost.count){
            
            
            if (!self.noMoreResultsAvailAllPost && (arryAllPost && arryAllPost.count>0)) {
                cell.textLabel.text=nil;
                
//                spinner.hidden=NO;
//                spinner = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
//                CGFloat width = 25;
//                CGFloat height = 25;
//
//                spinner.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, 12, width, height);
//                [cell.contentView addSubview:spinner];
//
//                if (indexPath.row>=arryAllPost.count) {
//                    [spinner startAnimating];
//                }

            }else{
                [spinner stopAnimating];
                spinner.hidden=YES;
                cell.textLabel.text=nil;
                UILabel* loadingLabel = [[UILabel alloc]init];
                loadingLabel.font=[UIFont boldSystemFontOfSize:14.0f];
                loadingLabel.textAlignment = NSTextAlignmentCenter;
                loadingLabel.textColor = [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0];
                loadingLabel.numberOfLines = 0;
                loadingLabel.text=@"No More data Available";
                loadingLabel.backgroundColor=[UIColor clearColor];
                cell.backgroundColor=[UIColor clearColor];
                loadingLabel.frame=CGRectMake((self.view.frame.size.width)/2-151,20, 302,25);
                [cell addSubview:loadingLabel];
            }
            
            return cell;
        }
        


    }*/
    
dict=[arryAllPost objectAtIndex:indexPath.row];

//    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 20,50,50)];
//    cell.userProfilePic.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//    cell.userProfilePic.showActivityIndicator=YES;
//    cell.userProfilePic.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;


        //  baseUrl + "thumb/" + image_name
    NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image"]];
    [cell.userProfilePic sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];

//    cell.userProfilePic.imageURL=[NSURL URLWithString:strUrl];
    cell.userProfilePic.clipsToBounds=YES;
    [cell.userProfilePic setContentMode:UIViewContentModeScaleAspectFill];
    cell.userProfilePic.layer.cornerRadius=cell.userProfilePic.frame.size.width/2;
    cell.userProfilePic.layer.borderWidth=1;
    cell.userProfilePic.tag=indexPath.row;
    cell.userProfilePic.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;



    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [cell.userProfilePic addGestureRecognizer:tap];
    [cell.userProfilePic setUserInteractionEnabled:YES];
    
//    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 20,SCREEN_SIZE.width-100,20)];
//    [name setFont:[UIFont boldSystemFontOfSize:14]];
//    name.textAlignment=NSTextAlignmentLeft;
//    name.numberOfLines=2;
//    name.textColor=[UIColor blackColor];//userChatName

    NSString *taggedFriends=[dict objectForKey:@"taggedFriends"];
    
    NSArray *tagFrnd=[taggedFriends componentsSeparatedByString:@","];
    if(taggedFriends.length>3){
        [cell.lblName setFont:[UIFont boldSystemFontOfSize:13]];
        if(tagFrnd.count==1){
            cell.lblName.text=[NSString stringWithFormat:@"%@  with %@",[dict objectForKey:@"name"],tagFrnd[0]];
        }else if (tagFrnd.count==2){
            cell.lblName.text=[NSString stringWithFormat:@"%@  with %@ and %@",[dict objectForKey:@"name"],tagFrnd[0],tagFrnd[1]];
        }else{
            int count=tagFrnd.count;
            count=count-1;
            cell.lblName.text=[NSString stringWithFormat:@"%@ with %@ and %d other",[dict objectForKey:@"name"],tagFrnd[0],count];
        }
        
    }else{
        cell.lblName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    }
    
   
//    [cell.contentView addSubview:name];

//    UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
//    [cell.btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
    cell.btnMore.tag=indexPath.row;
    
    if(self.tblAllPost == tableView){
        [cell.btnMore addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
        
    }

    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    NSString *strDatetoShow=[dateFormat stringFromDate:date];
//    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(75, 40,SCREEN_SIZE.width-110,20)];
//    [time setFont:[UIFont systemFontOfSize:12]];
//    time.textAlignment=NSTextAlignmentLeft;
//    time.numberOfLines=2;
//    time.textColor=[UIColor darkGrayColor];
    cell.lblDate.text=strDatetoShow;

    cell.lblCountry.text = [dict objectForKey:@"country"];
//    cell.lblDate.alpha=0.6;
//    [cell.contentView addSubview:time];

        //    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(20, 80,SCREEN_SIZE.width-40,[self getLabelHeight:[dict objectForKey:@"cpPhrase"]])];
        //    [status setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        //    status.textAlignment=NSTextAlignmentLeft;
        //    status.numberOfLines=40;
        //    status.textColor=[UIColor blackColor];
        //    status.text=[dict objectForKey:@"cpPhrase"];
        //    [cell.contentView addSubview:status];
    const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
    NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    cell.lblDescription.text = msg;

//
//    UITextView *status=[[UITextView alloc] initWithFrame:CGRectMake(20, 80,SCREEN_SIZE.width-40,[self getLabelHeight:msg])];
//    [status setFont:[UIFont fontWithName:@"OpenSans" size:14]];
//    status.textColor=[UIColor blackColor];
//    status.text=msg;
//    status.editable=NO;
//    status.backgroundColor=[UIColor clearColor];
//    status.scrollEnabled=NO;
//    status.textContainerInset = UIEdgeInsetsZero;
//    status.dataDetectorTypes=UIDataDetectorTypeAll;
//    [cell.contentView addSubview:status];

//    UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];//[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];

//    cell.btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:msg], 50, 32);
//    [cell.btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
                                                                                  //    countLikes = 4;
                                                                                  //    countcomments = 2;
                                                                                  //view_count

    NSString *strCount = [dict objectForKey:@"countLikes"];

    if([[dict objectForKey:@"countLikes"] intValue] > 99)
    {
        strCount = @"99+ ";
    }
    cell.lblLike.text = [NSString stringWithFormat:@" %@",strCount];
//    [cell.btnLike setTitle:[NSString stringWithFormat:@" %@",strCount] forState:UIControlStateNormal];
//    [cell.contentView addSubview:btnLike];

    if(self.tblAllPost ==tableView){
        [cell.btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];
        
    }
//    btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
//    [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btnLike.layer.cornerRadius=10;//0,160,223
//    btnLike.layer.borderWidth=1;
//    btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;

    
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likestatus"]];
    if([strLikestatus isEqualToString:@"0"]){
//        [cell.btnLike setSelected:false];
        [cell.imgLike setImage:[UIImage imageNamed:@"Like"]];
//         btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }else{
        [cell.imgLike setImage:[UIImage imageNamed:@"likeSelected"]];
//        btnLike.tintColor = [UIColor whiteColor];//
//        [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
 }
    
    cell.btnLike.tag=indexPath.row;
    
    
    
//    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 85+[self getLabelHeight:msg], 50, 32)];
//    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];

    NSString *strCommentCount = [dict objectForKey:@"countcomments"];

    if([strCommentCount intValue] > 99)
    {
        strCommentCount = @"99+ ";
    }
    cell.lblComents.text = [NSString stringWithFormat:@"%@ ",strCommentCount];
//    [cell.btnComents setTitle:[NSString stringWithFormat:@"%@ ",strCommentCount] forState:UIControlStateNormal];


//    [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countcomments"]] forState:UIControlStateNormal];



    if(self.tblAllPost ==tableView){
        [cell.btnComents addTarget:self
                       action:@selector(cmdCommentAllPost:)
             forControlEvents:UIControlEventTouchUpInside];
        
    }
//    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
//    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    btnComment.layer.cornerRadius=10;//0,160,223
//    btnComment.layer.borderWidth=1;
//    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    cell.btnComents.tag=indexPath.row;
    
//    [cell.contentView addSubview:btnComment];

//    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:msg], 50, 32)];
    [cell.btnShared setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    if(self.tblAllPost ==tableView){
        [cell.btnShared addTarget:self
                     action:@selector(cmdShareAllPost:)
           forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    cell.btnShared.tag=indexPath.row;
//    btnShare.layer.cornerRadius=10;//0,160,223
//    btnShare.layer.borderWidth=1;
//    btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
//    [cell.contentView addSubview:btnShare];

//    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 85+[self getLabelHeight:msg], 50, 32)];
//    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];

    if(self.tblAllPost ==tableView){
//        [btnView addTarget:self
//                    action:@selector(cmdShareAllPost:)
//          forControlEvents:UIControlEventTouchUpInside];
    }
    
//    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cell.lblView.text = [NSString stringWithFormat:@"%@ ",[dict objectForKey:@"view_count"]];

//    [cell.btnView setTitle:[NSString stringWithFormat:@"%@ ",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
//    btnView.layer.cornerRadius=10;//0,160,223
//    btnView.layer.borderWidth=1;
//    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    cell.btnView.tag=indexPath.row;
//    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
//    [cell.contentView addSubview:btnView];
//    UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1)];
//    cell.viewImages.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        //sepUpView.alpha=0.4;
//    [cell.contentView addSubview:cell.viewImages];
    cell.imgLinkPreview.hidden = true;
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){
        
//        UIView *viewImage=[[UIView alloc]initWithFrame:CGRectMake(0, [self getLabelHeight:msg]+80,SCREEN_SIZE.width,SCREEN_SIZE.width-40)];

//        UIImageView *bannerPost=[[UIImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:msg]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
//        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//        bannerPost.showActivityIndicator=YES;
//        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image"]];
//        bannerPost.imageURL=[NSURL URLWithString:strUrl];
//        [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
//        cell.imgPost.clipsToBounds=YES;
//        cell.imgPost.layer.cornerRadius=10;
//        //[cell.contentView addSubview:bannerPost];
//        cell.imgPost.userInteractionEnabled=YES;
//        [cell.imgPost sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:[UIImage imageNamed:@"picPlaceHolder"]];



        NSString *strImageList=[dict objectForKey:@"images"];
        NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];

        cell.collectionView.tag = indexPath.row;
        cell.collectionView.delegate = self;
        cell.collectionView.dataSource = self;


        OCTGalleryLayout_v2 * oct = (OCTGalleryLayout_v2 *)cell.collectionView.collectionViewLayout;
        oct.imgArray = arryImageList;
        oct.height = 360;
        if(arryImageList.count == 1)
            oct.totalColumns = 1;
        else
        {
            oct.totalColumns = 2;
        }

        if(arryImageList.count >3 )
            oct.kNumberOfSideItems = 3;
        else
        {
            oct.kNumberOfSideItems = arryImageList.count-1;
        }

        [cell.collectionView reloadData];

        cell.collectionView.hidden = false;
        cell.imgPost.hidden = true;
        cell.lblDomain.text = @"";
        cell.lblPreview.text = @"";
//        cell.viewImages =  [self addImageView:arryImageList view:cell.viewImages tagValue:indexPath.row];
//        cell.viewImages.tag=indexPath.row;
//        [cell.contentView addSubview:viewImage];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
//        [viewImage addGestureRecognizer:tap];
//        [viewImage setUserInteractionEnabled:YES];
        
//        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//       sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);

    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        
//        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:msg]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
//        cell.imgPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//        cell.imgPost.showActivityIndicator=YES;
//        cell.imgPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        cell.imgPost.hidden = false;
        cell.collectionView.hidden = true;
        NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dict objectForKey:@"lat"],[dict objectForKey:@"lon"],[dict objectForKey:@"lat"],[dict objectForKey:@"lon"]];


        [cell.imgPost sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];

        [cell.imgPost setContentMode:UIViewContentModeScaleAspectFill];
        cell.imgPost.clipsToBounds=YES;
        cell.imgPost.layer.cornerRadius=10;
//        [cell.contentView addSubview:bannerPost];
        cell.imgPost.userInteractionEnabled=YES;
//        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
//        sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);
    }else if([[dict objectForKey:@"type"] isEqualToString:@"3"]){
         NSString *link=[NSString stringWithFormat:@"%@",[dict objectForKey:@"link"]];
         link=[link stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

//        [cell.urlPreivewView loadURL]


        [MTDURLPreview loadPreviewWithURL:[NSURL URLWithString:link] completion:^(MTDURLPreview *preview, NSError *error) {
            //preview.imageURL
            NSLog(@"Image Url %@",preview.imageURL);
            NSLog(@"Image Url %@",preview.title);
            NSLog(@"Image Url %@",preview.domain);
            NSLog(@"Image Url %@",preview.content);
            
            cell.imgPost.hidden = true;
            cell.collectionView.hidden = true;
            cell.imgLinkPreview.hidden = false;
//            UIView *subView=[[UIView alloc]initWithFrame:CGRectMake(10, [self getLabelHeight:msg]+80, SCREEN_SIZE.width-20, 80)];
            [cell.viewImages.layer setShadowColor:[UIColor blackColor].CGColor];
            [cell.viewImages.layer setShadowOpacity:0.3];
            [cell.viewImages.layer setShadowRadius:3.0];
            [cell.viewImages.layer setShadowOffset:CGSizeMake(1, 1)];
            cell.viewImages.backgroundColor=[UIColor whiteColor];
            
//            AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 15,50,50)];
//            cell.imgPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//            cell.imgPost.showActivityIndicator=YES;
//            cell.imgPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//            cell.imgPost.imageURL=preview.imageURL;
            [cell.imgLinkPreview sd_setImageWithURL:preview.imageURL placeholderImage:nil];

            [cell.imgLinkPreview setContentMode:UIViewContentModeScaleAspectFill];
            cell.imgLinkPreview.clipsToBounds=YES;
            cell.imgLinkPreview.layer.cornerRadius=0;

//            [subView addSubview:bannerPost];

//            UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(75, 10,cell.collectionView.frame.size.width-80,40)];
//            [lblDescription setFont:[UIFont boldSystemFontOfSize:12]];
//            lblDescription.textAlignment=NSTextAlignmentLeft;
//            lblDescription.numberOfLines=5;
//            lblDescription.lineBreakMode=NSLineBreakByWordWrapping;
//            lblDescription.textColor=[UIColor blackColor];
            cell.lblPreview.text=[NSString stringWithFormat:@"%@:%@",preview.title,preview.content];
//            [cell.viewImages addSubview:lblDescription];

//            UILabel *lblDomein = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(lblDescription.frame),cell.collectionView.frame.size.width-80,20)];
//            [lblDomein setFont:[UIFont boldSystemFontOfSize:12]];
//            lblDomein.textAlignment=NSTextAlignmentLeft;
//            lblDomein.numberOfLines=5;
//            lblDomein.lineBreakMode=NSLineBreakByWordWrapping;
//            cell.lblDomain.textColor=[UIColor blackColor];
            cell.lblDomain.text=[NSString stringWithFormat:@"%@",preview.domain];
//            [cell.viewImages addSubview:lblDomein];

//            [cell.contentView addSubview:subView];
//            btnLike.frame=CGRectMake(SCREEN_SIZE.width-58,  CGRectGetMaxY(subView.frame)+5, 50, 32);
//            btnComment.frame=CGRectMake(SCREEN_SIZE.width-116,  CGRectGetMaxY(subView.frame)+5, 50, 32);
//            btnShare.frame=CGRectMake(20,  CGRectGetMaxY(subView.frame)+5, 50, 32);
//            btnView.frame=CGRectMake(SCREEN_SIZE.width-174, CGRectGetMaxY(subView.frame)+5, 50, 32);

//            sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);
        }];
    }
    else
    {
        cell.collectionView.hidden = true;
        cell.imgPost.hidden = true;
        cell.lblDomain.text = @"";
        cell.lblPreview.text = @"";

    }
    

    cell.viewActions.layer.borderColor = [UIColor colorWithRed:234/255.0 green:209/255.0 blue:241/255.0 alpha:1].CGColor;
    cell.viewActions.layer.cornerRadius = cell.viewActions.frame.size.height/2;
    cell.viewActions.layer.borderWidth = 1;
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hedderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 50)];
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnEdit addTarget:self
                action:@selector(cmdEdit:)
      forControlEvents:UIControlEventTouchUpInside];//camera editPost
    [btnEdit setImage:[UIImage imageNamed:@"editPost"] forState:UIControlStateNormal];
    btnEdit.frame = CGRectMake((SCREEN_SIZE.width/3)/2-20, 5, 40, 40);
    btnEdit.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [hedderView addSubview:btnEdit];
    btnEdit.layer.cornerRadius=20;
    UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnCamera addTarget:self
                  action:@selector(cmdCamera:)
        forControlEvents:UIControlEventTouchUpInside];
     btnCamera.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    btnCamera.frame = CGRectMake(SCREEN_SIZE.width/3+(SCREEN_SIZE.width/3)/2-20, 5, 40, 40);
    [hedderView addSubview:btnCamera];


    UIImageView *profilePic = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_SIZE.width/3)*2+(SCREEN_SIZE.width/3)/2-20, 5, 40, 40)];

//    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeSystem];
//    [btnLocation addTarget:self
//                    action:@selector(cmdLocation:)
//          forControlEvents:UIControlEventTouchUpInside];
//
//    btnLocation.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];


    profilePic.layer.masksToBounds = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    profilePic.userInteractionEnabled = true;
    [profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%simages/%@",BASEURl,[defaults valueForKey:@"profile_pic"]]] placeholderImage:nil];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openOwnerProfilePic:)];
    [profilePic addGestureRecognizer:gesture];

//completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//        btnLocation.layer.masksToBounds = YES;
//        [btnLocation setBackgroundImage:image forState:normal];
//    }];

//    [btnLocation setImage:[UIImage imageNamed:@"SendLocation"] forState:UIControlStateNormal];
//    btnLocation.frame = CGRectMake((SCREEN_SIZE.width/3)*2+(SCREEN_SIZE.width/3)/2-20, 5, 40, 40);
    [hedderView addSubview:profilePic];
     btnCamera.layer.cornerRadius=20;
     profilePic.layer.cornerRadius=20;
    profilePic.layer.borderWidth=1;
    profilePic.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnCamera.layer.borderWidth=1;
    btnCamera.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnEdit.layer.borderWidth=1;
    btnEdit.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    hedderView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    return hedderView;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
-(void)cmdCamera:(id)sender{
    
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
     imagePickerController.navigationBar.tintColor = [UIColor blackColor];

    [self presentViewController:imagePickerController animated:YES completion:^{}];
}
-(void)cmdEdit:(id)sender{
    AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
    
}
-(void)cmdLocation:(id)sender{
    CurrentLocationViewController *R2VC = [[CurrentLocationViewController alloc]initWithNibName:@"CurrentLocationViewController" bundle:nil];
    R2VC.strFromHome=@"1";
    [self.navigationController pushViewController:R2VC animated:YES];
}

#pragma mark ---------- imagePickerController delegate ------------

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenImage = info[UIImagePickerControllerOriginalImage];
    [self performSelector:@selector(addPost) withObject:nil afterDelay:1.5];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)addPost{
    AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
    R2VC.postImage=chosenImage;
    [self.navigationController pushViewController:R2VC animated:YES];
}
#pragma mark ---------- ScrollView delegate --------------

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView = self.tblAllPost;
    self.previousScrollOffset = self.tblAllPost.contentOffset.y;

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

//    if (!self.loadingAllPost) {
//        float scrollDiff = scrollView.contentOffset.y;
//        if (scrollDiff >= scrollView.contentSize.height - self.view.frame.size.height * 2)
//        {
//            self.loadingAllPost=YES;
//            int countAllPost=[totalAllPostPage intValue];
//            int currentPageAll=[currentAllPostPage intValue];
//            if(currentPageAll<countAllPost-1){
//                currentPageAll++;
//                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                NSString *USERID = [prefs stringForKey:@"USERID"];
//                currentAllPostPage=[NSString stringWithFormat:@"%d",currentPageAll];
//                [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];
//
//            }else{
//                self.loadingAllPost=NO;
//                self.noMoreResultsAvailAllPost=YES;
//                [self.tblAllPost reloadData];
//                //  [self.tblFrnd reloadData];
//            }
//        }
//    }
//    float scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset;
//    float isScrollingDown = scrollDiff > 0;
//    float isScrollingUp = scrollDiff < 0;
//    self.previousScrollOffset = scrollView.contentOffset.y;


    CGFloat scrollPos = self.tblAllPost.contentOffset.y ;

//     CGFloat sectionHeaderHeight = 70;
    if(scrollPos >= self.previousScrollOffset ){
        //Fully hide your toolbar
        [UIView animateWithDuration:2.25 animations:^{
            [self.navigationController setNavigationBarHidden:YES animated:YES];
//            if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//            }

        }];
    } else {
        //Slide it up incrementally, etc.
        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        }

    }





//    if(isScrollingDown == 0){
//        //Fully hide your toolbar
//        [UIView animateWithDuration:2.25 animations:^{
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//
//        }];
//    } else {
//        //Slide it up incrementally, etc.
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//    }


}

-(void)getMorePost
{

    if (!self.loadingAllPost) {

            self.loadingAllPost=YES;
            int countAllPost=[totalAllPostPage intValue];
            int currentPageAll=[currentAllPostPage intValue];
            if(currentPageAll<countAllPost-1){
                currentPageAll++;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *USERID = [prefs stringForKey:@"USERID"];
                currentAllPostPage=[NSString stringWithFormat:@"%d",currentPageAll];
                [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];

            }else{
                self.loadingAllPost=NO;
                self.noMoreResultsAvailAllPost=YES;
                [self.tblAllPost reloadData];
                //  [self.tblFrnd reloadData];
            }
    }
}

//
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.loadingAllPost) {
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            self.loadingAllPost=YES;
            int countAllPost=[totalAllPostPage intValue];
            int currentPageAll=[currentAllPostPage intValue];
            if(currentPageAll<countAllPost-1){
                currentPageAll++;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *USERID = [prefs stringForKey:@"USERID"];
                currentAllPostPage=[NSString stringWithFormat:@"%d",currentPageAll];
                [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];

            }else{
                self.loadingAllPost=NO;
                self.noMoreResultsAvailAllPost=YES;
                [self.tblAllPost reloadData];
                    //  [self.tblFrnd reloadData];
            }
        }
    }
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
        // [self sendNewIndex:scrollView];
}
#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(SCREEN_SIZE.width-40, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
-(void)setNavigationBar{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            //        statusBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gradient_large"]];
        statusBar.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont systemFontOfSize:17.0f],
      NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    //self.title=@"Home";
    self.navigationController.navigationBarHidden=NO;

    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    btnMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnMessage setImage:[UIImage imageNamed:@"unnamed"] forState:UIControlStateNormal];
   // [btnClear setTitle:@"Chat" forState:UIControlStateNormal];
    //[btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnMessage.frame = CGRectMake(0, 0, 32, 32);
   // btnMessage.badgeValue =@"1";
  //  btnMessage.badgeBGColor=[UIColor redColor];
    [btnMessage addTarget:self action:@selector(cmdChat:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnMessage];
    
    [arrRightBarItems addObject:btnSearchBar];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch setImage:[UIImage imageNamed:@"magnifying-glass"] forState:UIControlStateNormal];
    btnSearch.frame = CGRectMake(0, 0, 32, 32);
    [btnSearch addTarget:self action:@selector(cmdSearch:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBarq = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    [arrRightBarItems addObject:btnSearchBarq];
    
    //

    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
    
    
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    buttonContainer.backgroundColor = [UIColor clearColor];
    btnNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNotification setFrame:CGRectMake(100-16, 8, 32, 32)];
   
    [btnNotification setBackgroundImage:[UIImage imageNamed:@"earth"] forState:UIControlStateNormal];
    [btnNotification addTarget:self action:@selector(cmdNotification:) forControlEvents:UIControlEventTouchUpInside];
    [btnNotification setShowsTouchWhenHighlighted:YES];
    [buttonContainer addSubview:btnNotification];


    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnLocation addTarget:self
                    action:@selector(cmdLocation:)
          forControlEvents:UIControlEventTouchUpInside];
    btnLocation.tintColor = [UIColor colorWithRed:254/255.0 green:254/255.0 blue:254/255.0 alpha:1.0];


//    [imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%simages/%@",BASEURl,[defaults valueForKey:@"profile_pic"]]] placeholderImage:[UIImage imageNamed:@"SendLocation"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//        btnLocation.layer.masksToBounds = YES;
//        [btnLocation setBackgroundImage:image forState:normal];
//    }];

    [btnLocation setImage:[UIImage imageNamed:@"SendLocation"] forState:UIControlStateNormal];
    btnLocation.frame = CGRectMake(btnNotification.frame.size.width + btnNotification.frame.origin.x + 10, 8, 32, 32);
    [buttonContainer addSubview:btnLocation];


        //add your spacer images and button1 and button2...
    
    self.navigationItem.titleView = buttonContainer;
    
}
-(void)cmdChat:(id)sender{
    RecentChatListViewController *R2VC = [[RecentChatListViewController alloc]initWithNibName:@"RecentChatListViewController" bundle:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
}//

-(void)cmdNotification:(id)sender{
     NotificationViewController *notification = [[NotificationViewController alloc]initWithNibName:@"NotificationViewController" bundle:nil];
    [self.navigationController pushViewController:notification animated:YES];
    
}

- (void)smallButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
    
    ProileViewController*cont=[[ProileViewController alloc]initWithNibName:@"ProileViewController" bundle:nil];
    cont.dictData=[arryAllPost objectAtIndex:img.tag];
    [self.navigationController pushViewController:cont animated:YES];
    
//    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
//
//    imageInfo.image = img.image;
//    imageInfo.referenceRect = img.frame;
//    imageInfo.referenceView = img.superview;
//    imageInfo.referenceContentMode = img.contentMode;
//    imageInfo.referenceCornerRadius = img.layer.cornerRadius;
//
//        // Setup view controller
//    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
//                                           initWithImageInfo:imageInfo
//                                           mode:JTSImageViewControllerMode_Image
//                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
//
//        // Present the view controller.
//    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}
-(void)cmdMoreALL:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary  *dict=[arryAllPost objectAtIndex:btn.tag];
    NSString *PostUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([PostUserId isEqualToString:USERID]){
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Delete Post"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];
                                  // mSocket.emit("delete_post", post_id);
                                      // mSocket.emit("showAllVideos",UserID);
                                       [appDelegate().socket emit:@"delete_post" with:@[strPost_id]];
                                   [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"UpdatePost"
                                    object:self userInfo:nil];
                               }];
        if([[dict objectForKey:@"type"] isEqualToString:@"0"]){
        
        UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Edit Post"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                       EditPostViewController *R2VC = [[EditPostViewController alloc]initWithNibName:@"EditPostViewController" bundle:nil];
                                       R2VC.dictPost=dict;
                                       [self.navigationController pushViewController:R2VC animated:YES];
                                       
                                           // mSocket.emit("showAllVideos",UserID);
                                           //  [appDelegate().socket emit:@"showAllVideos" with:@[@"5d12dbf3-82f2-45b9-8fde-3ef69a187092"];
                                       
                                       
                                   }];
             [alert addAction:btnEdit];
        }
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                                 
                                 
                             }];
        
   
    [alert addAction:btnAbuse];
    [alert addAction:cancel];
        if ( IDIOM == IPAD ) {
            /* do something specifically for iPad. */
            UIButton *btn=(UIButton *)sender;
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            popPresenter.sourceView = btn;
            popPresenter.sourceRect = btn.bounds;
            
        }
    [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Hide Post"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                       
                                       [arryAllPost removeObjectAtIndex:btn.tag];
                                       [self.tblAllPost beginUpdates];
                                       [_tblAllPost deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                       [self.tblAllPost endUpdates];

                                       [appDelegate().socket emit:@"remove_post" with:@[USERID,[dict objectForKey:@"post_id"]]];


                                       //[_tblAllPost reloadData];
                                      // NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];
                                           // mSocket.emit("delete_post", post_id);
                                           // mSocket.emit("showAllVideos",UserID);
                                      
//                                       [[NSNotificationCenter defaultCenter]
//                                        postNotificationName:@"UpdatePost"
//                                        object:self userInfo:nil];
                                   }];
        
            
            UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Report"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          
                                          
                                          
                                      }];
            [alert addAction:btnEdit];
        
        UIAlertAction* btnBlock = [UIAlertAction actionWithTitle:@"Block User"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                  {
                                      NSString *uuid = [[NSUUID UUID] UUIDString];
                                      
                                      [appDelegate().socket emit:@"blockAfriend" with:@[[dict objectForKey:@"user_id"],USERID,uuid]];
                                      
                                      [AlertView showAlertWithMessage:@"User Blocked successfully" view:self];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePost" object:self];
                                  }];
        [alert addAction:btnBlock];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action)
                                 {
                                   
                                     
                                     
                                 }];
        
        
        [alert addAction:btnAbuse];
        [alert addAction:cancel];
        if ( IDIOM == IPAD ) {
            /* do something specifically for iPad. */
            UIButton *btn=(UIButton *)sender;
            [alert setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alert
                                                             popoverPresentationController];
            popPresenter.sourceView = btn;
            popPresenter.sourceRect = btn.bounds;
            
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)cmdShareAllPost:(id)sender{
    
     UIButton *btn=(UIButton *)sender;
     NSDictionary  *dict=[arryAllPost objectAtIndex:btn.tag];
     NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];
     NSString *strTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
     NSString *strDiscription=[NSString stringWithFormat:@"%@",[dict objectForKey:@"discription"]];
     NSString *strPosttype=[NSString stringWithFormat:@"%@",[dict objectForKey:@"posttype"]];
     NSString *strLat=[NSString stringWithFormat:@"%@",[dict objectForKey:@"lat"]];
     NSString *strLon=[NSString stringWithFormat:@"%@",[dict objectForKey:@"lon"]];
     NSString *strPostimages=[NSString stringWithFormat:@"%@",[dict objectForKey:@"images"]];
     NSString *strType=[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"]];
     NSString *strLocation=[NSString stringWithFormat:@"%@",[dict objectForKey:@"location"]];
//    NSString *strOtheruserID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"location"]];

                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
        //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Share this post on your wall?"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                    //mSocket.emit("sharePost", user_id, post_id, title,  discription,  posttype, lat, lon,"", postimages, "", type, location, other_user_id
                                    [appDelegate().socket emit:@"sharePost" with:@[USERID,strPost_id,strTitle,strDiscription,strPosttype,strLat,strLon,@"",strPostimages,@"",strType,strLocation,@"5d12dbf3-82f2-45b9-8fde-3ef69a187092"]];
                                    currentAllPostPage=@"0";
                                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                    NSString *USERID = [prefs stringForKey:@"USERID"];
                                    [appDelegate().socket emit:@"getAllPost" with:@[USERID,@"",currentAllPostPage]];
                                }];

//    UIAlertAction* btnSharewithFrnd = [UIAlertAction
//                               actionWithTitle:@"Share with Friends"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                       //Handle no, thanks button
//                                   [AlertView showAlertWithMessage:@"Comming soon." view:self];
//                               }];
    
    UIAlertAction* btnSharewithOtherApp = [UIAlertAction
                                       actionWithTitle:@"Share on other app"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                           [self shareWithOtherApp:dict];
//                                           [self performSelector:@selector(shareWithOtherApp:) withObject:dict afterDelay:0];
                                       }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                               }];
    
        //Add your buttons to alert controller
    [alert addAction:yesButton];
   // [alert addAction:btnSharewithFrnd];
    [alert addAction:btnSharewithOtherApp];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)shareWithOtherApp:(NSDictionary *)dict{



    [SupportClass shareWithOtherAppRefrenceClass:self withImagesArray:[[dict objectForKey:@"images"] isEqualToString:@""] ? @[] : [[dict objectForKey:@"images"] componentsSeparatedByString:@","] withTitle:[NSString stringWithFormat:@"%@",[dict objectForKey:@"discription"]] withLat:[dict objectForKey:@"lat"] withLong:[dict objectForKey:@"lon"]];


/*
    NSArray *arraImages = [[dict objectForKey:@"images"] componentsSeparatedByString:@","];


    [SVProgressHUD showWithStatus:@"Please wait"];
     NSString *strTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];

    UIActivityItemProvider *message = [[UIActivityItemProvider alloc] initWithPlaceholderItem:strTitle];

    NSMutableArray *Items = [[NSMutableArray alloc]init];


    int index = 0;
    for(NSString *strTemp in arraImages)
    {
        NSString *strImageUrl = [NSString stringWithFormat:@"%simages/%@",BASEURl,strTemp ];
        NSData *imgShare = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImageUrl]];

        UIImage *img = [UIImage imageWithData:imgShare];

        ImageActivityItemProvider *itemProvider = [[ImageActivityItemProvider alloc] initWithImage:img index:index shouldShowIndex:index];

        [Items addObject:itemProvider];

        index ++;
    }


    [SVProgressHUD dismiss];
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){

        [Items addObject:message];
        [Items addObject:@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8"];
        [Items addObject:@"Via iBlah-Blah"];

//        Items  = [NSArray arrayWithObjects:
//                  message,imgShare,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
//                  @"Via iBlah-Blah", nil];

     
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
         NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dict objectForKey:@"lat"],[dict objectForKey:@"lon"],[dict objectForKey:@"lat"],[dict objectForKey:@"lon"]];
        Items  = [NSMutableArray arrayWithObjects:
                  strTitle,strUrl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                  @"Via iBlah-Blah", nil];
    }
    


    UIActivityViewController *activityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];


    activityView.modalPresentationStyle  = UIModalTransitionStyleCoverVertical;

    if (IDIOM == IPAD)
    {
        NSLog(@"iPad");
        activityView.popoverPresentationController.sourceView = self.view;
        //        activityViewController.popoverPresentationController.sourceRect = self.frame;
        [self presentViewController:activityView
                           animated:YES
                         completion:nil];
    }
    else
    {
        NSLog(@"iPhone");
        [self presentViewController:activityView
                           animated:YES
                         completion:nil];
    } */
}


//- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
//{
//
//}
//
//- (nullable id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(nullable UIActivityType)activityType
//{
//
//}

/*
- (void)bigButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    
    NSLog(@"data : %@", tap.data);

    
    AsyncImageView *view=(AsyncImageView *)tap.view;
    
    NSDictionary  *dict=[arryAllPost objectAtIndex:[tap.tagValue   integerValue]];
    
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
    NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    long count = [strLikeCOunt intValue];
    
    NSMutableDictionary *dictNew=[dict mutableCopy];
    [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"view_count"];
   
    [arryAllPost replaceObjectAtIndex:view.tag withObject:dictNew];
//mSocket.emit("addToView", user_id, image_id, post_id)
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:view.tag inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tblAllPost reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    
    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
    NSMutableArray *arryimglink=[[NSMutableArray  alloc]init];
    for (int i=0; i<arryImageList.count; i++) {
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImageList[i]];
        NSURL *url=[NSURL URLWithString:strUrl];
        [arryimglink addObject:url];
    }
    self.imgURLs=arryimglink;
//    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
//    imageVC.startingIndex = 0;
//    [self presentViewController:imageVC animated:YES completion:nil];
    AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
    R2VC.dictPost=dict;
    R2VC.imgNumber=tap.data;
    [self.navigationController pushViewController:R2VC animated:YES];
}
*/
-(void)cmdLikeAllPost:(id)sender{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllPost objectAtIndex:btn.tag];
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likestatus"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
    NSString *strViewCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    if([strLikestatus isEqualToString:@"0"]){
        
         [appDelegate().socket emit:@"likeApost" with:@[USERID,strPost_id,currentAllPostPage]];
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"countLikes"];
        [dictNew setValue:@"1" forKey:@"likestatus"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [arryAllPost replaceObjectAtIndex:btn.tag withObject:dictNew];
        
        
        
    }else{
         [appDelegate().socket emit:@"unlikeApost" with:@[USERID,strPost_id,currentAllPostPage]];
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"countLikes"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [dictNew setValue:@"0" forKey:@"likestatus"];
        [arryAllPost replaceObjectAtIndex:btn.tag withObject:dictNew];
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tblAllPost reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

}

-(void)cmdCommentAllPost:(id)sender{
    UIButton *btn=(UIButton *)sender;
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    NSDictionary  *dict=[arryAllPost objectAtIndex:btn.tag];
    
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
    NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    long count = [strLikeCOunt intValue];
    
    NSMutableDictionary *dictNew=[dict mutableCopy];
    [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"view_count"];
    
    [arryAllPost replaceObjectAtIndex:btn.tag withObject:dictNew];
        //mSocket.emit("addToView", user_id, image_id, post_id)
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tblAllPost reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    cont.dictPost=dict;
  //  [self.navigationController presentViewController:cont animated:YES completion:nil];
    [self.navigationController pushViewController:cont animated:YES];
}



-(UIView *)addImageView:(NSArray *)arryImage view:(UIView *)view tagValue:(NSInteger *)tagValue{
    
    if(arryImage.count==5 || arryImage.count>5){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        
        MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap.data=@"0";
        tap.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost1 addGestureRecognizer:tap];
        [bannerPost1 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];

        
        
        MYTapGestureRecognizer *tap1 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap1.data=@"1";
        tap1.tagValue=[NSString stringWithFormat:@"%d",tagValue];
        [bannerPost2 addGestureRecognizer:tap1];
        [bannerPost2 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap2.data=@"2";
        tap2.tagValue=[NSString stringWithFormat:@"%d",tagValue];;;
        [bannerPost3 addGestureRecognizer:tap2];

        
        
        if(arryImage.count>5){
            
            int count=arryImage.count-5;
            
            UIView *viewOverLay=[[UIView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3)];
            viewOverLay.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
            UILabel* lblCount = [[UILabel alloc]init];
            lblCount.font=[UIFont boldSystemFontOfSize:34.0];
            lblCount.textAlignment = NSTextAlignmentCenter;
            lblCount.textColor = [UIColor whiteColor];
            lblCount.numberOfLines = 0;
            lblCount.backgroundColor=[UIColor clearColor];
            lblCount.frame=CGRectMake(0, 0, view.frame.size.width/2, view.frame.size.height/3);
            lblCount.text=[NSString stringWithFormat:@"+%d",count];
            [viewOverLay addSubview:lblCount];
            [view addSubview:viewOverLay];
            
            
            MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
            tap2.data=@"2";
            tap2.tagValue=[NSString stringWithFormat:@"%d",tagValue];
            [viewOverLay addGestureRecognizer:tap2];
//            [view setUserInteractionEnabled:YES];

            
        }
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/3, view.frame.size.width/2-1, view.frame.size.height/3-1)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];

        
        MYTapGestureRecognizer *tap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap3.data=@"3";
        tap3.tagValue=[NSString stringWithFormat:@"%d",tagValue];
        [bannerPost4 addGestureRecognizer:tap3];
        [bannerPost4 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost5=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, (view.frame.size.height/3)*2, view.frame.size.width/2, view.frame.size.height/3)];
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost5.showActivityIndicator=YES;
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[4]];
        bannerPost5.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost5 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost5.clipsToBounds=YES;
        [view addSubview:bannerPost5];
        bannerPost5.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap4 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap4.data=@"4";
        tap4.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost5 addGestureRecognizer:tap4];
        [bannerPost5 setUserInteractionEnabled:YES];
        
    }else if(arryImage.count==4){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        
        MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap.data=@"0";
        tap.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost1 addGestureRecognizer:tap];
        [bannerPost1 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2-1, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        MYTapGestureRecognizer *tap1 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap1.data=@"1";
        tap1.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost2 addGestureRecognizer:tap1];
        [bannerPost2 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/2-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap2.data=@"2";
        tap2.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost3 addGestureRecognizer:tap2];
        [bannerPost3 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        
        MYTapGestureRecognizer *tap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap3.data=@"3";
        tap3.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost4 addGestureRecognizer:tap3];
        [bannerPost4 setUserInteractionEnabled:YES];
        
        
    }else if(arryImage.count==3){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, (view.frame.size.width/3)*2, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        MYTapGestureRecognizer *tap1 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap1.data=@"0";
        tap1.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost1 addGestureRecognizer:tap1];
        [bannerPost1 setUserInteractionEnabled:YES];
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, view.frame.size.height/2,(view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap2.data=@"1";
        tap2.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost2 addGestureRecognizer:tap2];
        [bannerPost2 setUserInteractionEnabled:YES];
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, 0, (view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap3.data=@"2";
        tap3.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost3 addGestureRecognizer:tap2];
        [bannerPost3 setUserInteractionEnabled:YES];
        
        
    }else if(arryImage.count==2){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap.data=@"0";
        tap.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost1 addGestureRecognizer:tap];
        [bannerPost1 setUserInteractionEnabled:YES];
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2,0 , view.frame.size.width/2, view.frame.size.height)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap2.data=@"1";
        tap2.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost2 addGestureRecognizer:tap2];
        [bannerPost2 setUserInteractionEnabled:YES];
        
    }else if(arryImage.count==1){
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        tap.data=@"0";
        tap.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
        [bannerPost1 addGestureRecognizer:tap];
        [bannerPost1 setUserInteractionEnabled:YES];
    }
    
    return view;
}



#pragma mark - 3D Touch
- (void)check3DTouch {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
    }
}

#pragma mark like dislike comment update
-(void)likeUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
    NSArray *filtered = [arryAllPost filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(post_id == %@)", [Arr objectAtIndex:1]]];
    if(filtered.count>0){
        NSDictionary *item = [filtered objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryAllPost indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"countLikes"];
            [arryAllPost replaceObjectAtIndex:indexItem withObject:dictNew];
            [_tblAllPost reloadData];
        }
    }
    

}
-(void)commentCountUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
    NSArray *filtered = [arryAllPost filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(post_id == %@)", [Arr objectAtIndex:1]]];
    if(filtered.count>0){
        NSDictionary *item = [filtered objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryAllPost indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"countcomments"];
            [arryAllPost replaceObjectAtIndex:indexItem withObject:dictNew];
            [_tblAllPost reloadData];
        }
    }
}
-(void)cmdSearch:(id)sender{

    SearchPostViewController *R2VC = [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"SearchPostViewController"];
    [self.navigationController pushViewController:R2VC animated:YES];
}



#pragma mark collectionview delegate

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *dict = [arryAllPost objectAtIndex:collectionView.tag];
    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];

    if(arryImageList.count>=5)
        return 5;
    else
        if(arryImageList.count == 3)
            return arryImageList.count;
    return arryImageList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"postImages";
    
    FeedImagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
    //    NSArray *nib;
//        nib = [[NSBundle mainBundle] loadNibNamed:@"HomeFeedCustomCell" owner:self options:nil];
//        cell = [nib objectAtIndex:1];

                cell = (FeedImagesCollectionViewCell *)[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:identifier];

//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }



    NSDictionary *dict = [arryAllPost objectAtIndex:collectionView.tag];
    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];

    NSInteger index = indexPath.row;
//    if(indexPath.row == arryImageList.count )
//    {
//        index = index -1;
//    }

    NSString *imageName = [arryImageList objectAtIndex:index];

    NSString * strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,imageName];

    [cell.postImage sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil options:0];

    if(arryImageList.count > 5 && indexPath.row == 3 )
    {
        cell.view5Plus.hidden = NO;
    }
    else
    {
        cell.view5Plus.hidden = YES;
    }

    return cell;

}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;

//    NSLog(@"data : %@", tap.data);


//    AsyncImageView *view=(AsyncImageView *)tap.view;

    NSDictionary  *dict=[arryAllPost objectAtIndex:collectionView.tag];

    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
    NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    long count = [strLikeCOunt intValue];

    NSMutableDictionary *dictNew=[dict mutableCopy];
    [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"view_count"];

    [arryAllPost replaceObjectAtIndex:collectionView.tag withObject:dictNew];
    //mSocket.emit("addToView", user_id, image_id, post_id)

    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:collectionView.tag inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath1, nil];
    [self.tblAllPost reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];


    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
    NSMutableArray *arryimglink=[[NSMutableArray  alloc]init];
    for (int i=0; i<arryImageList.count; i++) {
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,arryImageList[i]];
        NSURL *url=[NSURL URLWithString:strUrl];
        [arryimglink addObject:url];
    }
    self.imgURLs=arryimglink;
    //    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
    //    imageVC.startingIndex = 0;
    //    [self presentViewController:imageVC animated:YES completion:nil];
    AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
    R2VC.dictPost=dict;
//    R2VC.arryGroupImages = arryImageList;
    R2VC.imgNumber=indexPath.row;

    [self presentViewController:R2VC animated:YES completion:nil];
//    [self.navigationController pushViewController:R2VC animated:YES];
}


#pragma mark
#pragma mark Link click handle

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    WebViewViewController *webview = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewViewController"];
    webview.url = url;
    [self presentViewController:webview animated:YES completion:nil];

}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithAddress:(NSDictionary *)addressComponents
{

}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    NSString *phoneNumber1 = [@"tel://" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber1] options:@{} completionHandler:^(BOOL success) {

    }];

}
- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithTransitInformation:(NSDictionary *)components
{

}


-(void)openProfilePic:(UITapGestureRecognizer *)gesture
{
    NSInteger tag = gesture.view.tag;
    NSDictionary *dic =[arryAllPost objectAtIndex:tag];

    NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dic objectForKey:@"image"]];

    PreviewOfPicViewController *preview = [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"PreviewOfPicViewController"];
    preview.imgArray = @[strUrl];
    [self presentViewController:preview animated:YES completion:nil];
}


-(void)openOwnerProfilePic:(UITapGestureRecognizer *)gesture
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PreviewOfPicViewController *preview = [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"PreviewOfPicViewController"];
    preview.imgArray = @[[NSString stringWithFormat:@"%simages/%@",BASEURl,[defaults valueForKey:@"profile_pic"]]];
    [self presentViewController:preview animated:YES completion:nil];
}



@end


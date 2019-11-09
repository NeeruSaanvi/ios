//
//  RecentChatListViewController.m
//  iBlah-Blah
//
//  Created by webHex on 13/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "RecentChatListViewController.h"
#import "AGChatViewController.h"
@interface RecentChatListViewController ()<UISearchBarDelegate>{
    NSArray *arryChatList;
    IndecatorView *ind;
}

@end

@implementation RecentChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //mSocket.emit("showMyChatList", user_id);
    ind=[[IndecatorView alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GetChatList"
                                               object:nil];
    
     self.title=@"CHAT LIST";
    
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    if([_strFromMarketPlace isEqualToString:@"yes"]){
        // emit("showItemChatList", user_id, post_id)
       
    }else{
        NSArray *savedValue = [[NSUserDefaults standardUserDefaults]
                               objectForKey:@"ChatLISTDATA"];
        
        if(savedValue){
            arryChatList=[savedValue mutableCopy];
            [_chatList reloadData];
        }else{
            [self.view addSubview:ind];
        }
        
        
        
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([_strFromMarketPlace isEqualToString:@"yes"]){
            // emit("showItemChatList", user_id, post_id)
        [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    }else{
        NSArray *savedValue = [[NSUserDefaults standardUserDefaults]
                                objectForKey:@"ChatLISTDATA"];
        
        if(savedValue){
            arryChatList=[savedValue mutableCopy];
            [_chatList reloadData];
        }
        [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
        
        
        
    }
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}//mSocket.emit("showMyChatList", user_id, user_name)
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"GetChatList"]){
         [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        if(![_strFromMarketPlace isEqualToString:@"yes"]){
        [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"CHATLIST"];
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
        [myDefaults setObject:json forKey:@"CHATLIST"];
            
            [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"ChatLISTDATA"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            //NSLog(@"Hello");
        }
        arryChatList=[json mutableCopy];
        
        [_chatList reloadData];
        NSMutableArray *arryTemp=[[NSMutableArray alloc]init];
        for (int i=0; i<arryChatList.count; i++) {
            NSDictionary *dict=[arryChatList objectAtIndex:i];
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
    
    }
//    else if ([[notification name] isEqualToString:@"BlockedUser"]){
//         [ind removeFromSuperview];
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString *USERID = [prefs stringForKey:@"USERID"];
//        if([_strFromMarketPlace isEqualToString:@"yes"]){
//            // emit("showItemChatList", user_id, post_id)
//            
//            [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
//        }else{
//            [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
//        }
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryChatList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict=[arryChatList objectAtIndex:indexPath.row];
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
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 5,self.view.frame.size.width-190,20)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"name"];
    [cell.contentView addSubview:name];
    
    UILabel *groupMemberCount = [[UILabel alloc] initWithFrame:CGRectMake(110, 27,100,32)];
    [groupMemberCount setFont:[UIFont boldSystemFontOfSize:12]];
    groupMemberCount.textAlignment=NSTextAlignmentLeft;
    groupMemberCount.numberOfLines=2;
    groupMemberCount.lineBreakMode=NSLineBreakByWordWrapping;
    groupMemberCount.textColor=[UIColor blackColor];
    NSString *strISMedia=[NSString stringWithFormat:@"%@",[dict objectForKey:@"have_media"]];
    if([strISMedia isEqualToString:@"1"]){
        groupMemberCount.text=[NSString stringWithFormat:@"Image"];
    }else{
        
        const char *jsonString = [[dict objectForKey:@"message"] UTF8String];
        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        groupMemberCount.text=[NSString stringWithFormat:@"%@",msg];
    }
    
    [cell.contentView addSubview:groupMemberCount];
    
    
    AsyncImageView *imgGroup=[[AsyncImageView alloc]initWithFrame:CGRectMake(75, 27,32,32)];
    imgGroup.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strread_status=[NSString stringWithFormat:@"%@",[dict objectForKey:@"read_status"]];
    
    if([strread_status isEqualToString:@"1"]){
        imgGroup.image=[UIImage imageNamed:@"tick_grey"];
    }else if([strread_status isEqualToString:@"3"]){
        imgGroup.image=[UIImage imageNamed:@"tick_pink"];
    }else if([strread_status isEqualToString:@"2"]){
        imgGroup.image=[UIImage imageNamed:@"tick_blue"];
    }
    
    
    
    imgGroup.clipsToBounds=YES;
    [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strFromId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
    if([strFromId isEqualToString:USERID]){
       [cell.contentView addSubview:imgGroup];
    }else{
         groupMemberCount.frame=CGRectMake(75, 27,100,20);
        
    }
    if([groupMemberCount.text isEqualToString:@""]){
        groupMemberCount.text=@"No Conversation";
    }
    UILabel *lblTlblGroupInfo = [[UILabel alloc] initWithFrame:CGRectMake(75, 59,SCREEN_SIZE.width-175,20)];
    [lblTlblGroupInfo setFont:[UIFont systemFontOfSize:11]];
    lblTlblGroupInfo.textAlignment=NSTextAlignmentLeft;
    lblTlblGroupInfo.numberOfLines=2;
    lblTlblGroupInfo.lineBreakMode=NSLineBreakByWordWrapping;
    lblTlblGroupInfo.textColor=[UIColor blackColor];
    
    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"msg_time"]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//EEE MMM dd HH:mm:ss z yyyy
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    NSString *strDatetoShow=[dateFormat stringFromDate:date];
    
    lblTlblGroupInfo.text=strDatetoShow;
    [cell.contentView addSubview:lblTlblGroupInfo];
    
    
    UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
    [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
    btnMore.tag=indexPath.row;
    [btnMore addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnMore];
    
    NSString *StrunreadCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"unreadCount"]];
    
    UILabel *msgCount = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-40, CGRectGetMaxY(btnMore.frame)+5,30,30)];
    [msgCount setFont:[UIFont boldSystemFontOfSize:12]];
    msgCount.textAlignment=NSTextAlignmentCenter;
    msgCount.numberOfLines=2;
    msgCount.lineBreakMode=NSLineBreakByWordWrapping;
    msgCount.textColor=[UIColor whiteColor];
    msgCount.clipsToBounds=YES;
    msgCount.backgroundColor=[UIColor redColor];
    msgCount.layer.cornerRadius=15;
    msgCount.text=StrunreadCount;
    if(![StrunreadCount isEqualToString:@"0"]){
         [cell.contentView addSubview:msgCount];
    }
   
    
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 79, SCREEN_SIZE.width-40, 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict=[arryChatList objectAtIndex:indexPath.row];
//    "block_id" = "";
//    "blocked_user" = "";
   // NSString *strBlockUser=[NSString stringWithFormat:@"%@",[dict objectForKey:@"blocked_user"]];
    //if([strBlockUser isEqualToString:@""]){
    
    
    NSString *strOnline=[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_online"]];
    if([strOnline isEqualToString:@"1"]){
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Online" style:UIBarButtonItemStylePlain target:nil action:nil] ;
    }else{
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Offline" style:UIBarButtonItemStylePlain target:nil action:nil] ;
    }
    
        AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
        R2VC.dictChatData=dict;
        R2VC.reasentChat=arryChatList;
        [self.navigationController pushViewController:R2VC animated:YES];
   // }
    
//    else{
//        NSString *strID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"blocked_user"]];
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString *USERID = [prefs stringForKey:@"USERID"];
//
//        if([strID isEqualToString:USERID]){
//            NSString *strName=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
//            NSString *strMsg=[NSString stringWithFormat:@"%@ blocked you!!",strName];
//            [AlertView  showAlertWithMessage:strMsg view:self];
//        }else{
//             NSString *strName=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
//            NSString *strMsg=[NSString stringWithFormat:@"you blocked %@",strName];
//            [AlertView  showAlertWithMessage:strMsg view:self];
//        }
//
//    }
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
-(void)cmdMoreALL:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary  *dict=[arryChatList objectAtIndex:btn.tag];
    NSString *PostUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    
        
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Delete Conversation"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                       //mSocket.emit("deleteAllMessages", user_id, myfreind_id);

                                       [appDelegate().socket emit:@"deleteAllMessages" with:@[USERID,[dict objectForKey:@"myFriend_id"]]];
                                       
                                       if([_strFromMarketPlace isEqualToString:@"yes"]){
                                           // emit("showItemChatList", user_id, post_id)
                                           [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
                                       }else{
                                           [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
                                       }
                                   }];
    NSString *strBlockUser=[NSString stringWithFormat:@"%@",[dict objectForKey:@"blocked_user"]];
    if([strBlockUser isEqualToString:@""]){

        UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Block"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          NSString *uuid = [[NSUUID UUID] UUIDString];

                                          
                                          [appDelegate().socket emit:@"blockAfriend" with:@[[dict objectForKey:@"user_id"],USERID,uuid]];

                                          [AlertView showAlertWithMessage:@"User Blocked successfully" view:self];
                                          if([_strFromMarketPlace isEqualToString:@"yes"]){
                                              // emit("showItemChatList", user_id, post_id)
                                              [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
                                          }else{
                                              [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
                                          }
                                      }];
            [alert addAction:btnEdit];
    }else{
        NSString *strID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"blocked_user"]];

        if([strID isEqualToString:USERID]){
            
        }else{
            UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Un Block"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          [appDelegate().socket emit:@"unblockAfriend" with:@[[dict objectForKey:@"user_id"],USERID]];
                                           [AlertView showAlertWithMessage:@"User Un Blocked successfully" view:self];
                                          if([_strFromMarketPlace isEqualToString:@"yes"]){
                                              // emit("showItemChatList", user_id, post_id)
                                              [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
                                          }else{
                                              [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
                                          }
                                      }];
            [alert addAction:btnEdit];

        }

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
        
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
        [self presentViewController:alert animated:YES completion:nil];
   
}



#pragma mark searchbar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([_strFromMarketPlace isEqualToString:@"yes"]){
        // emit("showItemChatList", user_id, post_id)
        [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    }else{
       // [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
        [appDelegate().socket emit:@"showMyChatList" with:@[USERID,searchBar.text]];
    }
    
   
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([_strFromMarketPlace isEqualToString:@"yes"]){
        // emit("showItemChatList", user_id, post_id)
        [appDelegate().socket emit:@"showItemChatList" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    }else{
        [appDelegate().socket emit:@"showMyChatList" with:@[USERID,@""]];
    }
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
}

@end

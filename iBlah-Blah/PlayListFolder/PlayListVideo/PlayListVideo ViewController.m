//
//  PlayListVideo ViewController.m
//  iBlah-Blah
//
//  Created by webHex on 28/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PlayListVideo ViewController.h"
#import "CommentVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "EditVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;
@interface PlayListVideo_ViewController (){
    NSArray *arryPlaylist;
     IndecatorView *ind;
    NSDictionary *rateSelectedDict;
}

@end

@implementation PlayListVideo_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //mSocket.emit("showAllPlayListVideos", user_id, playlist_id);
    // Do any additional setup after loading the view from its nib.
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    self.viewRateSubView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
    self.viewRate.layer.cornerRadius=10;
    self.btnRateNow.layer.cornerRadius=25;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getMyPlayListVideo"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"LikeClicked"
                                               object:nil];//LikeClicked
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getCommentCount"
                                               object:nil];//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"refreshMyPlayList1"
                                               object:nil];
    [self setNavigationBar];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllPlayListVideos" with:@[USERID,[_dictPlayListValue objectForKey:@"playlist_id"]]];
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}
- (void)receivedNotification:(NSNotification *) notification {
  if ([[notification name] isEqualToString:@"getMyPlayListVideo"]) {
      [ind removeFromSuperview];
      NSDictionary* userInfo = notification.userInfo;
      NSArray *Arr=[userInfo objectForKey:@"DATA"];
      NSArray *arryVideo=[Arr objectAtIndex:1];
      arryPlaylist=arryVideo;
      [_tblPlayListVideo reloadData];
      
  }else if([[notification name] isEqualToString:@"LikeClicked"]){//getCommentCount
      NSDictionary* userInfo = notification.userInfo;
      [self likeUpdate:userInfo];
  }else if([[notification name] isEqualToString:@"getCommentCount"]){//getPlayList
      NSDictionary* userInfo = notification.userInfo;
      [self commentCountUpdate:userInfo];
  }else if([[notification name] isEqualToString:@"refreshMyPlayList1"]){
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
      NSString *USERID = [prefs stringForKey:@"USERID"];
       [appDelegate().socket emit:@"showAllPlayListVideos" with:@[USERID,[_dictPlayListValue objectForKey:@"playlist_id"]]];
  }
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
    
self.title=[_dictPlayListValue objectForKey:@"playlist_name"];
    
}

-(void)hideIndecatorView{
    [ind removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryPlaylist.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 225;
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
        // cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    
    NSDictionary *dict=[arryPlaylist objectAtIndex:indexPath.row];
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"video_thumb"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
    AsyncImageView *playicon=[[AsyncImageView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/2)-16, 59,32,32)];
    playicon.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    playicon.image=[UIImage imageNamed:@"playIcon"];
    playicon.clipsToBounds=YES;
    [playicon setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:playicon];
    
    
    UIButton *btnPlayVideo = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
    
    btnPlayVideo.tag=indexPath.row;
    [cell.contentView addSubview:btnPlayVideo];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"title"];
    [cell.contentView addSubview:name];
    
    UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
    [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
    btnMore.tag=indexPath.row;
    NSString *strUserId=[_dictPlayListValue objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if([strUserId isEqualToString:USERID]){
        [cell.contentView addSubview:btnMore];
    }
    
    
  
        [btnPlayVideo addTarget:self
                         action:@selector(cmdplayAllVideo:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreALLVideo:) forControlEvents:UIControlEventTouchUpInside];


    
    UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(8, 170,self.view.frame.size.width-16,20)];
    [byWhome setFont:[UIFont boldSystemFontOfSize:16]];
    byWhome.textAlignment=NSTextAlignmentLeft;
    byWhome.numberOfLines=2;
    byWhome.lineBreakMode=NSLineBreakByWordWrapping;
    byWhome.textColor=[UIColor blackColor];
    byWhome.text=[NSString stringWithFormat:@"By %@",[dict objectForKey:@"name"]];
    [cell.contentView addSubview:byWhome];
    
    
    UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];//CGRectMake(SCREEN_SIZE.width-58, 190, 50, 32)
    btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 190, 50, 32);
    [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
                                                                                  //    countLikes = 4;
                                                                                  //    countcomments = 2;
                                                                                  //view_count
    [btnLike setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"likes_count"]] forState:UIControlStateNormal];
    
    btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLike.layer.cornerRadius=8;//0,160,223
    btnLike.layer.borderWidth=1;
    btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    if(!([strIsLike isEqualToString:@"0"])){
        btnLike.tintColor = [UIColor whiteColor];//
        [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }else{
        btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
    btnLike.tag=indexPath.row;
    [cell.contentView addSubview:btnLike];
    
    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 190, 50, 32)];
    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"comments_count"]] forState:UIControlStateNormal];
    
    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnComment.layer.cornerRadius=8;//0,160,223
    btnComment.layer.borderWidth=1;
    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnComment.tag=indexPath.row;
    
    [cell.contentView addSubview:btnComment];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 190, 40, 32)];
    [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    
    btnShare.tag=indexPath.row;
    btnShare.layer.cornerRadius=8;//0,160,223
    btnShare.layer.borderWidth=1;
    btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [cell.contentView addSubview:btnShare];
    
    
    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 190, 50, 32)];
    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
    btnView.layer.cornerRadius=10;//0,160,223
    btnView.layer.borderWidth=1;
    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnView.tag=indexPath.row;
    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [cell.contentView addSubview:btnView];
    
    
    UIButton *btnRate=[UIButton buttonWithType:UIButtonTypeSystem];
    btnRate.frame=CGRectMake(SCREEN_SIZE.width-232, 190, 50, 32);
    
    [btnRate setImage:[UIImage imageNamed:@"rateNotSelected"] forState:UIControlStateNormal];
    [btnRate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnRate setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"rating"]] forState:UIControlStateNormal];
    btnRate.layer.cornerRadius=10;//0,160,223
    btnRate.layer.borderWidth=1;
    btnRate.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnRate.tag=indexPath.row;
    btnRate.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [cell.contentView addSubview:btnRate];
    NSString *strIsRate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isRate"]];
    if(!([strIsRate isEqualToString:@"0"])){
        btnRate.userInteractionEnabled=NO;
        btnRate.tintColor = [UIColor whiteColor];//
        [btnRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnRate.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }else{
        btnRate.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
   
    
        [btnRate addTarget:self
                action:@selector(cmdRateAllvideo:)
      forControlEvents:UIControlEventTouchUpInside];
   
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllVideo:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareAllvideo:)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 224, SCREEN_SIZE.width-40 , 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    return cell;
}
-(void)cmdLikeAllVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryPlaylist objectAtIndex:btn.tag];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"likes_count"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1 =@"1";
    }else{
        Count --;
        strIsLike1 =@"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"likes_count"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"islike"];
    NSMutableArray *temp = [arryPlaylist mutableCopy];
    
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryPlaylist = temp;
    [_tblPlayListVideo reloadData];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{
        
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
}
-(void)cmdCommentAllVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlaylist objectAtIndex:btn.tag];
    [self comment:dict];
}
-(void)cmdShareAllvideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlaylist objectAtIndex:btn.tag];
    
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"\n\nDownload to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                        @"Via iBlah-Blah", nil];
    
    UIActivityViewController *ActivityView =
    [[UIActivityViewController alloc]
     initWithActivityItems:Items applicationActivities:nil];
    if (IDIOM == IPAD)
    {
        NSLog(@"iPad");
        ActivityView.popoverPresentationController.sourceView = self.view;
        //        activityViewController.popoverPresentationController.sourceRect = self.frame;
        [self presentViewController:ActivityView
                           animated:YES
                         completion:nil];
    }
    else
    {
        NSLog(@"iPhone");
        [self presentViewController:ActivityView
                           animated:YES
                         completion:nil];
    }
}
-(void)cmdplayAllVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlaylist objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];
}
-(void)cmdMoreALLVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlaylist objectAtIndex:btn.tag];
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove from Playlist" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
         [appDelegate().socket emit:@"removeFromMyPlayList" with:@[USERID,[dict objectForKey:@"id"],[_dictPlayListValue objectForKey:@"playlist_id"]]];
         [self performSelector:@selector(reloadTable) withObject:nil afterDelay:1.5];
        // Distructive button tapped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    NSString *strUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
  if([strUserId isEqualToString:USERID]){
      [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
          
          EditVideoViewController *folderViewController=[[EditVideoViewController alloc]initWithNibName:@"EditVideoViewController" bundle:nil];
          folderViewController.dictVideoData = dict;
          [self.navigationController pushViewController:folderViewController animated:YES];
      }]];
  }
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Save Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *strUrl=[dict objectForKey:@"video_url"];
        
        NSURL *video_url = [NSURL URLWithString:strUrl];
        
        [AlertView showAlertWithMessage:@"Downloading Started." view:self];
        
        {
            if([video_url absoluteString].length < 1) {
                return;
            }
            
            NSLog(@"source will be : %@", video_url.absoluteString);
            NSURL *sourceURL = video_url;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:[video_url absoluteString]]) {
                [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:video_url completionBlock:^(NSURL *assetURL, NSError *error) {
                    
                    if(assetURL) {
                        [AlertView showAlertWithMessage:@"video saved." view:self];
                        NSLog(@"saved down");
                    } else {
                        NSLog(@"something wrong");
                    }
                }];
                
            } else {
                
                NSURLSessionTask *download = [[NSURLSession sharedSession] downloadTaskWithURL:sourceURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                    if(error) {
                        NSLog(@"error saving: %@", error.localizedDescription);
                        return;
                    }
                    
                    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
                    NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[sourceURL lastPathComponent]];
                    
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil];
                    
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:tempURL];
                        
                        NSLog(@"%@", changeRequest.description);
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (success) {
                             [AlertView showAlertWithMessage:@"video saved." view:self];
                            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
                        } else {
                            NSLog(@"something wrong %@", error.localizedDescription);
                            [[NSFileManager defaultManager] removeItemAtURL:tempURL error:nil];
                        }
                    }];
                }];
                [download resume];
            }
        }
        
        
        
            // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [actionSheet
                                                         popoverPresentationController];
        popPresenter.sourceView = btn;
        popPresenter.sourceRect = btn.bounds;
        
    }
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
-(void)reloadTable{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refreshMyPlayList"
     object:self userInfo:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllPlayListVideos" with:@[USERID,[_dictPlayListValue objectForKey:@"playlist_id"]]];
}
-(void)comment:(NSDictionary *)dict{
    CommentVideoViewController *cont=[[CommentVideoViewController alloc]initWithNibName:@"CommentVideoViewController" bundle:nil];
    cont.dictPost=dict;
    [self.navigationController pushViewController:cont animated:YES];

   // [self.navigationController presentViewController:cont animated:YES completion:nil];
}
-(void)playVideo:(NSString *)strUrl videoId:(NSString *)videoId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"addToVideoHistory" with:@[USERID,videoId]];
    //   mSocket.emit("addToVideoHistory", user_id, id);
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *videoURL = [NSURL URLWithString:strUrl];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
    [self performSelector:@selector(getVideoHistory) withObject:nil afterDelay:5.0];
}
-(void)getVideoHistory{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
    [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
    [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
}

#pragma mark like dislike comment update
-(void)likeUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
    //    NSArray *arryMyVideo;
    //    NSArray *arryfavoriteVideo;
    //    NSArray *arryWatchLater;
    // NSArray *arryHistory;
    
    
    
    NSArray *filteredAllVideo = [arryPlaylist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
  
    if(filteredAllVideo.count>0){
        NSDictionary *item = [filteredAllVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryPlaylist indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryPlaylist mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryPlaylist=temp;
            [_tblPlayListVideo  reloadData];
        }
    }
}
-(void)commentCountUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
    NSArray *filteredAllVideo = [arryPlaylist filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
   
    if(filteredAllVideo.count>0){
        NSDictionary *item = [filteredAllVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryPlaylist indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryPlaylist mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryPlaylist=temp;
            [_tblPlayListVideo  reloadData];
        }
    }
}

-(void)cmdRateAllvideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlaylist objectAtIndex:btn.tag];
    rateSelectedDict=dict;
   
    _viewRateSubView.frame=CGRectMake(0, -SCREEN_SIZE.height,SCREEN_SIZE.width, SCREEN_SIZE.height);
    _viewRateSubView.hidden=NO;
    [self.view addSubview:_viewRateSubView];
    [UIView animateWithDuration:1.0f
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:5.0
                        options:0
                     animations:^{ _viewRateSubView.frame = CGRectMake(0, 0,SCREEN_SIZE.width, SCREEN_SIZE.height); }
                     completion:^(BOOL finished) {
                             // slide down animation finished, remove the older view and the constraints
                             //
                     }];
}

- (IBAction)cmdRateCancel:(id)sender {
   
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _viewRateSubView.alpha = 0;
                     }completion:^(BOOL finished){
                         _viewRateSubView.alpha = 1.0f;
                         _starView.value=0;
                         [_viewRateSubView removeFromSuperview];
                     }];
    
}

- (IBAction)cmdRateNow:(id)sender {
    
        //  emit("rateVideo", user_id, video_id, rating);
    NSString *strValue=[NSString stringWithFormat:@"%f",_starView.value];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"rateVideo" with:@[USERID,[rateSelectedDict objectForKey:@"id"],strValue]];
    
  
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _viewRateSubView.alpha = 0;
                     }completion:^(BOOL finished){
                         _viewRateSubView.alpha = 1.0f;
                         [_viewRateSubView removeFromSuperview];
                         
                         [[NSNotificationCenter defaultCenter]
                          postNotificationName:@"refreshMyPlayList"
                          object:self userInfo:nil];
                         [appDelegate().socket emit:@"showAllPlayListVideos" with:@[USERID,[_dictPlayListValue objectForKey:@"playlist_id"]]];
                         _starView.value=0;
                     }];
    
    
    NSLog(@"%f", _starView.value);
}

@end

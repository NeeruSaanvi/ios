     //
    //  VideoViewController.m
    //  iBlah-Blah
    //
    //  Created by Arun on 05/04/18.
    //  Copyright © 2018 webHax. All rights reserved.
    //

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "CommentVideoViewController.h"
#import "AddVideoViewController.h"
#import "PlayListFolderViewController.h"
#import "PlayListVideo ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EditVideoViewController.h"
@import Photos;
@interface VideoViewController ()<UIScrollViewDelegate>{
    NSArray *arryAllVideo;
    NSArray *arryMyVideo;
    NSArray *arryfavoriteVideo;
    NSArray *arryWatchLater;
    IndecatorView *ind;
    NSArray *arryHistory;
    NSArray *arryPlayList;
    NSArray *arryAllPlayList;
    NSDictionary *rateSelectedDict;
    NSString *rateSelectedArray;
}

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
    [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    //mSocket.emit("showAllVideos",UserID);
    [self setNavigationBar];
     self.viewRateSubView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
    self.viewRate.layer.cornerRadius=10;
    self.btnRateNow.layer.cornerRadius=25;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllVideo"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllVideoHistory"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MyVideo"
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
                                                 name:@"getPlayList"
                                               object:nil];//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"refreshMyPlayList"
                                               object:nil];//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllPlaylist"
                                               object:nil];//rateVideo
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"rateVideo"
                                               object:nil];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
     [appDelegate().socket emit:@"showAllPlayList" with:@[USERID]];
     [appDelegate().socket emit:@"showMyPlayList" with:@[USERID]];
     [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
     [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
     [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
    //mSocket.emit("showMyVideos", user_id);
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
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
    
    self.title=@"Video";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddVideo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self checkLayout];
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllVideo"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSArray *arryVideo=[Arr objectAtIndex:1];
        NSMutableArray *tempWatchLater=[[NSMutableArray alloc]init];
        NSMutableArray *tempFav=[[NSMutableArray alloc]init];
        for (int i=0; i<arryVideo.count; i++) {
            NSDictionary *dict=[arryVideo objectAtIndex:i];
            NSString *strWatchlater=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isWatchLater"]];
            NSString *strFav=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isFav"]];
            if([strWatchlater isEqualToString:@"1"]){
                [tempWatchLater addObject:dict];
            }
            if([strFav isEqualToString:@"1"]){
                [tempFav addObject:dict];
            }
        }
        arryAllVideo=arryVideo;
        arryWatchLater=tempWatchLater;
        arryfavoriteVideo=tempFav;
        [_tblAllVideo reloadData];
        [_tblWatchLater reloadData];
        [_tblFavoriteVideo reloadData];

        //
    }else if ([[notification name] isEqualToString:@"MyVideo"]){
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSArray *arryVideo=[Arr objectAtIndex:1];
        arryMyVideo=arryVideo;
        [_tblMyVideo reloadData];
    }else if ([[notification name] isEqualToString:@"AllVideoHistory"]){
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSArray *arryVideo=[Arr objectAtIndex:1];
        arryHistory=arryVideo;
        [_tblHistory reloadData];
    }else if([[notification name] isEqualToString:@"LikeClicked"]){//getCommentCount
        NSDictionary* userInfo = notification.userInfo;
        [self likeUpdate:userInfo];
    }else if([[notification name] isEqualToString:@"getCommentCount"]){//getPlayList
        NSDictionary* userInfo = notification.userInfo;
        [self commentCountUpdate:userInfo];
    }else if([[notification name] isEqualToString:@"getPlayList"]){//
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryPlayList=json;
        [_tblMyPlaylist reloadData];
    }else if([[notification name] isEqualToString:@"refreshMyPlayList"]){//AllPlaylist
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
        [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
        [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
        [appDelegate().socket emit:@"showMyPlayList" with:@[USERID]];
       [appDelegate().socket emit:@"showAllPlayList" with:@[USERID]];
    }else if([[notification name] isEqualToString:@"AllPlaylist"]){//rateVideo
        [ind removeFromSuperview];
        
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryAllPlayList=json;
        [_tblAllPlaylist reloadData];
        
    }else if([[notification name] isEqualToString:@"rateVideo"]){//
        
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
//        NSError *jsonError;
//        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
//        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&jsonError];
//        arryAllPlayList=json;
//        [_tblAllPlaylist reloadData];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (IBAction)cmdAllVideo:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(0, 0) animated:YES];
}
- (IBAction)cmdMyVideo:(id)sender {
     [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
}
- (IBAction)cmdFavoriteVideo:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*2, 0) animated:YES];
}
- (IBAction)cmdWatchLater:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*3, 0) animated:YES];
}
- (IBAction)cmdAllPlaylist:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*4, 0) animated:YES];
}
- (IBAction)cmdMyPlaylist:(id)sender {
     [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*5, 0) animated:YES];
}
- (IBAction)cmdHistory:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*6, 0) animated:YES];
}




-(void)cmdAddVideo:(id)sender{
    AddVideoViewController *cont=[[AddVideoViewController alloc]initWithNibName:@"AddVideoViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
-(void)checkLayout{
    
    
    CGRect frame=self.tblAllVideo.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblAllVideo.frame=frame;
    
    frame=self.tblMyVideo.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblMyVideo.frame=frame;
    frame=self.tblMyVideo.frame;
    
    frame=self.tblFavoriteVideo.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*2;
    self.tblFavoriteVideo.frame=frame;
    frame=self.tblFavoriteVideo.frame;
    
    frame=self.tblWatchLater.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*3;
    self.tblWatchLater.frame=frame;
    frame=self.tblWatchLater.frame;
    
    frame=self.tblAllPlaylist.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*4;
    self.tblAllPlaylist.frame=frame;
    frame=self.tblAllPlaylist.frame;
    
    
    frame=self.tblMyPlaylist.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*5;
    self.tblMyPlaylist.frame=frame;
    frame=self.tblMyPlaylist.frame;
    
    frame=self.tblHistory.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*6;
    self.tblHistory.frame=frame;
    frame=self.tblHistory.frame;
    
    frame= _btnAllVideo.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btnAllVideo.frame=frame;
    
    frame= _btnMyVideo.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnMyVideo.frame=frame;
    
    frame= _btnFavoriteVideo.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width;
    _btnFavoriteVideo.frame=frame;
    
    frame= _btnWatchLater.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=(SCREEN_SIZE.width/2)*3;
    _btnWatchLater.frame=frame;
    
    frame= _btnAllPlaylist.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=(SCREEN_SIZE.width/2)*4;
    _btnAllPlaylist.frame=frame;
    
    frame= _btnMyPlaylist.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=(SCREEN_SIZE.width/2)*5;
    _btnMyPlaylist.frame=frame;
    
    frame= _btnHistory.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=(SCREEN_SIZE.width/2)*6;
    _btnHistory.frame=frame;
    
    frame=_SelectedTabanimation.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _SelectedTabanimation.frame=frame;
    [self addingAnimationToTable];
    
}

-(void)addingAnimationToTable{
    
        // CGRect frame                                   = CGRectMake(0, 0, SCREEN_SIZE.width, self.view.frame.size.height);
        // self.ScrollView                                = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollViewBtn.backgroundColor                = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.scrollViewBtn.pagingEnabled                  = YES;
    self.scrollViewBtn.showsHorizontalScrollIndicator = NO;
    self.scrollViewBtn.showsVerticalScrollIndicator   = NO;
    self.scrollViewBtn.delegate                       = self;
    self.scrollViewBtn.bounces                        = NO;
    
    
    float width                 = (SCREEN_SIZE.width/2) * 7;
    float height                = 40;
    self.scrollViewBtn.contentSize = (CGSize){width, height};
    [self.scrollViewBtn setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.scrollViewTable.backgroundColor                = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.scrollViewTable.pagingEnabled                  = YES;
    self.scrollViewTable.showsHorizontalScrollIndicator = NO;
    self.scrollViewTable.showsVerticalScrollIndicator   = NO;
    self.scrollViewTable.delegate                       = self;
    self.scrollViewTable.bounces                        = NO;
    
    
    float width1                 = SCREEN_SIZE.width * 7;
    float height1                = CGRectGetHeight(self.view.frame);
    float tobbarhig1            = CGRectGetHeight(self.tblAllVideo.frame);
    float btnhig1                = CGRectGetHeight(_tblAllVideo.frame);
    float selectedHig1           = CGRectGetHeight(_SelectedTabanimation.frame);
    height1                      = height1-tobbarhig1-btnhig1-selectedHig1;
    self.scrollViewTable.contentSize = (CGSize){width1, height1};
    [self.scrollViewTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

#pragma mark ---------- ScrollView delegate --------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView== self.scrollViewTable){
        CGFloat percentage = scrollView.contentOffset.x / scrollView.contentSize.width;
        
        CGRect frame = _SelectedTabanimation.frame;
        frame.origin.x = (scrollView.contentOffset.x + percentage * SCREEN_SIZE.width)/3;
        _SelectedTabanimation.frame = frame;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView== self.scrollViewTable){
        [self sendNewIndex:scrollView];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if(scrollView== self.scrollViewTable){
        [self sendNewIndex:scrollView];
    }
}

-(void)sendNewIndex:(UIScrollView *)scrollView{
    CGFloat xOffset = scrollView.contentOffset.x;
    if(scrollView== self.scrollViewTable){
        if(xOffset>=SCREEN_SIZE.width && xOffset<SCREEN_SIZE.width*2){
            [self changeButtonColor];
            [_btnMyVideo setBackgroundColor:[UIColor whiteColor]];
            [_btnMyVideo setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
             [self.scrollViewBtn setContentOffset:CGPointMake(0, 0) animated:YES];
        }else if (xOffset>=SCREEN_SIZE.width*2 && xOffset<SCREEN_SIZE.width*3){
            
            [self changeButtonColor];
            [_btnFavoriteVideo setBackgroundColor:[UIColor whiteColor]];
            [_btnFavoriteVideo setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
             [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
        }else if (xOffset>=SCREEN_SIZE.width*3 && xOffset<SCREEN_SIZE.width*4){
            [self changeButtonColor];
            [_btnWatchLater setBackgroundColor:[UIColor whiteColor]];
            [_btnWatchLater setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
        }else if (xOffset>=SCREEN_SIZE.width*4 && xOffset<SCREEN_SIZE.width*5){
            [self changeButtonColor];
            [_btnAllPlaylist setBackgroundColor:[UIColor whiteColor]];
            [_btnAllPlaylist setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width*2, 0) animated:YES];
        }else if (xOffset>=SCREEN_SIZE.width*5 && xOffset<SCREEN_SIZE.width*6){
            [self changeButtonColor];
            [_btnMyPlaylist setBackgroundColor:[UIColor whiteColor]];
            [_btnMyPlaylist setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width*2, 0) animated:YES];
        }else if (xOffset>=SCREEN_SIZE.width*6 && xOffset<SCREEN_SIZE.width*7){
            [self changeButtonColor];
            [_btnHistory setBackgroundColor:[UIColor whiteColor]];
            [_btnHistory setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width*3, 0) animated:YES];
        }else{
            [self changeButtonColor];
            [_btnAllVideo setBackgroundColor:[UIColor whiteColor]];
            [_btnAllVideo setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.scrollViewBtn setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}
-(void)changeButtonColor{
    [_btnAllVideo setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnAllVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnMyVideo  setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnMyVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnFavoriteVideo setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnFavoriteVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnWatchLater setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnWatchLater setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnAllPlaylist setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnAllPlaylist setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnMyPlaylist  setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnMyPlaylist setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnHistory  setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView==_tblAllVideo){
        return arryAllVideo.count;
    }else if (_tblWatchLater==tableView){
         return arryWatchLater.count;
    }else if (_tblFavoriteVideo==tableView){
        return arryfavoriteVideo.count;
    }else if (_tblMyVideo ==tableView){
        return arryMyVideo.count;
    }else if (_tblHistory ==tableView){
        return arryHistory.count;
    }else if (_tblMyPlaylist ==tableView){
        return arryPlayList.count;
    }else if (_tblAllPlaylist ==tableView){
        return arryAllPlayList.count;
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
     if (_tblMyPlaylist ==tableView){
        return 200;
    }
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
    
        NSDictionary *dict;
    if(tableView==_tblAllVideo){
        dict=[arryAllVideo objectAtIndex:indexPath.row];
    }else if (_tblWatchLater==tableView){
        dict=[arryWatchLater objectAtIndex:indexPath.row];
    }else if (_tblFavoriteVideo==tableView){
         dict=[arryfavoriteVideo objectAtIndex:indexPath.row];
    }else if (_tblMyVideo==tableView){
        dict=[arryMyVideo objectAtIndex:indexPath.row];
    }else if (_tblHistory==tableView){
        dict=[arryHistory objectAtIndex:indexPath.row];
    }else if (_tblMyPlaylist==tableView){
        dict=[arryPlayList objectAtIndex:indexPath.row];
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"playlist_image"]];
        banner.imageURL=[NSURL URLWithString:strUrl];
        banner.clipsToBounds=YES;
        [banner setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:banner];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
        [name setFont:[UIFont boldSystemFontOfSize:16]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textColor=[UIColor blackColor];
        name.text=[dict objectForKey:@"playlist_name"];
        [cell.contentView addSubview:name];
        
        UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(8, 170,self.view.frame.size.width-16,20)];
        [byWhome setFont:[UIFont boldSystemFontOfSize:16]];
        byWhome.textAlignment=NSTextAlignmentLeft;
        byWhome.numberOfLines=2;
        byWhome.lineBreakMode=NSLineBreakByWordWrapping;
        byWhome.textColor=[UIColor blackColor];
        byWhome.text=[NSString stringWithFormat:@"By %@",[dict objectForKey:@"name"]];
        [cell.contentView addSubview:byWhome];
        UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
        [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
        btnMore.tag=indexPath.row;
        [btnMore addTarget:self action:@selector(cmdMoremyPlaylist:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnMore];
        
        
        UIView *viewOverLay=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/3)*2, 0,SCREEN_SIZE.width/3,150)];
        viewOverLay.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
        UILabel* lblCount = [[UILabel alloc]init];
        lblCount.font=[UIFont boldSystemFontOfSize:34.0];
        lblCount.textAlignment = NSTextAlignmentCenter;
        lblCount.textColor = [UIColor whiteColor];
        lblCount.numberOfLines = 0;
        lblCount.backgroundColor=[UIColor clearColor];
        lblCount.frame=CGRectMake(0, 0,SCREEN_SIZE.width/3,150);
        lblCount.text=[NSString stringWithFormat:@"+%@",[NSString stringWithFormat:@"%@",[dict objectForKey:@"videos_count"]]];
        [viewOverLay addSubview:lblCount];
        [cell.contentView addSubview:viewOverLay];
        
        return cell;
        
    }else if (_tblAllPlaylist==tableView){
        
        dict=[arryAllPlayList objectAtIndex:indexPath.row];
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"playlist_image"]];
        banner.imageURL=[NSURL URLWithString:strUrl];
        banner.clipsToBounds=YES;
        [banner setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:banner];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
        [name setFont:[UIFont boldSystemFontOfSize:16]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textColor=[UIColor blackColor];
        name.text=[dict objectForKey:@"playlist_name"];
        [cell.contentView addSubview:name];
        
        UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(8, 170,self.view.frame.size.width-16,20)];
        [byWhome setFont:[UIFont boldSystemFontOfSize:16]];
        byWhome.textAlignment=NSTextAlignmentLeft;
        byWhome.numberOfLines=2;
        byWhome.lineBreakMode=NSLineBreakByWordWrapping;
        byWhome.textColor=[UIColor blackColor];
        byWhome.text=[NSString stringWithFormat:@"By %@",[dict objectForKey:@"name"]];
        [cell.contentView addSubview:byWhome];
        UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
        [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
        btnMore.tag=indexPath.row;
        [btnMore addTarget:self action:@selector(cmdMoremyPlaylist:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnMore];
        
        
        UIView *viewOverLay=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/3)*2, 0,SCREEN_SIZE.width/3,150)];
        viewOverLay.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
        UILabel* lblCount = [[UILabel alloc]init];
        lblCount.font=[UIFont boldSystemFontOfSize:34.0];
        lblCount.textAlignment = NSTextAlignmentCenter;
        lblCount.textColor = [UIColor whiteColor];
        lblCount.numberOfLines = 0;
        lblCount.backgroundColor=[UIColor clearColor];
        lblCount.frame=CGRectMake(0, 0,SCREEN_SIZE.width/3,150);
        lblCount.text=[NSString stringWithFormat:@"+%@",[NSString stringWithFormat:@"%@",[dict objectForKey:@"videos_count"]]];
        [viewOverLay addSubview:lblCount];
        [cell.contentView addSubview:viewOverLay];
        
        return cell;
        
        
    }
    
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
    
    [cell.contentView addSubview:btnMore];
   
    if(tableView==_tblAllVideo){
        [btnPlayVideo addTarget:self
                         action:@selector(cmdplayAllVideo:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreALLVideo:) forControlEvents:UIControlEventTouchUpInside];
    }else if (_tblWatchLater==tableView){
        [btnPlayVideo addTarget:self
                         action:@selector(cmdplaywatchLater:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreWatchlater:) forControlEvents:UIControlEventTouchUpInside];
    }else if (_tblFavoriteVideo==tableView){
        [btnPlayVideo addTarget:self
                         action:@selector(cmdplayFavVideo:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreFavVideo:) forControlEvents:UIControlEventTouchUpInside];
    }else if (_tblMyVideo==tableView){
        [btnPlayVideo addTarget:self
                         action:@selector(cmdmyVideos:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoremyVideos:) forControlEvents:UIControlEventTouchUpInside];
    }else if (_tblHistory==tableView){
        [btnPlayVideo addTarget:self
                         action:@selector(cmdVideoHistory:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreVideoHistory:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
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
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 190, 50, 32)];
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
    
    if(tableView==_tblAllVideo){
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllVideo:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareAllvideo:)
           forControlEvents:UIControlEventTouchUpInside];
        [btnRate addTarget:self
                     action:@selector(cmdRateAllvideo:)
           forControlEvents:UIControlEventTouchUpInside];
     
    }else if (_tblWatchLater==tableView){
        [btnLike addTarget:self
                    action:@selector(cmdLikeWatchLater:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentWatchLater:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareWatchLater:)
           forControlEvents:UIControlEventTouchUpInside];
        [btnRate addTarget:self
                    action:@selector(cmdRateWatchLater:)
          forControlEvents:UIControlEventTouchUpInside];
      
        
    }else if (_tblFavoriteVideo==tableView){
        [btnLike addTarget:self
                    action:@selector(cmdLikeFavVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentFavVideo:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareFavVideo:)
           forControlEvents:UIControlEventTouchUpInside];
        [btnRate addTarget:self
                    action:@selector(cmdRateFavVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        
    }else if (_tblMyVideo==tableView){
        [btnLike addTarget:self
                    action:@selector(cmdLikeMyVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentMyVideo:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareMyVideo:)
           forControlEvents:UIControlEventTouchUpInside];
        [btnRate addTarget:self
                    action:@selector(cmdRateMyVideo:)
          forControlEvents:UIControlEventTouchUpInside];
    }else if (_tblHistory==tableView){
        [btnLike addTarget:self
                    action:@selector(cmdLikeHistory:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentHistory:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareHistory:)
           forControlEvents:UIControlEventTouchUpInside];
        [btnRate addTarget:self
                    action:@selector(cmdRateHistory:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 224, SCREEN_SIZE.width-40 , 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _tblMyPlaylist){
        NSDictionary *dict=[arryPlayList objectAtIndex:indexPath.row];
        PlayListVideo_ViewController *cont=[[PlayListVideo_ViewController alloc]initWithNibName:@"PlayListVideo ViewController" bundle:nil];
        cont.dictPlayListValue=dict;
        [self.navigationController pushViewController:cont animated:YES];
    }  if(tableView == _tblAllPlaylist){
        NSDictionary *dict=[arryAllPlayList objectAtIndex:indexPath.row];
        PlayListVideo_ViewController *cont=[[PlayListVideo_ViewController alloc]initWithNibName:@"PlayListVideo ViewController" bundle:nil];
        cont.dictPlayListValue=dict;
        [self.navigationController pushViewController:cont animated:YES];
    }
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

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark table buttonAction

//category = "All Categories";
//"comments_count" = 0;
//description = "yes description ";
//"fav_count" = 0;
//id = "9318d330-4927-11e8-acb5-253ef70f2e59";
//image = "1519410306_2534903982.png";
//isFav = 1;
//isWatchLater = 1;
//"likes_count" = 0;
//name = "Perez Ivan";
//privacy = 0;
//tags = tag;
//time = "2018-04-26T07:58:15.000Z";
//title = "test ";
//"user_id" = "5d12dbf3-82f2-45b9-8fde-3ef69a187092";
//"video_thumb" = "http://iblah-blah.com/iblah/images/1524729475.jpg";
//"video_type" = 0;
//"video_url" = "http://iblah-blah.com/iblah/videos/1524729475_9525330862.mov";

-(void)cmdLikeAllVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryAllVideo objectAtIndex:btn.tag];
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
    NSMutableArray *temp = [arryAllVideo mutableCopy];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryAllVideo = temp;
    [_tblAllVideo reloadData];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{
        
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
}
-(void)cmdCommentAllVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllVideo objectAtIndex:btn.tag];
    [self comment:dict];
}
-(void)cmdShareAllvideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllVideo objectAtIndex:btn.tag];
    
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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
-(void)cmdLikeWatchLater:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryWatchLater objectAtIndex:btn.tag];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"likes_count"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1 = @"1";
    }else{
        Count -- ;
        strIsLike1 = @"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"likes_count"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"islike"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSMutableArray *temp = [arryWatchLater mutableCopy];
    
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryWatchLater = temp;
    [_tblWatchLater reloadData];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{

         [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
    
    //[appDelegate().socket emit:@"" with:@[@"5d12dbf3-82f2-45b9-8fde-3ef69a187092",strPost_id,currentAllPostPage]];
}
-(void)cmdCommentWatchLater:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryWatchLater objectAtIndex:btn.tag];
    [self comment:dict];
}
-(void)cmdShareWatchLater:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryWatchLater objectAtIndex:btn.tag];
    
     NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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
-(void)cmdLikeFavVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryfavoriteVideo objectAtIndex:btn.tag];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"likes_count"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1=@"1";
    }else{
        Count -- ;
        strIsLike1=@"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"likes_count"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"islike"];
    NSMutableArray *temp = [arryfavoriteVideo mutableCopy];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryfavoriteVideo = temp;
    [_tblFavoriteVideo reloadData];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{
        
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
}
-(void)cmdLikeMyVideo:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryMyVideo objectAtIndex:btn.tag];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"likes_count"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1 =@"1";
    }else{
        Count -- ;
        strIsLike1 =@"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"likes_count"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"islike"];
    
    NSMutableArray *temp = [arryMyVideo mutableCopy];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryMyVideo = temp;
    [_tblMyVideo reloadData];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{
        
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
    
}
-(void)cmdLikeHistory:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dict = [arryHistory objectAtIndex:btn.tag];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"likes_count"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"islike"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1 = @"1";
    }else{
        Count -- ;
        strIsLike1 = @"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"likes_count"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"islike"];
    
    NSMutableArray *temp = [arryHistory mutableCopy];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arryHistory = temp;
    [_tblHistory reloadData];
    if([strIsLike isEqualToString:@"0"]){
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }else{
        
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[dict objectForKey:@"id"],@"0"]];
    }
    
}
-(void)cmdCommentFavVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryfavoriteVideo objectAtIndex:btn.tag];
    [self comment:dict];
    
}
-(void)cmdCommentMyVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryMyVideo objectAtIndex:btn.tag];
    [self comment:dict];
    
}
-(void)cmdCommentHistory:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryHistory objectAtIndex:btn.tag];
    [self comment:dict];
    
}
-(void)cmdShareFavVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryfavoriteVideo objectAtIndex:btn.tag];
    
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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
-(void)cmdShareMyVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryMyVideo objectAtIndex:btn.tag];
    
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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
-(void)cmdShareHistory:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryHistory objectAtIndex:btn.tag];
    
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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

-(void)comment:(NSDictionary *)dict{
    CommentVideoViewController *cont=[[CommentVideoViewController alloc]initWithNibName:@"CommentVideoViewController" bundle:nil];
    cont.dictPost=dict;
    [self.navigationController pushViewController:cont animated:YES];

   // [self.navigationController presentViewController:cont animated:YES completion:nil];
}
-(void)cmdplayAllVideo:(id)sender{

    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllVideo objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];
//    [self playVideo:strURl];
    
}
-(void)cmdmyVideos:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryMyVideo objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];

}
-(void)cmdVideoHistory:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryHistory objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];
    
}

-(void)cmdMoremyPlaylist:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryPlayList objectAtIndex:btn.tag];
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    NSString *strUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if([strUserId isEqualToString:USERID]){
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [appDelegate().socket emit:@"deleteMyPlayList" with:@[USERID,[dict objectForKey:@"playlist_id"]]];
                //
            [self performSelector:@selector(reloadTable) withObject:nil afterDelay:5];
                // emit("deleteMyPlayList", user_id, playlist_id);
                // Distructive button tapped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
    }
   
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        UIButton *btn=(UIButton *)sender;
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
    [_tblMyPlaylist reloadData];
}
-(void)cmdMoreALLVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllVideo objectAtIndex:btn.tag];
    [self moreOpetion:dict sender:sender];
}
-(void)cmdMoreVideoHistory:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryHistory objectAtIndex:btn.tag];
    [self moreOpetion:dict sender:sender];
}
-(void)cmdMoreWatchlater:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryWatchLater objectAtIndex:btn.tag];
    [self moreOpetion:dict sender:sender];
}

//cmdmyVideos
//cmdMoremyVideos
-(void)cmdMoreFavVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryfavoriteVideo objectAtIndex:btn.tag];
    [self moreOpetion:dict sender:sender];
}

-(void)cmdMoremyVideos:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryMyVideo objectAtIndex:btn.tag];
    [self moreOpetion:dict sender:sender];
}


-(void)moreOpetion:(NSDictionary *)dict sender:(id)sender{
    
//    isFav
//isWatchLater
    
//    REMOVE FROM WATCH LATER:-
//    mSocket.emit("removelaterVideo", user_id, video_id);
//
//
//    ADD TO WATCH LATER:-
//    mSocket.emit("laterVideo", user_id, video_id);
//
//
//    REMOVE FROM FAVORITE VIDEO:-
//    mSocket.emit("removefavVideo", user_id, video_id);
//
//
//    ADD TO FAVORITE VIDEOS:-
//    mSocket.emit("favVideo", user_id, video_id);
    //id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *videoId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSString *strIsFav=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isFav"]];
    NSString *strIsWatchLater=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isWatchLater"]];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    if([strIsWatchLater isEqualToString:@"1"]){
        UIAlertAction* btnWatchLater = [UIAlertAction actionWithTitle:@"Remove from watch later"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                             [appDelegate().socket emit:@"removelaterVideo" with:@[USERID,videoId]];
                                             [self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                        }];
        [alert addAction:btnWatchLater];
    }else{
        UIAlertAction* btnWatchLater = [UIAlertAction actionWithTitle:@"Watch later"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                             [appDelegate().socket emit:@"laterVideo" with:@[USERID,videoId]];
                                             [self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                        }];
         [alert addAction:btnWatchLater];
    }
  
    if([strIsFav isEqualToString:@"1"]){
        UIAlertAction* btnFavorite = [UIAlertAction actionWithTitle:@"Remove from favorite"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                           [appDelegate().socket emit:@"removefavVideo" with:@[USERID,videoId]];
                                           [self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                      }];
        [alert addAction:btnFavorite];
    }else{
        UIAlertAction* btnFavorite = [UIAlertAction actionWithTitle:@"Favorite"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                            [appDelegate().socket emit:@"favVideo" with:@[USERID,videoId]];
                                          [self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                      }];
        [alert addAction:btnFavorite];
    }
    
    
    NSString *strUserId=[dict objectForKey:@"user_id"];
    
    if([strUserId isEqualToString:USERID]){
        UIAlertAction* btnDelete = [UIAlertAction actionWithTitle:@"Delete Video"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          [appDelegate().socket emit:@"deleteVideos" with:@[USERID,videoId]];
                                          [self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                      }];
        [alert addAction:btnDelete];
        
        UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Edit Video"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          //emit("deleteVideos", user_id, video_id)
                                          [appDelegate().socket emit:@"editVideo" with:@[USERID,videoId]];
                                          EditVideoViewController *folderViewController=[[EditVideoViewController alloc]initWithNibName:@"EditVideoViewController" bundle:nil];
                                          folderViewController.dictVideoData = dict;
                                          [self.navigationController pushViewController:folderViewController animated:YES];
                                          //[self performSelector:@selector(getNewData) withObject:nil afterDelay:1.5];
                                      }];
        [alert addAction:btnEdit];
    }
    
    
    UIAlertAction* btnAddPlayList = [UIAlertAction actionWithTitle:@"Add to playlist"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                  {

                                      PlayListFolderViewController *folderViewController=[[PlayListFolderViewController alloc]initWithNibName:@"PlayListFolderViewController" bundle:nil];
                                      folderViewController.dictVideoData = dict;
                                      [self.navigationController pushViewController:folderViewController animated:YES];
                                      
//                                      [AlertView showAlertWithMessage:@"Comming soon." view:self];
                                  }];
    
    
    UIAlertAction* btnSaveVideo = [UIAlertAction actionWithTitle:@"Save Video"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         
                                         //NSString *strVideoName=[dict objectForKey:@"id"];
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
                                                             NSLog(@"saved down");
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
                                         
                                             //
                                     }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                              
                                 
                                 
                             }];
    [alert addAction:btnAddPlayList];
    [alert addAction:btnSaveVideo];
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

//+ (void)saveMedia:(UIImage *)image video:(NSURL *)video_url {
//    if(image) {
//        if(!image) {
//            return;
//        }
//
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//            NSLog(@"%@", changeRequest.description);
//        } completionHandler:^(BOOL success, NSError *error) {
//            if (success) {
//                NSLog(@"saved down");
//            } else {
//                NSLog(@"something wrong");
//            }
//        }];
//    } else if (video_url)
//}


-(void)getNewData{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
    [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
    [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
    [appDelegate().socket emit:@"showMyPlayList" with:@[USERID]];
    [appDelegate().socket emit:@"showAllPlayList" with:@[USERID]];
}
-(void)cmdplayFavVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryfavoriteVideo objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];
    
  //  [self playVideo:strURl];
}
-(void)cmdplaywatchLater:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryWatchLater objectAtIndex:btn.tag];
    NSString *strURl=[dict objectForKey:@"video_url"];
    NSString *strId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    [self playVideo:strURl videoId:strId];
    //[self playVideo:strURl];
}
-(void)playVideo:(NSString *)strUrl videoId:(NSString *)videoId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
   
   [appDelegate().socket emit:@"addToView" with:@[USERID,@"",videoId]];
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


-(void)cmdRateAllvideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllVideo objectAtIndex:btn.tag];
     rateSelectedDict=dict;
    rateSelectedArray=@"AllVideo";
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
-(void)cmdRateWatchLater:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryWatchLater objectAtIndex:btn.tag];
    rateSelectedDict=dict;
    rateSelectedArray=@"AllVideo";
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
-(void)cmdRateFavVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryfavoriteVideo objectAtIndex:btn.tag];
     rateSelectedDict=dict;
    rateSelectedArray=@"AllVideo";
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
-(void)cmdRateMyVideo:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryMyVideo objectAtIndex:btn.tag];
     rateSelectedDict=dict;
    rateSelectedArray=@"MyVideo";
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
-(void)cmdRateHistory:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryHistory objectAtIndex:btn.tag];
     rateSelectedDict=dict;
    rateSelectedArray=@"History";
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
-(void)getVideoHistory{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
}
#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(SCREEN_SIZE.width-40, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:15.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
#pragma mark like dislike comment update
-(void)likeUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
//    NSArray *arryMyVideo;
//    NSArray *arryfavoriteVideo;
//    NSArray *arryWatchLater;
// NSArray *arryHistory;
    
    
    
    NSArray *filteredAllVideo = [arryAllVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
     NSArray *filteredMyVideo = [arryMyVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    NSArray *filteredfavoriteVideo = [arryfavoriteVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];

    
    NSArray *filteredWatchLater = [arryWatchLater filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
        NSArray *filteredHistory = [arryHistory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    if(filteredAllVideo.count>0){
        NSDictionary *item = [filteredAllVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryAllVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryAllVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryAllVideo=temp;
            [_tblAllVideo reloadData];
        }
    }
    if(filteredMyVideo.count>0){
        NSDictionary *item = [filteredMyVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryMyVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryMyVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryMyVideo=temp;
            [_tblMyVideo reloadData];
        }
    }
    if(filteredfavoriteVideo.count>0){
        NSDictionary *item = [filteredfavoriteVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryfavoriteVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryfavoriteVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryfavoriteVideo=temp;
            [_tblFavoriteVideo reloadData];
        }
    }
    if(filteredWatchLater.count>0){
        NSDictionary *item = [filteredWatchLater objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryWatchLater indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryWatchLater mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryWatchLater=temp;
            [_tblWatchLater reloadData];
        }
    }
    if(filteredHistory.count>0){
        NSDictionary *item = [filteredHistory objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryHistory indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"likes_count"];
            NSMutableArray *temp=[arryHistory mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryHistory=temp;
            [_tblHistory  reloadData];
        }
    }
}
-(void)commentCountUpdate:(NSDictionary *)dict{
    NSArray *Arr=[dict objectForKey:@"DATA"];
    NSArray *filteredAllVideo = [arryAllVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
     NSArray *filteredMyVideo = [arryMyVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    NSArray *filteredfavoriteVideo = [arryfavoriteVideo filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    
    NSArray *filteredWatchLater = [arryWatchLater filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    NSArray *filteredHistory = [arryHistory filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(id == %@)", [Arr objectAtIndex:1]]];
    
    if(filteredAllVideo.count>0){
        NSDictionary *item = [filteredAllVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryAllVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryAllVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryAllVideo=temp;
            [_tblAllVideo reloadData];
        }
    }
    
    if(filteredMyVideo.count>0){
        NSDictionary *item = [filteredMyVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryMyVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryMyVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryMyVideo=temp;
            [_tblMyVideo reloadData];
        }
    }
    
    if(filteredfavoriteVideo.count>0){
        NSDictionary *item = [filteredfavoriteVideo objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryfavoriteVideo indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryfavoriteVideo mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryfavoriteVideo=temp;
            [_tblFavoriteVideo reloadData];
        }
    }
    if(filteredWatchLater.count>0){
        NSDictionary *item = [filteredWatchLater objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryWatchLater indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryWatchLater mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryWatchLater=temp;
            [_tblWatchLater reloadData];
        }
    }
    if(filteredHistory.count>0){
        NSDictionary *item = [filteredHistory objectAtIndex:0];
        NSLog(@"item %@",item);
        if(item){
            long indexItem=[arryHistory indexOfObject:item];
            
            NSMutableDictionary *dictNew=[item mutableCopy];
            [dictNew setValue:[Arr objectAtIndex:2] forKey:@"comments_count"];
            NSMutableArray *temp=[arryHistory mutableCopy];
            [temp replaceObjectAtIndex:indexItem withObject:dictNew];
            arryHistory=temp;
            [_tblHistory  reloadData];
        }
    }
}
- (IBAction)cmdRateCancel:(id)sender {
    rateSelectedDict=nil;
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _viewRateSubView.alpha = 0;
                     }completion:^(BOOL finished){
                         _viewRateSubView.alpha = 1.0f;
                         [_viewRateSubView removeFromSuperview];
                     }];
    
}

- (IBAction)cmdRateNow:(id)sender {
    
  //  emit("rateVideo", user_id, video_id, rating);
    NSString *strValue=[NSString stringWithFormat:@"%f",_starView.value];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"rateVideo" with:@[USERID,[rateSelectedDict objectForKey:@"id"],strValue]];
    
    rateSelectedDict=nil;
    [UIView animateWithDuration:1.0f
                          delay:0.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         _viewRateSubView.alpha = 0;
                     }completion:^(BOOL finished){
                         _viewRateSubView.alpha = 1.0f;
                         [_viewRateSubView removeFromSuperview];
                         
                         

                         if([rateSelectedArray isEqualToString:@"AllVideo"]){
                              [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
                              [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
                              [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
                         }else if([rateSelectedArray isEqualToString:@"MyVideo"]){
                             [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
                             [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
                             [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
                         }if([rateSelectedArray isEqualToString:@"History"]){
                             [appDelegate().socket emit:@"showAllVideos" with:@[USERID]];
                             [appDelegate().socket emit:@"showMyVideos" with:@[USERID]];
                             [appDelegate().socket emit:@"showMyHistoryVideos" with:@[USERID]];
                         }
                         _starView.value=0;
                     }];
   
  
    NSLog(@"%f", _starView.value);
}
@end

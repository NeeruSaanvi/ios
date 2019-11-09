//
//  EventDetails ViewController.m
//  iBlah-Blah
//
//  Created by Arun on 06/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "EventDetails ViewController.h"
#import "CommentViewController.h"
#import "InvitePeopleViewController.h"
#import "EditPostViewController.h"
#import "AllImagesViewController.h"
#import "AddPostViewController.h"
#import "CurrentLocationViewController.h"
#import "ShowLocationViewController.h"
#import "EventAnalyticViewController.h"
#import "AttendingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RecentChatListViewController.h"
#import "AGChatViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@interface EventDetails_ViewController ()<UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate>{
    IndecatorView *ind;
    NSDictionary *dictEventDetails;
    NSMutableArray *arryAllPost;
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;
    UIImage *chosenImage;
}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@property (strong, nonatomic) NSArray *imgURLs;
@end

@implementation EventDetails_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     currentAllPostPage=@"0";
    [self setNavigationBar];
    //mSocket.emit("showEventDetail", user_id, event_id);
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"EventDetails"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GroupAllPost"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllPostGroups" with:@[USERID,[_dictPost objectForKey:@"post_id"],currentAllPostPage]];
    [appDelegate().socket emit:@"showEventDetail" with:@[USERID,[_dictPost objectForKey:@"post_id"]]];
     [appDelegate().socket emit:@"addToView" with:@[USERID,@"",[_dictPost objectForKey:@"post_id"]]];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}

- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"EventDetails"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        if(json.count>0){
            dictEventDetails=[json objectAtIndex:0];
        }
        
        [_tblInformation reloadData];
       // [_tblInformation reloadData];
        
    }else  if ([[notification name] isEqualToString:@"GroupAllPost"]) {
        NSDictionary* userInfo = notification.userInfo;
            //[ind removeFromSuperview];
        if([currentAllPostPage isEqualToString:@"0"]){
            
            NSArray *Arr=[userInfo objectForKey:@"DATA"];
            
            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
                //NSDictionary *dict=json;
            arryAllPost=[json mutableCopy];//[[dict objectForKey:@"posts"] mutableCopy];
            if(Arr.count>=2){
                totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }

            [_tblActivity reloadData];
            
        }else{
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
                [arryAllPost addObjectsFromArray:[json mutableCopy]];
            }else{
                if(currentPageAll==0){
                    arryAllPost=[json mutableCopy];
                }else{
                    [arryAllPost addObjectsFromArray:[json mutableCopy]];
                }
            }
            if(Arr.count>=2){
                totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            [_tblActivity reloadData];
        }
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self checkLayout];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.title=@"Information";
    self.navigationController.navigationBarHidden=NO;
    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"More" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdInvite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)cmdInvite:(id)sender{
    
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Invite Friend"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   
                                   InvitePeopleViewController *cont=[[InvitePeopleViewController alloc]initWithNibName:@"InvitePeopleViewController" bundle:nil];
                                   [self.navigationController pushViewController:cont animated:YES];
                               }];
    
    
    UIAlertAction* btnEdit = [UIAlertAction actionWithTitle:@"Event Analytic"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                              {
                                  EventAnalyticViewController *cont=[[EventAnalyticViewController alloc]initWithNibName:@"EventAnalyticViewController" bundle:nil];
                                  [self.navigationController pushViewController:cont animated:YES];
                                  
                                  
                              }];
    [alert addAction:btnEdit];
    
    UIAlertAction* btnEdit1 = [UIAlertAction actionWithTitle:@"Attending User List"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                              {
                                  AttendingViewController *R2VC = [[AttendingViewController alloc]initWithNibName:@"AttendingViewController" bundle:nil];
                                  R2VC.dictPost=_dictPost;
                                  [self.navigationController pushViewController:R2VC animated:YES];
                                  
                                  
                              }];
    [alert addAction:btnEdit1];
    
    NSDictionary  *dict=_dictPost;
    NSString *PostUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([PostUserId isEqualToString:USERID]){
        UIAlertAction* btnEdit1 = [UIAlertAction actionWithTitle:@"Message List"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       RecentChatListViewController *R2VC = [[RecentChatListViewController alloc]initWithNibName:@"RecentChatListViewController" bundle:nil];
                                       R2VC.dictPost=_dictPost;
                                       R2VC.strFromMarketPlace=@"yes";
                                       [self.navigationController pushViewController:R2VC animated:YES];
                                       
                                       
                                   }];
        [alert addAction:btnEdit1];
    }else{
        UIAlertAction* btnEdit1 = [UIAlertAction actionWithTitle:@"Contact Event Admin"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       
                                       AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
                                       R2VC.dictChatData=_dictPost;
                                       [self.navigationController pushViewController:R2VC animated:YES];
                                       
                                   }];
        [alert addAction:btnEdit1];
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
    
    //
   
}
-(void)checkLayout{
    
    CGRect frame=self.tblInformation.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblInformation.frame=frame;
    
    frame=self.tblActivity.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblActivity.frame=frame;
    frame=self.tblActivity.frame;
    
    frame= _btnInformation.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btnInformation.frame=frame;
    
    frame= _btnActivity.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnActivity.frame=frame;
    
    frame=_SelectedTabanimation.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _SelectedTabanimation.frame=frame;
    [self addingAnimationToTable];

}

-(void)addingAnimationToTable{
    
        // CGRect frame                                   = CGRectMake(0, 0, SCREEN_SIZE.width, self.view.frame.size.height);
        // self.ScrollView                                = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollview.backgroundColor                = [UIColor clearColor];
    self.scrollview.pagingEnabled                  = YES;
    self.scrollview.showsHorizontalScrollIndicator = NO;
    self.scrollview.showsVerticalScrollIndicator   = NO;
    self.scrollview.delegate                       = self;
    self.scrollview.bounces                        = NO;
    
    
    float width                 = SCREEN_SIZE.width * 2;
    float height                = CGRectGetHeight(self.view.frame);
    float tobbarhig             = CGRectGetHeight(self.tblInformation.frame);
    float btnhig                = CGRectGetHeight(_tblInformation.frame);
    float selectedHig           = CGRectGetHeight(_SelectedTabanimation.frame);
    height                      = height-tobbarhig-btnhig-selectedHig;
    self.scrollview.contentSize = (CGSize){width, height};
    [self.scrollview setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark ---------- ScrollView delegate --------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView== self.scrollview){
        CGFloat percentage = scrollView.contentOffset.x / scrollView.contentSize.width;
        
        CGRect frame = _SelectedTabanimation.frame;
        frame.origin.x = (scrollView.contentOffset.x + percentage * SCREEN_SIZE.width)/3;
        _SelectedTabanimation.frame = frame;
    }
    
}

- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view cell:(UITableViewCell *)cell img:(AsyncImageView *)img
{
    CGRect rectInSuperview = [tableView convertRect:cell.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(cell.frame) - CGRectGetHeight(cell.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = img.frame;
    imageRect.origin.y = -(difference/2)+move;
    img.frame = imageRect;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(scrollView== self.scrollview){
        
        [self sendNewIndex:scrollView];
        
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self sendNewIndex:scrollView];
}

-(void)sendNewIndex:(UIScrollView *)scrollView{
    CGFloat xOffset = scrollView.contentOffset.x;
    if(scrollView== self.scrollview){
        if(xOffset>=320){
            _SelectedTabanimation.frame=CGRectMake(SCREEN_SIZE.width/2, _SelectedTabanimation.frame.origin.y, SCREEN_SIZE.width/2, 4);
        }else{
            _SelectedTabanimation.frame=CGRectMake(0, _SelectedTabanimation.frame.origin.y, SCREEN_SIZE.width/2, 4);
        }
    }
}

- (IBAction)cmdInformation:(id)sender {
     [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)cmdActivity:(id)sender {
     [self.scrollview setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
}


#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(_tblInformation ==tableView){
        return 1;
    }else{
        if(arryAllPost.count>0){
            return arryAllPost.count+1;
        }else{
            return 1;
        }
    }
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(_tblInformation ==tableView){
        return 491+[self getLabelHeight:[dictEventDetails objectForKey:@"discription"]]+55;
    }else{
        if(indexPath.row>=arryAllPost.count){
            return 50;
        }
        NSDictionary *dict=[arryAllPost objectAtIndex:indexPath.row];
        const char *jsonString = [[dict objectForKey:@"discription"] UTF8String];
        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        if(![[dict objectForKey:@"images"] isEqualToString:@""]){
            
            return SCREEN_SIZE.width-40+[self getLabelHeight:msg]+145;
            
        }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:msg]+145;
        }else if([[dict objectForKey:@"type"] isEqualToString:@"3"]){
            return   225+[self getLabelHeight:msg];
        }
        return  145+[self getLabelHeight:msg];
    }
    
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
       // cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    
    if(_tblInformation==tableView){
        
        NSArray *arr=[[_dictPost objectForKey:@"images"] componentsSeparatedByString:@","];
        NSArray *arrVideo=[[_dictPost objectForKey:@"video"] componentsSeparatedByString:@","];
        NSArray *arrvideothumb=[[_dictPost objectForKey:@"videothumb"] componentsSeparatedByString:@","];
        
        UIScrollView *scrollView=[[UIScrollView   alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        scrollView.pagingEnabled=YES;
        scrollView.showsVerticalScrollIndicator=NO;
        scrollView.showsHorizontalScrollIndicator=NO;
        int XAxix=0;
        NSString *VideoThumURLLenth=[_dictPost objectForKey:@"videothumb"];
        if(VideoThumURLLenth.length>3){
            for (int i=0; i<arrvideothumb.count; i++) {
                AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(XAxix, 0,SCREEN_SIZE.width,150)];
                banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                NSString *strVideoUrl=arrvideothumb[i];
                strVideoUrl=[strVideoUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%simages/",BASEURl] withString:@""];
                NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,strVideoUrl];
                NSURL *url = [NSURL URLWithString:strUrl];
                banner.imageURL=url;
                [scrollView addSubview:banner];
                
                MYTapGestureRecognizer *tap = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(PlayVideo:)];
                NSString *strUrlVideo=[NSString stringWithFormat:@"%svideos/%@",BASEURl,arrVideo[i]];
                tap.data=strUrlVideo;
                // tap.tagValue=[NSString stringWithFormat:@"%d",tagValue];;
                [banner addGestureRecognizer:tap];
                [banner setUserInteractionEnabled:YES];
                
                AsyncImageView *playicon=[[AsyncImageView alloc]initWithFrame:CGRectMake(XAxix+((SCREEN_SIZE.width/2)-16), 59,32,32)];
                playicon.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                playicon.image=[UIImage imageNamed:@"playIcon"];
                playicon.clipsToBounds=YES;
                [playicon setContentMode:UIViewContentModeScaleAspectFill];
                [scrollView addSubview:playicon];
                
                XAxix=XAxix+SCREEN_SIZE.width;
            }
        }
        
        
        
        for (int i=0; i<arr.count; i++) {
            AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(XAxix, 0,SCREEN_SIZE.width,150)];
            banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arr[i]];
            banner.imageURL=[NSURL URLWithString:strUrl];
            banner.clipsToBounds=YES;
            [banner setContentMode:UIViewContentModeScaleAspectFill];
            [scrollView addSubview:banner];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
            [banner addGestureRecognizer:tap];
            [banner setUserInteractionEnabled:YES];
            
            XAxix=XAxix+SCREEN_SIZE.width;
        }
        scrollView.contentSize = CGSizeMake(XAxix,110);
        [cell.contentView addSubview:scrollView];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 155,SCREEN_SIZE.width-32,20)];
        [title setFont:[UIFont boldSystemFontOfSize:14]];
        title.textAlignment=NSTextAlignmentLeft;
        title.numberOfLines=2;
        title.textColor=[UIColor blackColor];//userChatName
        title.text=[NSString stringWithFormat:@"%@",[dictEventDetails objectForKey:@"title"]];
        [cell.contentView addSubview:title];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(16, 175,SCREEN_SIZE.width-32,20)];
        [name setFont:[UIFont boldSystemFontOfSize:14]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.textColor=[UIColor blackColor];//userChatName
        name.text=[NSString stringWithFormat:@"By %@",[dictEventDetails objectForKey:@"user_name"]];
        [cell.contentView addSubview:name];
        
        UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(10, 200,SCREEN_SIZE.width-20 , 1)];
        sepUpView.backgroundColor=[UIColor darkGrayColor];
        sepUpView.alpha=0.4;
        [cell.contentView addSubview:sepUpView];
        
        UIButton *btnAttending=[[UIButton alloc]initWithFrame:CGRectMake(8, 201, SCREEN_SIZE.width/3-16, 40)];
        [btnAttending setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        [btnAttending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnAttending setTitle:[NSString stringWithFormat:@" %@",[dictEventDetails objectForKey:@"isAttendingCount"]] forState:UIControlStateNormal];
        btnAttending.tag=indexPath.row;
        [btnAttending addTarget:self action:@selector(cmdAttending:) forControlEvents:UIControlEventTouchUpInside];
        btnAttending.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:btnAttending];
        
        
        UIView *sepUpViewertical=[[UIView alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width/3-7, 200,1 , 81)];
        sepUpViewertical.backgroundColor=[UIColor darkGrayColor];
        sepUpViewertical.alpha=0.4;
        [cell.contentView addSubview:sepUpViewertical];
        
        
        UILabel *lblAttending = [[UILabel alloc] initWithFrame:CGRectMake(8, 241, SCREEN_SIZE.width/3-16, 40)];
        [lblAttending setFont:[UIFont boldSystemFontOfSize:14]];
        lblAttending.textAlignment=NSTextAlignmentCenter;
        lblAttending.numberOfLines=2;
        lblAttending.textColor=[UIColor blackColor];//userChatName
        lblAttending.text=[NSString stringWithFormat:@"ATTENDING"];
        [cell.contentView addSubview:lblAttending];
        
        
        UIButton *btnMatBe=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width/3-8, 201, SCREEN_SIZE.width/3-16, 40)];
        [btnMatBe setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        [btnMatBe setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnMatBe setTitle:[NSString stringWithFormat:@" %@",[dictEventDetails objectForKey:@"maybeAttendingCount"]] forState:UIControlStateNormal];
        btnMatBe.tag=indexPath.row;
        [btnMatBe addTarget:self action:@selector(cmdMaybe:) forControlEvents:UIControlEventTouchUpInside];
        btnMatBe.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:btnMatBe];
        
        UILabel *lblMatBe = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width/3-8, 241, SCREEN_SIZE.width/3-16, 40)];
        [lblMatBe setFont:[UIFont boldSystemFontOfSize:14]];
        lblMatBe.textAlignment=NSTextAlignmentCenter;
        lblMatBe.numberOfLines=2;
        lblMatBe.textColor=[UIColor blackColor];//userChatName
        lblMatBe.text=[NSString stringWithFormat:@"MAYBEE"];
        [cell.contentView addSubview:lblMatBe];
        
        
        UIView *sepUpViewertical1=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/3-7)*2, 200,1 , 81)];
        sepUpViewertical1.backgroundColor=[UIColor darkGrayColor];
        sepUpViewertical1.alpha=0.4;
        [cell.contentView addSubview:sepUpViewertical1];
        
        UIButton *btnNotAttending=[[UIButton alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/3-8)*2, 201, SCREEN_SIZE.width/3-16, 40)];
        [btnNotAttending setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        [btnNotAttending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnNotAttending setTitle:[NSString stringWithFormat:@" %@",[dictEventDetails objectForKey:@"notAttendingCount"]] forState:UIControlStateNormal];
        btnNotAttending.tag=indexPath.row;
        [btnNotAttending addTarget:self action:@selector(cmdNotAttending:) forControlEvents:UIControlEventTouchUpInside];
        btnNotAttending.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cell.contentView addSubview:btnNotAttending];
        
        UILabel *lblNotAttending= [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_SIZE.width/3-8)*2, 241, SCREEN_SIZE.width/3-16, 40)];
        [lblNotAttending setFont:[UIFont boldSystemFontOfSize:14]];
        lblNotAttending.textAlignment=NSTextAlignmentCenter;
        lblNotAttending.numberOfLines=2;
        lblNotAttending.textColor=[UIColor blackColor];//userChatName
        lblNotAttending.text=[NSString stringWithFormat:@"NOT ATTENDING"];
        [cell.contentView addSubview:lblNotAttending];
        
        
        NSString *isAttending=[NSString stringWithFormat:@"%@",[dictEventDetails objectForKey:@"isAttending"]];
        if([isAttending  isEqualToString:@"1"]){
            [btnAttending setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        }else if([isAttending  isEqualToString:@"2"]){
            [btnMatBe setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        }else if([isAttending  isEqualToString:@"3"]){
            [btnNotAttending setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];//Checkbox_Without Tick
        }
        UIView *sepUpView1=[[UIView alloc]initWithFrame:CGRectMake(10, 282,SCREEN_SIZE.width-20 , 1)];
        sepUpView1.backgroundColor=[UIColor darkGrayColor];
        sepUpView1.alpha=0.4;
        [cell.contentView addSubview:sepUpView1];
        
        AsyncImageView *clock=[[AsyncImageView alloc]initWithFrame:CGRectMake(10, 303,32,32)];
        clock.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        clock.image=[UIImage imageNamed:@"clock"];
        clock.clipsToBounds=YES;
        [clock setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:clock];
        
        
        NSString *strDate=[NSString stringWithFormat:@"%@",[dictEventDetails objectForKey:@"startDate"]];
        NSString *strEndDate=[NSString stringWithFormat:@"%@",[dictEventDetails objectForKey:@"endDate"]];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-mm-yyyy"];//EEE MMM dd HH:mm:ss z yyyy
        NSDate *date = [dateFormat dateFromString:strDate];
        NSDate *dateend = [dateFormat dateFromString:strEndDate];
        [dateFormat setDateFormat:@"EEE MMM dd yyyy"];
        NSString *strDatetoShowStartDate=[dateFormat stringFromDate:date];
        NSString *strDatetoShowEndDate=[dateFormat stringFromDate:dateend];
        
        UILabel *startTime = [[UILabel alloc] initWithFrame:CGRectMake(50, 295,SCREEN_SIZE.width-50,20)];
        [startTime setFont:[UIFont boldSystemFontOfSize:14]];
        startTime.textAlignment=NSTextAlignmentLeft;
        startTime.numberOfLines=2;
        startTime.textColor=[UIColor blackColor];//userChatName
        startTime.text=[NSString stringWithFormat:@"Start on %@ at %@",strDatetoShowStartDate,[dictEventDetails objectForKey:@"startTime"]];
        [cell.contentView addSubview:startTime];
        
        UILabel *EndTime = [[UILabel alloc] initWithFrame:CGRectMake(50, 325,SCREEN_SIZE.width-50,20)];
        [EndTime setFont:[UIFont boldSystemFontOfSize:14]];
        EndTime.textAlignment=NSTextAlignmentLeft;
        EndTime.numberOfLines=2;
        EndTime.textColor=[UIColor blackColor];//userChatName
        EndTime.text=[NSString stringWithFormat:@"End on %@ at %@",strDatetoShowEndDate,[dictEventDetails objectForKey:@"endTime"]];
        [cell.contentView addSubview:EndTime];
        
        UIView *sepUpView2=[[UIView alloc]initWithFrame:CGRectMake(10, 350,SCREEN_SIZE.width-20 , 1)];
        sepUpView2.backgroundColor=[UIColor darkGrayColor];
        sepUpView2.alpha=0.4;
        [cell.contentView addSubview:sepUpView2];
        
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(10, 351,SCREEN_SIZE.width-50,20)];
        [description setFont:[UIFont boldSystemFontOfSize:14]];
        description.textAlignment=NSTextAlignmentLeft;
        description.numberOfLines=2;
        description.textColor=[UIColor blackColor];//userChatName
        description.text=@"Description :";
        [cell.contentView addSubview:description];
        
        UILabel *descriptionValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 371,SCREEN_SIZE.width-50,[self getLabelHeight:[dictEventDetails objectForKey:@"discription"]])];
        [descriptionValue setFont:[UIFont systemFontOfSize:14]];
        descriptionValue.textAlignment=NSTextAlignmentLeft;
        descriptionValue.numberOfLines=2000;
        description.lineBreakMode=NSLineBreakByWordWrapping;
        descriptionValue.textColor=[UIColor blackColor];//userChatName
        descriptionValue.text=[dictEventDetails objectForKey:@"discription"];
        [cell.contentView addSubview:descriptionValue];
        
        
        AsyncImageView *imgLocation=[[AsyncImageView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(descriptionValue.frame)+5,SCREEN_SIZE.width-20,110)];
        imgLocation.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        
         NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dictEventDetails objectForKey:@"lat"],[dictEventDetails objectForKey:@"lon"],[dictEventDetails objectForKey:@"lat"],[dictEventDetails objectForKey:@"lon"]];
        
        imgLocation.imageURL=[NSURL URLWithString:strUrl];
        imgLocation.clipsToBounds=YES;
        [imgLocation setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:imgLocation];
        
        imgLocation.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        
        tapGesture1.numberOfTapsRequired = 1;
        
        [tapGesture1 setDelegate:self];
        
        [imgLocation addGestureRecognizer:tapGesture1];
        
        
        UIView *viewBottom=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imgLocation.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageShare=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageShare.image=[UIImage imageNamed:@"share-2"];
        imageShare.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom addSubview:imageShare];
        
        
        UILabel *lblShare=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblShare.text=@"Share";
        lblShare.textAlignment=NSTextAlignmentCenter;
        lblShare.font=[UIFont systemFontOfSize:12];
        [viewBottom addSubview:lblShare];
        
        [cell.contentView addSubview:viewBottom];
        
        
        
        UIView *viewBottom1=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width)/4, CGRectGetMaxY(imgLocation.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageView.image=[UIImage imageNamed:@"viewPost"];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom1 addSubview:imageView];
        
        
        UILabel *lblView=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblView.text=[NSString stringWithFormat:@"%@ Views",[_dictPost objectForKey:@"view_count"]];
        lblView.textAlignment=NSTextAlignmentCenter;
        lblView.font=[UIFont systemFontOfSize:12];
        [viewBottom1 addSubview:lblView];
        
        [cell.contentView addSubview:viewBottom1];
        
        
        UIView *viewBottom2=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*2, CGRectGetMaxY(imgLocation.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        
        UIImageView *imageComment=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageComment.image=[UIImage imageNamed:@"chat-comment"];
        imageComment.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom2 addSubview:imageComment];
        
        
        UILabel *lblComments=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblComments.text=[NSString stringWithFormat:@"%@ Comments",[_dictPost objectForKey:@"countcomments"]];
        lblComments.textAlignment=NSTextAlignmentCenter;
        lblComments.font=[UIFont systemFontOfSize:12];
        [viewBottom2 addSubview:lblComments];
        
        [cell.contentView addSubview:viewBottom2];
        
        UIView *viewBottom3=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*3, CGRectGetMaxY(imgLocation.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageLike=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        
        NSString *strLikeStatus=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likestatus"]];
        if([strLikeStatus isEqualToString:@"0"]){
            imageLike.image=[UIImage imageNamed:@"like11"];
        }else{
            imageLike.image=[UIImage imageNamed:@"like-1"];
        }
        imageLike.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom3 addSubview:imageLike];
        
        UILabel *lblLike=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        
        lblLike.text=[NSString stringWithFormat:@"%@ Likes",[_dictPost objectForKey:@"countLikes"]];
        lblLike.textAlignment=NSTextAlignmentCenter;
        lblLike.font=[UIFont systemFontOfSize:12];
        [viewBottom3 addSubview:lblLike];
        
        [cell.contentView addSubview:viewBottom3];
        
        
        
        MYTapGestureRecognizer *tapShare = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdShareAll:)];
        tapShare.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [viewBottom addGestureRecognizer:tapShare];
        [viewBottom setUserInteractionEnabled:YES];
        
        
        MYTapGestureRecognizer *tapComment = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdCommentAll:)];
        tapComment.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        [viewBottom2 addGestureRecognizer:tapComment];
        [viewBottom2 setUserInteractionEnabled:YES];
        
        
        MYTapGestureRecognizer *tapLike = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdLikeAll:)];
        tapLike.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        [viewBottom3 addGestureRecognizer:tapLike];
        [viewBottom3 setUserInteractionEnabled:YES];
        
    }else{
        NSDictionary *dict;
        
        if(indexPath.row>=arryAllPost.count){
            
            
            if (!self.noMoreResultsAvailAllPost && (arryAllPost && arryAllPost.count>0)) {
                cell.textLabel.text=nil;
                
                spinner.hidden=NO;
                spinner = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
                CGFloat width = 25;
                CGFloat height = 25;
                
                spinner.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, 12, width, height);
                [cell.contentView addSubview:spinner];
                
                if (indexPath.row>=arryAllPost.count) {
                    [spinner startAnimating];
                }
                
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
        
        dict=[arryAllPost objectAtIndex:indexPath.row];
        [cell.contentView addSubview: [self tblActivity:dict indexPath:indexPath]];
    }
    
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_tblActivity==tableView){
       return 50;
    }else{
      return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(_tblInformation==tableView){
        return nil;
    }
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
    
    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnLocation addTarget:self
                    action:@selector(cmdLocation:)
          forControlEvents:UIControlEventTouchUpInside];
    btnLocation.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [btnLocation setImage:[UIImage imageNamed:@"SendLocation"] forState:UIControlStateNormal];
    btnLocation.frame = CGRectMake((SCREEN_SIZE.width/3)*2+(SCREEN_SIZE.width/3)/2-20, 5, 40, 40);
    [hedderView addSubview:btnLocation];
    btnCamera.layer.cornerRadius=20;
    btnLocation.layer.cornerRadius=20;
    btnLocation.layer.borderWidth=1;
    btnLocation.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnCamera.layer.borderWidth=1;
    btnCamera.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnEdit.layer.borderWidth=1;
    btnEdit.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    hedderView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    return hedderView;
}
-(void)cmdEdit:(id)sender{
    AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
    R2VC.fromPage=@"EVENT";
    R2VC.dictFromPage=dictEventDetails;
    [self.navigationController pushViewController:R2VC animated:YES];
    
}
-(void)cmdLocation:(id)sender{
    CurrentLocationViewController *R2VC = [[CurrentLocationViewController alloc]initWithNibName:@"CurrentLocationViewController" bundle:nil];
    R2VC.strFromHome=@"2";
    R2VC.dictFromPage=dictEventDetails;
    [self.navigationController pushViewController:R2VC animated:YES];
}

-(void)cmdCamera:(id)sender{
    
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    imagePickerController.navigationBar.tintColor = [UIColor blackColor];
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
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
    R2VC.fromPage=@"EVENT";
    R2VC.dictFromPage=dictEventDetails;
    [self.navigationController pushViewController:R2VC animated:YES];
}
#pragma Mark dynamic height of textFeild
- (CGFloat)getLabelHeightInfo:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(SCREEN_SIZE.width-40, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
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
-(void)cmdAttending:(id)sender{
    NSMutableDictionary *temDict=[dictEventDetails mutableCopy];
    [temDict setValue:@"1" forKey:@"isAttending"];
    dictEventDetails=temDict;
    [_tblInformation reloadData];
    //mSocket.emit("changeEventAttending", user_id, event_id, 1)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"changeEventAttending" with:@[USERID,[_dictPost objectForKey:@"post_id"],@"1"]];
}
-(void)cmdMaybe:(id)sender{
    NSMutableDictionary *temDict=[dictEventDetails mutableCopy];
    [temDict setValue:@"2" forKey:@"isAttending"];
    dictEventDetails=temDict;
    [_tblInformation reloadData];
        //mSocket.emit("changeEventAttending", user_id, event_id, 1)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"changeEventAttending" with:@[USERID,[_dictPost objectForKey:@"post_id"],@"2"]];
}
-(void)cmdNotAttending:(id)sender{
    NSMutableDictionary *temDict=[dictEventDetails mutableCopy];
    [temDict setValue:@"3" forKey:@"isAttending"];
    dictEventDetails=temDict;
    [_tblInformation reloadData];
        //mSocket.emit("changeEventAttending", user_id, event_id, 1)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"changeEventAttending" with:@[USERID,[_dictPost objectForKey:@"post_id"],@"3"]];
}


-(UIView *)tblActivity:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 125+[self getLabelHeight:[dict objectForKey:@"discription"]])];
    viewDesign.backgroundColor=[UIColor clearColor];
   
    if(![[dict objectForKey:@"images"] isEqualToString:@""]){
        viewDesign.frame=CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+145);
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        viewDesign.frame=CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125);
    }else if([[dict objectForKey:@"type"] isEqualToString:@"3"]){
        viewDesign.frame=CGRectMake(0, 0, SCREEN_SIZE.width, 225+[self getLabelHeight:[dict objectForKey:@"discription"]]);
    }
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 20,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    banner.showActivityIndicator=YES;
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    //  baseUrl + "thumb/" + image_name
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    banner.layer.cornerRadius=25;
    banner.layer.borderWidth=1;
    banner.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [viewDesign addSubview:banner];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 20,SCREEN_SIZE.width-100,20)];
    [name setFont:[UIFont boldSystemFontOfSize:14]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.textColor=[UIColor blackColor];//userChatName
    
    NSString *taggedFriends=[dict objectForKey:@"taggedFriends"];
    
    NSArray *tagFrnd=[taggedFriends componentsSeparatedByString:@","];
    if(taggedFriends.length>3){
        [name setFont:[UIFont boldSystemFontOfSize:13]];
        if(tagFrnd.count==1){
            name.text=[NSString stringWithFormat:@"%@  with %@",[dict objectForKey:@"name"],tagFrnd[0]];
        }else if (tagFrnd.count==2){
            name.text=[NSString stringWithFormat:@"%@  with %@ and %@",[dict objectForKey:@"name"],tagFrnd[0],tagFrnd[1]];
        }else{
            int count=tagFrnd.count;
            count=count-1;
            name.text=[NSString stringWithFormat:@"%@ with %@ and %d other",[dict objectForKey:@"name"],tagFrnd[0],count];
        }
        
    }else{
        name.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    }
    
    
    [viewDesign addSubview:name];
    
    UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
    [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
    btnMore.tag=indexPath.row;
    
    
        [btnMore addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
        
 
    [viewDesign addSubview:btnMore];
    
    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
    NSString *strDatetoShow=[dateFormat stringFromDate:date];
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(75, 40,SCREEN_SIZE.width-110,20)];
    [time setFont:[UIFont systemFontOfSize:12]];
    time.textAlignment=NSTextAlignmentLeft;
    time.numberOfLines=2;
    time.textColor=[UIColor darkGrayColor];
    time.text=strDatetoShow;
    time.alpha=0.6;
    [viewDesign addSubview:time];
    
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
    
    UITextView *status=[[UITextView alloc] initWithFrame:CGRectMake(20, 80,SCREEN_SIZE.width-40,[self getLabelHeight:msg])];
    [status setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    status.textColor=[UIColor blackColor];
    status.text=msg;
    status.editable=NO;
    status.backgroundColor=[UIColor clearColor];
    status.scrollEnabled=NO;
    status.textContainerInset = UIEdgeInsetsZero;
    status.dataDetectorTypes=UIDataDetectorTypeAll;
    [viewDesign addSubview:status];
    
    UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];//[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
    
    btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:msg], 50, 32);
    [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
    //    countLikes = 4;
    //    countcomments = 2;
    //view_count
    [btnLike setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countLikes"]] forState:UIControlStateNormal];
    [viewDesign addSubview:btnLike];
    
    
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];
        
   
    btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLike.layer.cornerRadius=10;//0,160,223
    btnLike.layer.borderWidth=1;
    btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likestatus"]];
    if([strLikestatus isEqualToString:@"0"]){
        btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }else{
        btnLike.tintColor = [UIColor whiteColor];//
        [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
    
    btnLike.tag=indexPath.row;
    
    
    
    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 85+[self getLabelHeight:msg], 50, 32)];
    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countcomments"]] forState:UIControlStateNormal];
    
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllPost:)
             forControlEvents:UIControlEventTouchUpInside];
        
   
    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnComment.layer.cornerRadius=10;//0,160,223
    btnComment.layer.borderWidth=1;
    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnComment.tag=indexPath.row;
    
    [viewDesign addSubview:btnComment];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:msg], 50, 32)];
    [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
   
        [btnShare addTarget:self
                     action:@selector(cmdShareAllPost:)
           forControlEvents:UIControlEventTouchUpInside];
        
  
    
    btnShare.tag=indexPath.row;
    btnShare.layer.cornerRadius=10;//0,160,223
    btnShare.layer.borderWidth=1;
    btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [viewDesign addSubview:btnShare];
    
    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 85+[self getLabelHeight:msg], 50, 32)];
    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
    
    
        //        [btnView addTarget:self
        //                    action:@selector(cmdShareAllPost:)
        //          forControlEvents:UIControlEventTouchUpInside];
    
    
    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
    btnView.layer.cornerRadius=10;//0,160,223
    btnView.layer.borderWidth=1;
    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnView.tag=indexPath.row;
    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [viewDesign addSubview:btnView];
    UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1)];
    sepUpView.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    //sepUpView.alpha=0.4;
    [viewDesign addSubview:sepUpView];
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){
        
        UIView *viewImage=[[UIView alloc]initWithFrame:CGRectMake(0, [self getLabelHeight:msg]+80,SCREEN_SIZE.width,SCREEN_SIZE.width-40)];
        
        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:msg]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost.showActivityIndicator=YES;
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
        bannerPost.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost.clipsToBounds=YES;
        bannerPost.layer.cornerRadius=10;
        //[cell.contentView addSubview:bannerPost];
        bannerPost.userInteractionEnabled=YES;
        
        NSString *strImageList=[dict objectForKey:@"images"];
        NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
        
        viewImage =  [self addImageView:arryImageList view:viewImage];
        viewImage.tag=indexPath.row;
        [viewDesign addSubview:viewImage];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        [viewImage addGestureRecognizer:tap];
        [viewImage setUserInteractionEnabled:YES];
        
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);
        
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        
        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:msg]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost.showActivityIndicator=YES;
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dict objectForKey:@"lat"],[dict objectForKey:@"lon"],[dict objectForKey:@"lat"],[dict objectForKey:@"lon"]];
        bannerPost.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost.clipsToBounds=YES;
        bannerPost.layer.cornerRadius=10;
        [viewDesign addSubview:bannerPost];
        bannerPost.userInteractionEnabled=YES;
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);
    }else if([[dict objectForKey:@"type"] isEqualToString:@"3"]){
        
        [MTDURLPreview loadPreviewWithURL:[NSURL URLWithString:[dict objectForKey:@"link"]] completion:^(MTDURLPreview *preview, NSError *error) {
            //preview.imageURL
            NSLog(@"Image Url %@",preview.imageURL);
            NSLog(@"Image Url %@",preview.title);
            NSLog(@"Image Url %@",preview.domain);
            NSLog(@"Image Url %@",preview.content);
            
            
            UIView *subView=[[UIView alloc]initWithFrame:CGRectMake(10, [self getLabelHeight:msg]+80, SCREEN_SIZE.width-20, 80)];
            [subView.layer setShadowColor:[UIColor blackColor].CGColor];
            [subView.layer setShadowOpacity:0.3];
            [subView.layer setShadowRadius:3.0];
            [subView.layer setShadowOffset:CGSizeMake(1, 1)];
            subView.backgroundColor=[UIColor whiteColor];
            
            AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 15,50,50)];
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            bannerPost.showActivityIndicator=YES;
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            bannerPost.imageURL=preview.imageURL;
            [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
            bannerPost.clipsToBounds=YES;
            bannerPost.layer.cornerRadius=0;
            [subView addSubview:bannerPost];
            
            UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(75, 10,subView.frame.size.width-80,40)];
            [lblDescription setFont:[UIFont boldSystemFontOfSize:12]];
            lblDescription.textAlignment=NSTextAlignmentLeft;
            lblDescription.numberOfLines=5;
            lblDescription.lineBreakMode=NSLineBreakByWordWrapping;
            lblDescription.textColor=[UIColor blackColor];
            lblDescription.text=[NSString stringWithFormat:@"%@:%@",preview.title,preview.content];
            [subView addSubview:lblDescription];
            
            UILabel *lblDomein = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(lblDescription.frame),subView.frame.size.width-80,20)];
            [lblDomein setFont:[UIFont boldSystemFontOfSize:12]];
            lblDomein.textAlignment=NSTextAlignmentLeft;
            lblDomein.numberOfLines=5;
            lblDomein.lineBreakMode=NSLineBreakByWordWrapping;
            lblDomein.textColor=[UIColor blackColor];
            lblDomein.text=[NSString stringWithFormat:@"%@",preview.domain];
            [subView addSubview:lblDomein];
            
            [viewDesign addSubview:subView];
            btnLike.frame=CGRectMake(SCREEN_SIZE.width-58,  CGRectGetMaxY(subView.frame)+5, 50, 32);
            btnComment.frame=CGRectMake(SCREEN_SIZE.width-116,  CGRectGetMaxY(subView.frame)+5, 50, 32);
            btnShare.frame=CGRectMake(20,  CGRectGetMaxY(subView.frame)+5, 50, 32);
            btnView.frame=CGRectMake(SCREEN_SIZE.width-174, CGRectGetMaxY(subView.frame)+5, 50, 32);
            
            sepUpView.frame=CGRectMake(0, btnComment.frame.origin.y+45,SCREEN_SIZE.width , 1);
        }];
    }
    
    
    return viewDesign;
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
        [AlertView showAlertWithMessage:@"You don't have permission to delete  or edit this post." view:self];
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
                                }];
    
    UIAlertAction* btnSharewithFrnd = [UIAlertAction
                                       actionWithTitle:@"Share with Friends"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                                           [AlertView showAlertWithMessage:@"Comming soon." view:self];
                                       }];
    
    UIAlertAction* btnSharewithOtherApp = [UIAlertAction
                                           actionWithTitle:@"Share on other app"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                               [self performSelector:@selector(shareWithOtherApp:) withObject:dict afterDelay:1];
                                           }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:btnSharewithFrnd];
    [alert addAction:btnSharewithOtherApp];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)shareWithOtherApp:(NSDictionary *)dict{
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSString *strTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
    NSArray *Items;
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){
        
        Items  = [NSArray arrayWithObjects:
                  strTitle,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                  @"Via iBlah-Blah", nil];
        
        
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dict objectForKey:@"lat"],[dict objectForKey:@"lon"],[dict objectForKey:@"lat"],[dict objectForKey:@"lon"]];
        Items  = [NSArray arrayWithObjects:
                  strTitle,strUrl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                  @"Via iBlah-Blah", nil];
    }
    
    
    
    
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

- (void)bigButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    UIView *view=(UIView *)tapRecognizer.view;
    
    NSDictionary  *dict=[arryAllPost objectAtIndex:view.tag];
    
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
    [self.tblActivity reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    
    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
    NSMutableArray *arryimglink=[[NSMutableArray  alloc]init];
    for (int i=0; i<arryImageList.count; i++) {
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImageList[i]];
        NSURL *url=[NSURL URLWithString:strUrl];
        [arryimglink addObject:url];
    }
    self.imgURLs=arryimglink;
    //    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
    //    imageVC.startingIndex = 0;
    //    [self presentViewController:imageVC animated:YES completion:nil];
    AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
    R2VC.dictPost=dict;
    [self.navigationController pushViewController:R2VC animated:YES];
}

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
    [self.tblActivity reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
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
    [self.tblActivity reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    cont.dictPost=dict;
  //  [self.navigationController presentViewController:cont animated:YES completion:nil];
    [self.navigationController pushViewController:cont animated:YES];
}



-(UIView *)addImageView:(NSArray *)arryImage view:(UIView *)view{
    
    if(arryImage.count==5 || arryImage.count>5){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
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
            
        }
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/3, view.frame.size.width/2-1, view.frame.size.height/3-1)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost5=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, (view.frame.size.height/3)*2, view.frame.size.width/2, view.frame.size.height/3)];
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost5.showActivityIndicator=YES;
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[4]];
        bannerPost5.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost5 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost5.clipsToBounds=YES;
        [view addSubview:bannerPost5];
        bannerPost5.userInteractionEnabled=YES;
        
        
        
    }else if(arryImage.count==4){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2-1, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/2-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        bannerPost3.userInteractionEnabled=YES;
        
        
    }else if(arryImage.count==3){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, (view.frame.size.width/3)*2, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, view.frame.size.height/2,(view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, 0, (view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        
        
        
    }else if(arryImage.count==2){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2,0 , view.frame.size.width/2, view.frame.size.height)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
    }else if(arryImage.count==1){
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
    }
    
    return view;
}

- (void)cmdShareAll:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    NSLog(@"data : %@", tap.data);
    NSLog(@"data : %@", tap.tagValue);
    
    
    NSDictionary *dict=_dictPost;
    
        //    NSString *strOtheruserID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"location"]];
    

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
        //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Share with Contacts"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        //mSocket.emit("sharePost", user_id, post_id, title,  discription,  posttype, lat, lon,"", postimages, "", type, location, other_user_id
                                    InvitePeopleViewController *cont=[[InvitePeopleViewController alloc]initWithNibName:@"InvitePeopleViewController" bundle:nil];
                                    [self.navigationController pushViewController:cont animated:YES];
                                }];
    
    
    UIAlertAction* btnSharewithOtherApp = [UIAlertAction
                                           actionWithTitle:@"Share on other app"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                                   //Handle no, thanks button
                                               [self performSelector:@selector(shareWithOtherApp1:) withObject:dict afterDelay:1];
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



-(void)shareWithOtherApp1:(NSDictionary *)dict{
        //    IndecatorView *ind=[[IndecatorView alloc]init];
        //    [self.view addSubview:ind];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSString *strTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
    NSArray *Items;
    
    NSString *strLink = [NSString stringWithFormat:@"Check this awesome event on iBlahBlah\nhttps://www.iblah-blah.com/iblah/event.php?key=%@",[dict objectForKey:@"post_id"]];
    Items  = [NSArray arrayWithObjects:
              strTitle,image,strLink,
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


- (void)cmdCommentAll:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    NSLog(@"data : %@", tap.data);
    NSLog(@"data : %@", tap.tagValue);
    
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *dict=_dictPost;
    
    
    
    CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    cont.dictPost=dict;
        //  [self.navigationController presentViewController:cont animated:YES completion:nil];
    [self.navigationController pushViewController:cont animated:YES];
    
    
}
- (void)cmdLikeAll:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    NSLog(@"data : %@", tap.data);
    NSLog(@"data : %@", tap.tagValue);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSDictionary *dict=_dictPost;
    
    
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likestatus"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
    NSString *strViewCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    if([strLikestatus isEqualToString:@"0"]){
        
        [appDelegate().socket emit:@"likeApost" with:@[USERID,strPost_id,@"0"]];
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"countLikes"];
        [dictNew setValue:@"1" forKey:@"likestatus"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        if([tap.data isEqualToString:@"0"]){
            
            
            _dictPost=dictNew;
            
        }else{
            _dictPost=dictNew;
        }
        
        
    }else{
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,strPost_id,@"0"]];
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"countLikes"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [dictNew setValue:@"0" forKey:@"likestatus"];
        if([tap.data isEqualToString:@"0"]){
            
            _dictPost=dictNew;
        }else{
             _dictPost=dictNew;
        }
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tap.tagValue integerValue] inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    if([tap.data isEqualToString:@"0"]){
        
        [self.tblInformation reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self.tblInformation reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
       
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RefreshEvent"
     object:self userInfo:nil];
    
}

- (void) tapGesture: (id)sender
{
    ShowLocationViewController *cont=[[ShowLocationViewController alloc]initWithNibName:@"ShowLocationViewController" bundle:nil];
    cont.dict=dictEventDetails;
    [self.navigationController pushViewController:cont animated:YES];
}
- (void)PlayVideo:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    NSLog(@"data : %@", tap.data);
    NSURL *videoURL = [NSURL URLWithString:tap.data];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
    
}


-(void)playVideo:(NSString *)strUrl videoId:(NSString *)videoId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",videoId]];
    [appDelegate().socket emit:@"addToVideoHistory" with:@[USERID,videoId]];
    //   mSocket.emit("addToVideoHistory", user_id, id);
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
   
    [self performSelector:@selector(getVideoHistory) withObject:nil afterDelay:5.0];
}
@end

    //
    //  ProileViewController.m
    //  iBlah-Blah
    //
    //  Created by webHex on 10/05/18.
    //  Copyright © 2018 webHax. All rights reserved.
    //

#import "ProileViewController.h"
#import "AllImagesViewController.h"
#import "EditPostViewController.h"
#import "CommentViewController.h"
#import "AGChatViewController.h"
@interface ProileViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    
    NSString *totalAllImages;
    NSString  *currentAllImages;
    
    DGActivityIndicatorView *spinner;
    
    NSMutableArray *arryAllPost;
    NSMutableArray *arryAllImages;
    NSMutableArray *arryAllImages1;
    NSArray *arryFrnd;
    NSDictionary *userInfoValue;
    IndecatorView *ind;
    
}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;

@property (nonatomic) BOOL noMoreResultsAvailImages;
@property (nonatomic) BOOL loadingAllImages;

@end

@implementation ProileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
    [self checkLayout];
    
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    currentAllPostPage=@"0";
    currentAllImages=@"0";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"USERINFO"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UserActivity"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UserAllImages"
                                               object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllDetailOfUser" with:@[USERID,[_dictData objectForKey:@"user_id"]]];
    [appDelegate().socket emit:@"getAllPostofUser" with:@[USERID,[_dictData objectForKey:@"user_id"],currentAllPostPage]];
    [appDelegate().socket emit:@"showAllUserImages" with:@[USERID,[_dictData objectForKey:@"user_id"],currentAllImages]];
        //mSocket.emit("showAllUserImages", user_id, friends_id);
    
    
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"USERINFO"]) {
        
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        NSData *objectData1 = [[Arr objectAtIndex:2] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json1 = [NSJSONSerialization JSONObjectWithData:objectData1
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
        NSData *objectData2 = [[Arr objectAtIndex:3] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json2 = [NSJSONSerialization JSONObjectWithData:objectData2
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
        
        userInfoValue=[json objectAtIndex:0];

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        if(![USERID isEqualToString:[userInfoValue objectForKey:@"user_id"]])
        {
        NSString *strISfriend=[NSString stringWithFormat:@"%@",[userInfoValue objectForKey:@"isFriends"]];
        
        NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
        UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnClear.frame = CGRectMake(0, 0, 32, 32);
        if(!([strISfriend isEqualToString:@"0"])){
            [btnClear setTitle:@"Send Msg" forState:UIControlStateNormal];
            [btnClear addTarget:self action:@selector(cmdSendMsg1:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if([[userInfoValue objectForKey:@"pendingRequest"] intValue] == 0)
            {
                [btnClear setTitle:@"Add Friend" forState:UIControlStateNormal];
                [btnClear addTarget:self action:@selector(cmdAddFrnd:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                [btnClear setTitle:@"Pending Request" forState:UIControlStateNormal];
            }
        }
        arryAllImages1=[json2 mutableCopy];
        UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
        [arrRightBarItems addObject:btnSearchBar];
        self.navigationItem.rightBarButtonItems=arrRightBarItems;
        }
        arryFrnd=json1;
        
        [_tblAbout reloadData];
        [_tblFriends reloadData];
        [_tblActivity reloadData];
        NSLog(@"heloo %@",json);
    }else if ([[notification name] isEqualToString:@"UserActivity"]) {
        NSDictionary* userInfo = notification.userInfo;
        [ind removeFromSuperview];
        if([currentAllPostPage isEqualToString:@"0"]){
            
            NSArray *Arr=[userInfo objectForKey:@"DATA"];
            if ([Arr objectAtIndex:1] == [NSNull null]) {
                return;
            }
            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
                //NSDictionary *dict=json;
            arryAllPost=[json mutableCopy];//[[dict objectForKey:@"posts"] mutableCopy];
            if(Arr.count>2){
                totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            
            [_tblActivity reloadData];
        }else{
            self.loadingAllPost=NO;
            
            NSArray *Arr=[userInfo objectForKey:@"DATA"];
                //NSDictionary *dict=[Arr objectAtIndex:1];
            if ([Arr objectAtIndex:1] == [NSNull null]) {
                return;
            }
            
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
            if(Arr.count>2){
                totalAllPostPage =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            
            
            [_tblActivity reloadData];
        }
    } else if ([[notification name] isEqualToString:@"UserAllImages"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        [ind removeFromSuperview];
        if([currentAllImages isEqualToString:@"0"]){
            
            NSArray *Arr=[userInfo objectForKey:@"DATA"];
            if ([Arr objectAtIndex:1] == [NSNull null]) {
                return;
            }
            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
                //NSDictionary *dict=json;
            arryAllImages=[json mutableCopy];//[[dict objectForKey:@"posts"] mutableCopy];
            if(Arr.count>2){
                totalAllImages =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            
            [_tblPhotos reloadData];
        }else{
            self.loadingAllImages=NO;
            
            NSArray *Arr=[userInfo objectForKey:@"DATA"];
                //NSDictionary *dict=[Arr objectAtIndex:1];
            if ([Arr objectAtIndex:1] == [NSNull null]) {
                return;
            }
            
            NSError *jsonError;
            NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
            
            int countAllPost=[totalAllPostPage intValue];
            int currentPageAll=[currentAllPostPage intValue];
            
            if(arryAllImages1.count>0){
                NSDictionary *dict1=[arryAllImages1 objectAtIndex:0];
                NSString *StrTotalCount =  [NSString stringWithFormat:@"%@",[dict1 objectForKey:@"image_count"]];
                if(!(arryAllImages.count>=[StrTotalCount integerValue])){
                    [arryAllImages addObjectsFromArray:[json mutableCopy]];
                }
            }else{
                if(currentAllImages==0){
                    arryAllImages=[json mutableCopy];
                }else{
                    [arryAllImages addObjectsFromArray:[json mutableCopy]];
                }
            }
            
            
            
            if(Arr.count>2){
                totalAllImages =[NSString stringWithFormat:@"%@",[Arr objectAtIndex:2]];
            }
            
            
            [_tblPhotos reloadData];
        
    }
    }
}
-(void)cmdSendMsg1:(id)sender{
    NSLog(@"_dict Data%@",_dictData);
        //  UIButton *btn=(UIButton *)sender;
    AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
    R2VC.dictChatData=userInfoValue;
    [self.navigationController pushViewController:R2VC animated:YES];
    
}
-(void)cmdSendRequest:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryFrnd objectAtIndex:btn.tag];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *profile_pic = [prefs stringForKey:@"profile_pic"];
    NSString *username = [prefs stringForKey:@"username"];
    [appDelegate().socket emit:@"sendFriendRequest" with:@[USERID,[dict objectForKey:@"user_id"],username,profile_pic]];
        // mSocket.emit("sendFriendRequest", user_id,  friend_id, user_name, user_image);
    [AlertView showAlertWithMessage:@"Friend request sent sucssfully." view:self];
}

-(void)cmdSendMsg:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryFrnd objectAtIndex:btn.tag];
    AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
    R2VC.dictChatData=dict;
    [self.navigationController pushViewController:R2VC animated:YES];
    
}
-(void)cmdAddFrnd:(UIButton *)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *profile_pic = [prefs stringForKey:@"profile_pic"];
    NSString *username = [prefs stringForKey:@"username"];
    [appDelegate().socket emit:@"sendFriendRequest" with:@[USERID,[_dictData objectForKey:@"user_id"],username,profile_pic]];
    [AlertView showAlertWithMessage:@"Friend request sent sucssfully." view:self];
    sender.enabled = false;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
-(void)checkLayout{
    
    
    CGRect frame=self.tblActivity.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblActivity.frame=frame;
    
    frame=self.tblAbout.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblAbout.frame=frame;
    frame=self.tblAbout.frame;
    
    frame=self.tblFriends.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*2;
    self.tblFriends.frame=frame;
    frame=self.tblFriends.frame;
    
    frame=self.tblPhotos.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*3;
    self.tblPhotos.frame=frame;
    frame=self.tblPhotos.frame;
    
    frame= _btnActivity.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    _btnActivity.frame=frame;
    
    frame= _btnAbout.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    frame.origin.x=SCREEN_SIZE.width/4;
    _btnAbout.frame=frame;
    
    frame= _btnFriends.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnFriends.frame=frame;
    
    frame= _btnPhotos.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    frame.origin.x=(SCREEN_SIZE.width/4)*3;
    _btnPhotos.frame=frame;
    
    
    
    frame=_viewAnimation.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    _viewAnimation.frame=frame;
    
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
    
    
    float width                 = (SCREEN_SIZE.width/2);
    float height                = 40;
    self.scrollViewBtn.contentSize = (CGSize){width, height};
    [self.scrollViewBtn setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.scrollViewTable.backgroundColor                = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.scrollViewTable.pagingEnabled                  = YES;
    self.scrollViewTable.showsHorizontalScrollIndicator = NO;
    self.scrollViewTable.showsVerticalScrollIndicator   = NO;
    self.scrollViewTable.delegate                       = self;
    self.scrollViewTable.bounces                        = NO;
    
    
    float width1                 = SCREEN_SIZE.width * 4;
    float height1                = CGRectGetHeight(self.view.frame);
    float tobbarhig1            = CGRectGetHeight(self.tblActivity.frame);
    float btnhig1                = CGRectGetHeight(_tblActivity.frame);
        //float selectedHig1           = CGRectGetHeight(_SelectedTabanimation.frame);
    height1                      = height1-tobbarhig1-btnhig1;
    self.scrollViewTable.contentSize = (CGSize){width1, height1};
    [self.scrollViewTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
}

#pragma mark ---------- ScrollView delegate --------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView== self.scrollViewTable){
        
        CGFloat percentage = (scrollView.contentOffset.x / scrollView.contentSize.width);
        CGRect frame = _viewAnimation.frame;
        frame.origin.x = (scrollView.contentOffset.x + percentage * SCREEN_SIZE.width)/5;
        _viewAnimation.frame = frame;
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if(scrollView== self.scrollViewTable){
        [self sendNewIndex:scrollView];
    }else if (scrollView == self.scrollViewBtn){
        
    }else{
        if (scrollView == _tblActivity){
            if (!self.loadingAllPost) {
                
                float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
                if (endScrolling >= scrollView.contentSize.height)
                {
                    self.loadingAllPost=YES;
                    int countAllPost=[totalAllPostPage intValue];
                    int currentPageAll=[currentAllPostPage intValue];
                    if(currentPageAll<countAllPost-1){
                        currentPageAll++;
                        
                        currentAllPostPage=[NSString stringWithFormat:@"%d",currentPageAll];
                        [appDelegate().socket emit:@"getAllPostofUser" with:@[USERID,[_dictData objectForKey:@"user_id"],currentAllPostPage]];
                            // [appDelegate().socket emit:@"getAllEventsGroups" with:@[USERID,@"",currentAllPostPage]];
                        
                    }else{
                        self.loadingAllPost=NO;
                        self.noMoreResultsAvailAllPost=YES;
                        [self.tblActivity reloadData];
                            //  [self.tblFrnd reloadData];
                    }
                }
            }
        }else if (scrollView == _tblPhotos){
            if (!self.loadingAllImages) {
                
                float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
                if (endScrolling >= scrollView.contentSize.height)
                {
                    self.loadingAllImages=YES;
                    int countAllPost=[totalAllImages intValue];
                    int currentPageAll=[currentAllImages intValue];
                    if(arryAllImages1.count>0){
                        currentPageAll++;
                        NSDictionary *dict1=[arryAllImages1 objectAtIndex:0];
                        NSString *StrTotalCount =  [NSString stringWithFormat:@"%@",[dict1 objectForKey:@"image_count"]];
                        if(!(arryAllImages.count>=[StrTotalCount integerValue])){
                            currentAllImages=[NSString stringWithFormat:@"%d",currentPageAll];
                            [appDelegate().socket emit:@"showAllUserImages" with:@[USERID,[_dictData objectForKey:@"user_id"],currentAllImages]];
                        }
                       
                    }else{
                        self.loadingAllImages=NO;
                        self.noMoreResultsAvailImages=YES;
                        [self.tblPhotos reloadData];
                            //  [self.tblFrnd reloadData];
                    }
                  
                    
                }
            }
        }
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
                // [self changeButtonColor];
                // [_btnActivity setBackgroundColor:[UIColor whiteColor]];
                //[_btnActivity setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            _viewAnimation.frame=CGRectMake(SCREEN_SIZE.width/4, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else if (xOffset>=SCREEN_SIZE.width*2 && xOffset<SCREEN_SIZE.width*3){
            
                // [self changeButtonColor];
                //[_btnEvents setBackgroundColor:[UIColor whiteColor]];
                //  [_btnEvents setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            _viewAnimation.frame=CGRectMake((SCREEN_SIZE.width/4)*2, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else if (xOffset>=SCREEN_SIZE.width*3 && xOffset<SCREEN_SIZE.width*4){
                // [self changeButtonColor];
                // [_btnPhotos setBackgroundColor:[UIColor whiteColor]];
                //  [_btnPhotos setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
            _viewAnimation.frame=CGRectMake((SCREEN_SIZE.width/4)*3, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else{
                // [self changeButtonColor];
            
            _viewAnimation.frame=CGRectMake(0, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
                //  [_btnInformation setBackgroundColor:[UIColor whiteColor]];
                //  [_btnInformation setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
                // [self.scrollViewBtn setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}
-(void)changeButtonColor{
    [_btnActivity setBackgroundColor:[UIColor clearColor]];
    [_btnActivity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnAbout  setBackgroundColor:[UIColor clearColor]];
    [_btnAbout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnFriends setBackgroundColor:[UIColor clearColor]];
    [_btnFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnPhotos setBackgroundColor:[UIColor clearColor]];
    [_btnPhotos setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (IBAction)cmdActivity:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (IBAction)cmdAbout:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
    
}

- (IBAction)cmdFriends:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*2, 0) animated:YES];
}

- (IBAction)cmdPhotos:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*3, 0) animated:YES];
}


#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    
    if(tableView==_tblAbout){
        return 1;
    }else if (tableView==_tblActivity){
        return 1;
    }else if (_tblFriends==tableView){
        return 1;
    }else if(_tblPhotos == tableView){
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView==_tblAbout){
        if(section==0){
            return 1;
        }else{
            return 1;
        }
        return 1;
    }else if (tableView==_tblActivity){
        if(arryAllPost){
            return arryAllPost.count+2;
        }else{
            return 1;
        }
    }else if (_tblFriends==tableView){
        if(arryFrnd.count==0){
            return 1;
        }
        
        int count=arryFrnd.count%2;
        long coutCheck=arryFrnd.count/2;
        if(count==1){
            return coutCheck+2;
        }else{
            return coutCheck+1;
        }
    }else if(_tblPhotos == tableView){
        if(arryAllImages.count==0){
            return 1;
        }
        
        int count=arryAllImages.count%2;
        long coutCheck=arryAllImages.count/2;
        if(count==1){
            return coutCheck+2;
        }else{
            return coutCheck+1;
        }
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if(tableView==_tblAbout){
        if(indexPath.section==0){
            return 212;
        }else{
            return 90;
        }
        return 1;
    }else if (tableView==_tblActivity){
        if(indexPath.row>=arryAllPost.count+1){
            return 50;
        }
        if(indexPath.row==0){
            return 230;
        }
        NSDictionary *dict=[arryAllPost objectAtIndex:indexPath.row-1];
        
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
        
    }else if (_tblFriends==tableView){
        return 230;
    }else if(_tblPhotos == tableView){
        return SCREEN_SIZE.width/2+32;
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
            //
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    
    
    if(tableView ==_tblAbout){
        
        if(indexPath.section==0){
            AsyncImageView *imgGroupImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(16, 8,60,60)];
            imgGroupImage.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[userInfoValue objectForKey:@"image"]];
            [imgGroupImage sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
//            imgGroupImage.imageURL=[NSURL URLWithString:strUrl];
            imgGroupImage.clipsToBounds=YES;
            [imgGroupImage setContentMode:UIViewContentModeScaleAspectFill];
            imgGroupImage.layer.cornerRadius=8;
            imgGroupImage.layer.borderWidth=1;
            imgGroupImage.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
            [cell.contentView addSubview:imgGroupImage];
            
            UILabel *lblGroupName = [[UILabel alloc] initWithFrame:CGRectMake(80, 8,SCREEN_SIZE.width-120,20)];
            [lblGroupName setFont:[UIFont boldSystemFontOfSize:16]];
            lblGroupName.textAlignment=NSTextAlignmentLeft;
            lblGroupName.numberOfLines=2;
            lblGroupName.textColor=[UIColor blackColor];//userChatName
            lblGroupName.text=[NSString stringWithFormat:@"%@",[userInfoValue objectForKey:@"name"]];
            [cell.contentView addSubview:lblGroupName];
            
            UILabel *lblGroupName1 = [[UILabel alloc] initWithFrame:CGRectMake(80, 30,SCREEN_SIZE.width-120,20)];
            [lblGroupName1 setFont:[UIFont boldSystemFontOfSize:16]];
            lblGroupName1.textAlignment=NSTextAlignmentLeft;
            lblGroupName1.numberOfLines=2;
            lblGroupName1.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];//userChatName
            lblGroupName1.text=[NSString stringWithFormat:@"%@",[userInfoValue objectForKey:@"dob"]];
            [cell.contentView addSubview:lblGroupName1];
            
            
            UILabel *lblGroupName2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70,SCREEN_SIZE.width,20)];
            [lblGroupName2 setFont:[UIFont boldSystemFontOfSize:16]];
            lblGroupName2.textAlignment=NSTextAlignmentLeft;
            lblGroupName2.numberOfLines=2;
            lblGroupName2.textColor=[UIColor blackColor];//userChatName
            lblGroupName2.backgroundColor=[UIColor lightGrayColor];
            lblGroupName2.text=[NSString stringWithFormat:@"      About Me"];
            [cell.contentView addSubview:lblGroupName2];
            
            UILabel *lblGroupName3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100,SCREEN_SIZE.width,20)];
            [lblGroupName3 setFont:[UIFont boldSystemFontOfSize:16]];
            lblGroupName3.textAlignment=NSTextAlignmentLeft;
            lblGroupName3.numberOfLines=2;
            lblGroupName3.textColor=[UIColor blackColor];//userChatName
            lblGroupName3.backgroundColor=[UIColor lightGrayColor];
            lblGroupName3.text=[NSString stringWithFormat:@"      Contact Info"];
            [cell.contentView addSubview:lblGroupName3];
            
            
        }else{
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }else if (tableView==_tblActivity){
        NSDictionary *dict;
        
        if(indexPath.row>=arryAllPost.count+1){
                //            if(indexPath.row==0){
                //                [cell.contentView addSubview:[self tblActivityInfoSection1:userInfoValue]];
                //            }
            
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
        NSLog(@"index path row %ld",indexPath.row);
        if(indexPath.row==0){
            [cell.contentView addSubview:[self tblActivityInfoSection1:userInfoValue]];
        }else{
            dict=[arryAllPost objectAtIndex:indexPath.row-1];
            [cell.contentView addSubview: [self tblActivity:dict indexPath:indexPath]];
        }
        
        
        
        
    }else if (_tblFriends==tableView){
        if (arryFrnd.count != 0) {
            int count=arryFrnd.count%2;
            long coutCheck=arryFrnd.count/2;
            if(count==1){
                coutCheck=coutCheck+1;
            }else{
                coutCheck=coutCheck;
            }
            long valueTag=indexPath.row+indexPath.row;
            if(arryFrnd.count>=valueTag+1){
                [cell.contentView addSubview:[self tblFriendsView:valueTag]];
            }
        }
        
    }else if (_tblPhotos==tableView){
        
        
        
        if(indexPath.row>=arryAllImages.count){
            
            
            if (!self.noMoreResultsAvailImages && (arryAllImages && arryAllImages.count>0)) {
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
        
        
        if (arryAllImages.count != 0) {
            int count=arryAllImages.count%2;
            long coutCheck=arryAllImages.count/2;
            if(count==1){
                coutCheck=coutCheck+1;
            }else{
                coutCheck=coutCheck;
            }
            long valueTag=indexPath.row+indexPath.row;
            if(arryAllImages.count>=valueTag+1){
                [cell.contentView addSubview:[self tblAllImages:valueTag]];
            }
        }
    }
    
    
    return cell;
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

- (CGFloat)getLabelWidth:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, 20);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
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
    btnMore.tag=indexPath.row-1;
    
    
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

    NSString *strLikeCount = [dict objectForKey:@"countLikes"];

    if([strLikeCount intValue] > 99)
    {
        strLikeCount = @"99+";
    }
    [btnLike setTitle:[NSString stringWithFormat:@" %@",strLikeCount] forState:UIControlStateNormal];


//    [btnLike setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countLikes"]] forState:UIControlStateNormal];
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
    
    btnLike.tag=indexPath.row-1;
    
    
    
    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 85+[self getLabelHeight:msg], 50, 32)];
    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];

    NSString *strCommentCount = [dict objectForKey:@"countcomments"];

    if([strCommentCount intValue] > 99)
    {
        strCommentCount = @"99+";
    }
    [btnComment setTitle:[NSString stringWithFormat:@" %@",strCommentCount] forState:UIControlStateNormal];


//    [btnComment setTitle:[NSString stringWithFormat:@" %@",msg] forState:UIControlStateNormal];

    [btnComment addTarget:self
                   action:@selector(cmdCommentAllPost:)
         forControlEvents:UIControlEventTouchUpInside];
    
    
    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnComment.layer.cornerRadius=10;//0,160,223
    btnComment.layer.borderWidth=1;
    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnComment.tag=indexPath.row-1;
    
    [viewDesign addSubview:btnComment];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:msg], 50, 32)];
    [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    [btnShare addTarget:self
                 action:@selector(cmdShareAllPost:)
       forControlEvents:UIControlEventTouchUpInside];
    
    
    
    btnShare.tag=indexPath.row-1;
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
    btnView.tag=indexPath.row-1;
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
        viewImage.tag=indexPath.row-1;
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
        // self.imgURLs=arryimglink;
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
    [self.navigationController pushViewController:cont animated:YES];
}



-(UIView *)addImageView:(NSArray *)arryImage view:(UIView *)view{
    
    if(arryImage.count==5 || arryImage.count>5){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
//        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        [bannerPost2 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
//        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
//        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
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
//        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost5=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, (view.frame.size.height/3)*2, view.frame.size.width/2, view.frame.size.height/3)];
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost5.showActivityIndicator=YES;
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[4]];
        [bannerPost5 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
//        bannerPost5.imageURL=[NSURL URLWithString:strUrl];
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
//        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2-1, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
//        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/2-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
//        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[3]];
//        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
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
//        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, view.frame.size.height/2,(view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
//        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, 0, (view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
//        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
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
//        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2,0 , view.frame.size.width/2, view.frame.size.height)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
//        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
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
//        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
         [bannerPost1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
    }
    
    return view;
}
-(UIView *)tblEventsDesign:(NSDictionary *)dict{
    
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 280)];
    viewDesign.backgroundColor=[UIColor clearColor];
    
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_SIZE.width-20, 260)];
    view.backgroundColor=[UIColor colorWithRed:229/225.0 green:229/225.0 blue:229/225.0 alpha:1.0];
    [viewDesign addSubview:view];
    
    UIView *viewSide=[[UIView alloc]initWithFrame:CGRectMake(10, 10, view.frame.size.width/3, 110)];
    viewSide.backgroundColor=[[UIColor colorWithRed:177/255.0 green:203/255.0 blue:236/255.0 alpha:1.0] colorWithAlphaComponent:0.1] ;//r177,203,236
    [viewDesign addSubview:viewSide];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 10,SCREEN_SIZE.width-40-view.frame.size.width/3,40)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.backgroundColor=[UIColor clearColor];
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"title"];
    [viewDesign addSubview:name];
    
    UILabel *venue = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 50,SCREEN_SIZE.width-40-view.frame.size.width/3,20)];
    [venue setFont:[UIFont systemFontOfSize:14]];
    venue.textAlignment=NSTextAlignmentLeft;
    venue.numberOfLines=11;
    venue.textColor=[UIColor blackColor];
    venue.text=[NSString stringWithFormat:@"%@, %@",[dict objectForKey:@"location"],[dict objectForKey:@"country"]];
    venue.backgroundColor=[UIColor whiteColor];
    [viewDesign addSubview:venue];
    
    UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 70,SCREEN_SIZE.width-view.frame.size.width/3-40,20)];
    [byWhome setFont:[UIFont systemFontOfSize:14]];
    byWhome.textAlignment=NSTextAlignmentLeft;
    byWhome.numberOfLines=11;
    byWhome.text=[NSString stringWithFormat:@"By %@",[dict objectForKey:@"name"]];
    byWhome.textColor=[UIColor blackColor];
    [viewDesign addSubview:byWhome];
    
    
    UILabel *startTime = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 90,SCREEN_SIZE.width-view.frame.size.width/3-40,20)];
    [startTime setFont:[UIFont systemFontOfSize:14]];
    startTime.textAlignment=NSTextAlignmentLeft;
    startTime.numberOfLines=11;
    startTime.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"startTime"]];
    startTime.textColor=[UIColor blackColor];
    [viewDesign addSubview:startTime];
    
        //KabelMedium,KabelITCbyBT-Book
    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"MMM"];
    NSString *strMonth=[dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"dd"];
    NSString *strDay=[dateFormat stringFromDate:date];
    
    UILabel *startDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 30,(SCREEN_SIZE.width-40)/3,30)];
    [startDate setFont:[UIFont boldSystemFontOfSize:18]];
    startDate.textAlignment=NSTextAlignmentCenter;
    startDate.numberOfLines=2;
    startDate.backgroundColor=[UIColor clearColor];
    startDate.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    startDate.text=strDay;
    [viewDesign addSubview:startDate];
    
    UILabel *endDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 60,(SCREEN_SIZE.width-40)/3,30)];
    [endDate setFont:[UIFont systemFontOfSize:16]];
    endDate.textAlignment=NSTextAlignmentCenter;
    endDate.numberOfLines=2;
    endDate.backgroundColor=[UIColor clearColor];
    endDate.text=strMonth;
    endDate.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [viewDesign addSubview:endDate];
    
    NSString *strImageList=[dict objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
    AsyncImageView *imgGroup=[[AsyncImageView alloc]initWithFrame:CGRectMake(10, 120,SCREEN_SIZE.width-20,150)];
    imgGroup.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryImageList.count>0){
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImageList[0]];
//        imgGroup.imageURL=[NSURL URLWithString:strUrl];
         [imgGroup sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    
    imgGroup.clipsToBounds=YES;
    [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
    [viewDesign addSubview:imgGroup];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [imgGroup addGestureRecognizer:tap];
    [imgGroup setUserInteractionEnabled:YES];
    
    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-65, 85, 50, 32)];
    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
    btnView.layer.cornerRadius=10;//0,160,223
    btnView.layer.borderWidth=1;
    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [viewDesign addSubview:btnView];
    
    return viewDesign;
}
-(UIView *)tblAllImages:(long )valueTag{
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, (SCREEN_SIZE.width/2)+32)];
    viewDesign.backgroundColor=[UIColor clearColor];
    
    NSDictionary *dict=[arryAllImages objectAtIndex:valueTag];
    
    
    UIView *containierView=[[UIView alloc]initWithFrame:CGRectMake(16, 20, SCREEN_SIZE.width/2-24, SCREEN_SIZE.width/2+12)];
    containierView.backgroundColor=[UIColor whiteColor];
    containierView.layer.borderWidth=0.5;
    containierView.layer.borderColor=[UIColor lightGrayColor].CGColor ;
    containierView.layer.masksToBounds=NO;
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 5,SCREEN_SIZE.width/2-30 ,SCREEN_SIZE.width/2)];
    banner.showActivityIndicator=YES;
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    banner.imageURL=[NSURL URLWithString:strUrl];
     [banner sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    banner.clipsToBounds=YES;
    banner.tag=valueTag;
    [banner setContentMode:UIViewContentModeRedraw];
    [containierView addSubview:banner];
    [viewDesign addSubview:containierView];
    banner.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(smallButtonTappedImagesForComment:)];
    tapGesture1.numberOfTapsRequired = 1;
    [tapGesture1 setDelegate:self];
    [banner addGestureRecognizer:tapGesture1];
    if(arryAllImages.count>valueTag+1){
        
        NSDictionary *dict=[arryAllImages objectAtIndex:valueTag+1];
        
        
        UIView *containierView=[[UIView alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width/2+8, 20, SCREEN_SIZE.width/2-24, SCREEN_SIZE.width/2+12)];
        containierView.backgroundColor=[UIColor whiteColor];
        containierView.layer.borderWidth=0.5;
        containierView.layer.borderColor=[UIColor lightGrayColor].CGColor ;
        containierView.layer.masksToBounds=NO;
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(5, 5,SCREEN_SIZE.width/2-30 ,SCREEN_SIZE.width/2)];
        banner.showActivityIndicator=YES;
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
        strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//        banner.imageURL=[NSURL URLWithString:strUrl];
         [banner sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        banner.clipsToBounds=YES;
        banner.tag=valueTag+1;
        [banner setContentMode:UIViewContentModeRedraw];
        [containierView addSubview:banner];
        banner.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(smallButtonTappedImagesForComment:)];
        tapGesture1.numberOfTapsRequired = 1;
        [tapGesture1 setDelegate:self];
        [banner addGestureRecognizer:tapGesture1];
        [viewDesign addSubview:containierView];
        
    }
    
    return viewDesign;
    
}
-(void)smallButtonTappedImages:(UITapGestureRecognizer *)tapRecognizer {
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

-(void)smallButtonTappedImagesForComment:(UITapGestureRecognizer *)tapRecognizer {
    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;
    AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
    R2VC.arryGroupImages=arryAllImages;
    [self.navigationController pushViewController:R2VC animated:YES];
}

-(UIView *)tblFriendsView:(long )valueTag{
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, (SCREEN_SIZE.width/2)+32)];
    viewDesign.backgroundColor=[UIColor clearColor];
    
    NSDictionary *dict=[arryFrnd objectAtIndex:valueTag];
    
    
    UIView *containierView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 230)];
    containierView.backgroundColor=[UIColor whiteColor];
    containierView.layer.borderWidth=0.5;
    containierView.layer.borderColor=[UIColor lightGrayColor].CGColor ;
    containierView.layer.masksToBounds=NO;
    
    
    
    
    
    UIView *viewFrame=[[UIView alloc]initWithFrame:CGRectMake(5, 2.5, SCREEN_SIZE.width/2-8, 225)];
    viewFrame.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    
    
    
        // border radius
    [viewFrame.layer setCornerRadius:15.0f];
    
        // border
    [viewFrame.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [viewFrame.layer setBorderWidth:1.5f];
    
        // drop shadow
    [viewFrame.layer setShadowColor:[UIColor clearColor].CGColor];
    [viewFrame.layer setShadowOpacity:0.8];
    [viewFrame.layer setShadowRadius:3.0];
    [viewFrame.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(viewFrame.frame.size.width/2-50, 2,100,100)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    banner.image=[UIImage imageNamed:@"defaultAllUser"];
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
//    banner.imageURL=[NSURL URLWithString:strUrl];
     [banner sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
        // banner.image=[UIImage imageNamed:@"Logo"];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [viewFrame addSubview:banner];
    banner.userInteractionEnabled=YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    banner.layer.cornerRadius=50;
    banner.layer.borderWidth=1;
    banner.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 102,viewFrame.frame.size.width,20)];
    [lblName setFont:[UIFont boldSystemFontOfSize:14]];
    lblName.textAlignment=NSTextAlignmentCenter;
    lblName.numberOfLines=2;
    lblName.textColor=[UIColor blackColor];//userChatName
    lblName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
        //lblName.text=@"Arun";
    [viewFrame addSubview:lblName];
    
    
    UILabel *lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(0, 122,viewFrame.frame.size.width,60)];
    [lblDetails setFont:[UIFont systemFontOfSize:12]];
    lblDetails.textAlignment=NSTextAlignmentCenter;
    lblDetails.numberOfLines=8;
    lblDetails.textColor=[UIColor blackColor];//userChatName
    lblDetails.text=[NSString stringWithFormat:@"%@\n%@",[dict objectForKey:@"aboutme"],[dict objectForKey:@"current_country"]];
    
    [viewFrame addSubview:lblDetails];
    
    UIButton *btnSendMsg=[[UIButton alloc]initWithFrame:CGRectMake(viewFrame.frame.size.width/2-60, 182, 120, 40)];
    btnSendMsg.tag=valueTag;
        // [btnSendMsg setTitle:@"Send Message" forState:UIControlStateNormal];
        //    [btnSendMsg addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
    btnSendMsg.layer.cornerRadius=20;
    btnSendMsg.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnSendMsg.layer.borderWidth=1;
    [btnSendMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnSendMsg.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    
    NSString *strisFriends=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isFriends"]];
    if([strisFriends isEqualToString:@"1"]){
        [btnSendMsg setTitle:@"Send Message" forState:UIControlStateNormal];
        [btnSendMsg addTarget:self action:@selector(cmdSendMsg:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [btnSendMsg addTarget:self action:@selector(cmdSendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        [btnSendMsg setTitle:@"Link" forState:UIControlStateNormal];
    }
    
    [viewFrame addSubview:btnSendMsg];
    
    [containierView addSubview:viewFrame];
    if(arryFrnd.count>valueTag+1){
        
        NSDictionary *dict=[arryFrnd objectAtIndex:valueTag+1];
        UIView *viewFrame1=[[UIView alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width/2+2.5, 2.5, SCREEN_SIZE.width/2-8, 225)];
        
        viewFrame1.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
        
        
            // border radius
        [viewFrame1.layer setCornerRadius:15.0f];
        
            // border
        [viewFrame1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [viewFrame1.layer setBorderWidth:1.5f];
        
            // drop shadow
        [viewFrame1.layer setShadowColor:[UIColor clearColor].CGColor];
        [viewFrame1.layer setShadowOpacity:0.8];
        [viewFrame1.layer setShadowRadius:3.0];
        [viewFrame1.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(viewFrame.frame.size.width/2-50, 2,100,100)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        banner.image=[UIImage imageNamed:@"defaultAllUser"];
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
//        banner.imageURL=[NSURL URLWithString:strUrl];
        [banner sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
            //banner.image=[UIImage imageNamed:@"Logo"];
        banner.clipsToBounds=YES;
        [banner setContentMode:UIViewContentModeScaleAspectFill];
        [viewFrame1 addSubview:banner];
        banner.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
        [banner addGestureRecognizer:tap];
        [banner setUserInteractionEnabled:YES];
        
        banner.layer.cornerRadius=50;
        banner.layer.borderWidth=1;
        banner.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, 102,viewFrame.frame.size.width,20)];
        [lblName setFont:[UIFont boldSystemFontOfSize:14]];
        lblName.textAlignment=NSTextAlignmentCenter;
        lblName.numberOfLines=2;
        lblName.textColor=[UIColor blackColor];//userChatName
        lblName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
            // lblName.text=@"Arun";
        [viewFrame1 addSubview:lblName];
        
        
        UILabel *lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(0, 122,viewFrame.frame.size.width,60)];
        [lblDetails setFont:[UIFont systemFontOfSize:12]];
        lblDetails.textAlignment=NSTextAlignmentCenter;
        lblDetails.numberOfLines=8;
        lblDetails.textColor=[UIColor blackColor];//userChatName
        lblDetails.text=[NSString stringWithFormat:@"%@\n%@",[dict objectForKey:@"aboutme"],[dict objectForKey:@"current_country"]];
        [viewFrame1 addSubview:lblDetails];
        
        UIButton *btnSendMsg=[[UIButton alloc]initWithFrame:CGRectMake(viewFrame.frame.size.width/2-60, 182, 120, 40)];
        btnSendMsg.tag=valueTag+1;
        NSString *strisFriends=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isFriends"]];
        if([strisFriends isEqualToString:@"1"]){
            [btnSendMsg setTitle:@"Send Message" forState:UIControlStateNormal];
            [btnSendMsg addTarget:self action:@selector(cmdSendMsg:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [btnSendMsg addTarget:self action:@selector(cmdSendRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            [btnSendMsg setTitle:@"Link" forState:UIControlStateNormal];
        }
            // [btnSendMsg addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
        btnSendMsg.layer.cornerRadius=20;
        btnSendMsg.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnSendMsg.layer.borderWidth=1;
        [btnSendMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnSendMsg.titleLabel.font=[UIFont boldSystemFontOfSize:14];
        [viewFrame1 addSubview:btnSendMsg];
        [containierView addSubview:viewFrame1];
        
    }
    return containierView;
}

-(UIView *)tblActivityInfoSection1:(NSDictionary *)dict{
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 230)];
    
    viewDesign.backgroundColor=[UIColor clearColor];
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"backImage"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [viewDesign addSubview:banner];
    
    AsyncImageView *imgGroupImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(16, 100,100,100)];
    imgGroupImage.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
//    imgGroupImage.imageURL=[NSURL URLWithString:strUrl];
    [imgGroupImage sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    imgGroupImage.clipsToBounds=YES;
    [imgGroupImage setContentMode:UIViewContentModeScaleAspectFill];
    imgGroupImage.layer.cornerRadius=50;
    imgGroupImage.layer.borderWidth=2;
    imgGroupImage.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [viewDesign addSubview:imgGroupImage];
    
    UILabel *lblGroupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 160,SCREEN_SIZE.width-120,20)];
    [lblGroupName setFont:[UIFont boldSystemFontOfSize:16]];
    lblGroupName.textAlignment=NSTextAlignmentLeft;
    lblGroupName.numberOfLines=2;
    lblGroupName.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];//userChatName
    lblGroupName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    [viewDesign addSubview:lblGroupName];
    
    UILabel *lblGroupType = [[UILabel alloc] initWithFrame:CGRectMake(120, 180,100,20)];
    [lblGroupType setFont:[UIFont boldSystemFontOfSize:11]];
    lblGroupType.textAlignment=NSTextAlignmentLeft;
    lblGroupType.numberOfLines=2;
    lblGroupType.textColor=[UIColor blackColor];//userChatName
    lblGroupType.text=[NSString stringWithFormat:@"%lu Friends",(unsigned long)arryFrnd.count];
    [viewDesign addSubview:lblGroupType];
    
    
    UILabel *lblGroupType1 = [[UILabel alloc] initWithFrame:CGRectMake(230, 180,100,20)];
    [lblGroupType1 setFont:[UIFont boldSystemFontOfSize:11]];
    lblGroupType1.textAlignment=NSTextAlignmentLeft;
    lblGroupType1.numberOfLines=2;
    lblGroupType1.textColor=[UIColor blackColor];//userChatName
    lblGroupType1.text=[NSString stringWithFormat:@"%lu Photos",(unsigned long)arryAllImages1.count];
    [viewDesign addSubview:lblGroupType1];
    
    
    
    AsyncImageView *imgFrndImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(120, 205,20,20)];
    imgFrndImage.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryFrnd.count>0){
        
        NSDictionary *dict1=[arryFrnd objectAtIndex:0];
      
        
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage.imageURL=[NSURL URLWithString:strUrl];

        [imgFrndImage sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];

    }
    
    imgFrndImage.clipsToBounds=YES;
    [imgFrndImage setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage];
    
    AsyncImageView *imgFrndImage1=[[AsyncImageView alloc]initWithFrame:CGRectMake(145, 205,20,20)];
    imgFrndImage1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryFrnd.count>1){
        NSDictionary *dict1=[arryFrnd objectAtIndex:1];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage1.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage1 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage1.clipsToBounds=YES;
    [imgFrndImage1 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage1.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage1];
    
    
    AsyncImageView *imgFrndImage2=[[AsyncImageView alloc]initWithFrame:CGRectMake(170, 205,20,20)];
    imgFrndImage2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryFrnd.count>2){
        NSDictionary *dict1=[arryFrnd objectAtIndex:2];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage2.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage2 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage2.clipsToBounds=YES;
    [imgFrndImage2 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage2.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage2];
    
    
    
    AsyncImageView *imgFrndImage3=[[AsyncImageView alloc]initWithFrame:CGRectMake(230, 205,20,20)];
    imgFrndImage3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryAllImages1.count>0){
        NSDictionary *dict1=[arryAllImages1 objectAtIndex:0];
          lblGroupType1.text=[NSString stringWithFormat:@"%@ Photos",[dict1 objectForKey:@"image_count"]];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage3.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage3 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage3.clipsToBounds=YES;
    [imgFrndImage3 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage3.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage3];
    
    AsyncImageView *imgFrndImage4=[[AsyncImageView alloc]initWithFrame:CGRectMake(255, 205,20,20)];
    imgFrndImage4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryAllImages1.count>0){
        NSDictionary *dict1=[arryAllImages1 objectAtIndex:0];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage4.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage4 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage4.clipsToBounds=YES;
    [imgFrndImage4 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage4.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage4];
    
    
    AsyncImageView *imgFrndImage5=[[AsyncImageView alloc]initWithFrame:CGRectMake(280, 205,20,20)];
    imgFrndImage5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryAllImages1.count>1){
        NSDictionary *dict1=[arryAllImages1 objectAtIndex:1];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage5.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage5 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage5.clipsToBounds=YES;
    [imgFrndImage5 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage5.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage5];
    
    AsyncImageView *imgFrndImage6=[[AsyncImageView alloc]initWithFrame:CGRectMake(280, 205,20,20)];
    imgFrndImage6.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    if(arryAllImages1.count>2){
        NSDictionary *dict1=[arryAllImages1 objectAtIndex:2];
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict1 objectForKey:@"image"]];
//        imgFrndImage6.imageURL=[NSURL URLWithString:strUrl];
        [imgFrndImage6 sd_setImageWithURL:[NSURL URLWithString:strUrl] placeholderImage:nil];
    }
    
    imgFrndImage6.clipsToBounds=YES;
    [imgFrndImage6 setContentMode:UIViewContentModeScaleAspectFill];
    imgFrndImage6.layer.cornerRadius=2;
    [viewDesign addSubview:imgFrndImage6];
    
    return viewDesign;
}
@end

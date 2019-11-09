//
//  PagesDetailsViewController.m
//  iBlah-Blah
//
//  Created by Arun on 12/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PagesDetailsViewController.h"
#import "CommentViewController.h"
@interface PagesDetailsViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    NSArray *arryGroupInforamtion;
    NSArray *arryGroupMember;
    NSMutableArray *arryAllPost;
    NSMutableArray *arryAllImages;
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;
    NSArray *arryAllEvent;
    IndecatorView *ind;
    int checkBTNScroll;
}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@property (strong, nonatomic) NSArray *imgURLs;
@end

@implementation PagesDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    checkBTNScroll=0;
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    currentAllPostPage=@"0";
    [self setNavigationBar];
    [self checkLayout];
        //emit("showAllGroupImages", user_id, group_id)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"PageDetails"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GroupAllPost"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GroupAllEvent"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GroupAllImages"
                                               object:nil];
        //emit("getAllPostGroups", user_id, group_id, post_numbers);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllGroupImages" with:@[USERID,[_dictPages objectForKey:@"id"]]];
    
    [appDelegate().socket emit:@"getAllEventsGroups" with:@[USERID,[_dictPages objectForKey:@"id"],@"0"]];
    
    [appDelegate().socket emit:@"getAllPostGroups" with:@[USERID,[_dictPages objectForKey:@"id"],currentAllPostPage]];
    
    [appDelegate().socket emit:@"showPageDetail" with:@[USERID,[_dictPages objectForKey:@"id"]]];
        // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}

-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"PageDetails"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        if(Arr.count>1){
            NSData *objectData = [[Arr objectAtIndex:2] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            arryGroupMember=json;
        }
        
        NSLog(@"json %@",json);
        arryGroupInforamtion=[json mutableCopy];
        [_tblInformation reloadData];
            //        [_tblMyGroup reloadData];
        
    }else  if ([[notification name] isEqualToString:@"GroupAllPost"]) {
        NSDictionary* userInfo = notification.userInfo;
        [ind removeFromSuperview];
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
        
    }else  if ([[notification name] isEqualToString:@"GroupAllEvent"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryAllEvent=[json mutableCopy];
        [_tblEvents reloadData];
        
    }else  if ([[notification name] isEqualToString:@"GroupAllImages"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSLog(@"%@",Arr);
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryAllImages=[json mutableCopy];
        [_tblPhotos reloadData];
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
    
    self.title=@"Details";
    self.navigationController.navigationBarHidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (IBAction)cmdInformation:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (IBAction)cmdActivity:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
    
}

- (IBAction)cmdEvents:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*2, 0) animated:YES];
    
}

- (IBAction)cmdPhotos:(id)sender {
    [self.scrollViewTable setContentOffset:CGPointMake(SCREEN_SIZE.width*3, 0) animated:YES];
}

#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    
    if(tableView==_tblInformation){
        return 2;
    }else if (tableView==_tblActivity){
        return 1;
    }else if (_tblEvents==tableView){
        return 1;
    }else if(_tblPhotos == tableView){
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(tableView==_tblInformation){
        if(section==0){
            return 1;
        }else{
            return 1;
        }
        return 1;
    }else if (tableView==_tblActivity){
        if(arryAllPost.count>0){
            return arryAllPost.count+1;
        }else{
            return 1;
        }
    }else if (_tblEvents==tableView){
        return  arryAllEvent.count;;
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
    
    if(tableView==_tblInformation){
        if(indexPath.section==0){
            return 212;
        }else{
            return 80;
        }
        return 1;
    }else if (tableView==_tblActivity){
        if(indexPath.row>=arryAllPost.count){
            return 50;
        }
        NSDictionary *dict=[arryAllPost objectAtIndex:indexPath.row];
        if(![[dict objectForKey:@"images"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125;
            
        }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125;
        }
        return  125+[self getLabelHeight:[dict objectForKey:@"discription"]];
        
    }else if (_tblEvents==tableView){
        return 280;;
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
    
    NSDictionary *dict;
    if(tableView ==_tblInformation){
        
        if(indexPath.section==0){
            dict =[arryGroupInforamtion objectAtIndex:indexPath.row];
            [cell.contentView addSubview:[self tblInfoSection1:dict]];
            
        }else{
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            dict =[arryGroupMember objectAtIndex:indexPath.row];
            [cell.contentView addSubview:[self tblInfoSection2:dict]];
        }
        
    }else if (tableView==_tblActivity){
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
        
        
        
    }else if (_tblEvents==tableView){
        NSDictionary *dict=[arryAllEvent objectAtIndex:indexPath.row];
        [cell.contentView addSubview:[self tblEventsDesign:dict]];
        
    }else if (_tblPhotos==tableView){
        
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
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==_tblInformation){
        if(section==0){
            return 0;
        }else{
            return 50;
        }
        return 0;
    }
    
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(tableView==_tblInformation){
        UIView *hedderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 50)];
        hedderView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
        
        AsyncImageView *imgGroup=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 15,20,20)];
        imgGroup.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        imgGroup.image=[UIImage imageNamed:@"groupSmall"];
        imgGroup.clipsToBounds=YES;
        [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
        [hedderView addSubview:imgGroup];
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 15,100,20)];
        [lblTitle setFont:[UIFont boldSystemFontOfSize:14]];
        lblTitle.textAlignment=NSTextAlignmentLeft;
        lblTitle.numberOfLines=2;
        lblTitle.textColor=[UIColor blackColor];//userChatName
        lblTitle.text=[NSString stringWithFormat:@"Members"];
        [hedderView addSubview:lblTitle];//
        
        UILabel *lblTotalCount = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-70, 15,40,20)];
        [lblTotalCount setFont:[UIFont boldSystemFontOfSize:14]];
        lblTotalCount.textAlignment=NSTextAlignmentRight;
        lblTotalCount.numberOfLines=2;
        lblTotalCount.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];//userChatName
        lblTotalCount.text=[NSString stringWithFormat:@"%lu",arryGroupMember.count];
        [hedderView addSubview:lblTotalCount];
        
        AsyncImageView *imgArrow=[[AsyncImageView alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-30, 15,20,20)];
        imgArrow.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        imgArrow.image=[UIImage imageNamed:@"arrow"];
        imgArrow.clipsToBounds=YES;
        [imgArrow setContentMode:UIViewContentModeScaleAspectFill];
        [hedderView addSubview:imgArrow];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:hedderView.bounds];
        hedderView.layer.masksToBounds = NO;
        hedderView.layer.shadowColor = [UIColor blackColor].CGColor;
        hedderView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        hedderView.layer.shadowOpacity = 0.5f;
        hedderView.layer.shadowPath = shadowPath.CGPath;
        
        
        return hedderView;
    }else{
        return nil;
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

-(void)checkLayout{
    
    
    CGRect frame=self.tblInformation.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblInformation.frame=frame;
    
    frame=self.tblActivity.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblActivity.frame=frame;
    frame=self.tblActivity.frame;
    
    frame=self.tblEvents.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*2;
    self.tblEvents.frame=frame;
    frame=self.tblEvents.frame;
    
    frame=self.tblPhotos.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width*3;
    self.tblPhotos.frame=frame;
    frame=self.tblPhotos.frame;
    
    frame= _btnInformation.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    _btnInformation.frame=frame;
    
    frame= _btnActivity.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    frame.origin.x=SCREEN_SIZE.width/4;
    _btnActivity.frame=frame;
    
    frame= _btnEvents.frame;
    frame.size.width=SCREEN_SIZE.width/4;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnEvents.frame=frame;
    
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
    //self.scrollViewBtn.pagingEnabled                  = YES;
    self.scrollViewBtn.showsHorizontalScrollIndicator = NO;
    self.scrollViewBtn.showsVerticalScrollIndicator   = NO;
    self.scrollViewBtn.delegate                       = self;
    self.scrollViewBtn.bounces                        = NO;
    
    
    float width                 = (SCREEN_SIZE.width/2) ;
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
    float tobbarhig1            = CGRectGetHeight(self.tblInformation.frame);
    float btnhig1                = CGRectGetHeight(_tblInformation.frame);
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
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        NSString *USERID = [prefs stringForKey:@"USERID"];
                        [appDelegate().socket emit:@"getAllEventsGroups" with:@[USERID,@"",currentAllPostPage]];
                        
                    }else{
                        self.loadingAllPost=NO;
                        self.noMoreResultsAvailAllPost=YES;
                        [self.tblActivity reloadData];
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
//            [self changeButtonColor];
//            [_btnActivity setBackgroundColor:[UIColor whiteColor]];
//            [_btnActivity setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
//            if(checkBTNScroll==0){
//               // checkBTNScroll=1;
//                 [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width/2, 0) animated:YES];
//            }else{
//                 [self.scrollViewBtn setContentOffset:CGPointMake(0, 0) animated:YES];
//            }
//           checkBTNScroll=1;
             _viewAnimation.frame=CGRectMake(SCREEN_SIZE.width/4, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else if (xOffset>=SCREEN_SIZE.width*2 && xOffset<SCREEN_SIZE.width*3){
            
//            [self changeButtonColor];
//            [_btnEvents setBackgroundColor:[UIColor whiteColor]];
//            [_btnEvents setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
//            if(checkBTNScroll==1){
//
//                [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
//            }else{
//
//                 [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width/2, 0) animated:YES];
//            }
//             checkBTNScroll=2;
            _viewAnimation.frame=CGRectMake((SCREEN_SIZE.width/4)*2, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else if (xOffset>=SCREEN_SIZE.width*3 && xOffset<SCREEN_SIZE.width*4){
//            [self changeButtonColor];
//            [_btnPhotos setBackgroundColor:[UIColor whiteColor]];
//            [_btnPhotos setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
//            [self.scrollViewBtn setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
             _viewAnimation.frame=CGRectMake((SCREEN_SIZE.width/4)*3, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }else{
//            [self changeButtonColor];
//            checkBTNScroll=0;
//            [_btnInformation setBackgroundColor:[UIColor whiteColor]];
//            [_btnInformation setTitleColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0] forState:UIControlStateNormal];
//            [self.scrollViewBtn setContentOffset:CGPointMake(0, 0) animated:YES];
              _viewAnimation.frame=CGRectMake(0, _viewAnimation.frame.origin.y, SCREEN_SIZE.width/4, _viewAnimation.frame.size.height);
        }
    }
}
-(void)changeButtonColor{
    [_btnInformation setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnInformation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnActivity  setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnActivity setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnEvents setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnEvents setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_btnPhotos setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [_btnPhotos setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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

#pragma dynamic height of textFeild
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
#pragma mark table design

-(UIView *)tblInfoSection1:(NSDictionary *)dict{
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 212)];
    viewDesign.backgroundColor=[UIColor clearColor];
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"page_image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [viewDesign addSubview:banner];
    
    
    AsyncImageView *imgGroupImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(16, 100,100,100)];
    imgGroupImage.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"page_image"]];
    imgGroupImage.imageURL=[NSURL URLWithString:strUrl];
    imgGroupImage.clipsToBounds=YES;
    [imgGroupImage setContentMode:UIViewContentModeScaleAspectFill];
    imgGroupImage.layer.cornerRadius=50;
    imgGroupImage.layer.borderWidth=2;
    imgGroupImage.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [viewDesign addSubview:imgGroupImage];
    
    UILabel *lblGroupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 160,SCREEN_SIZE.width-120,20)];
    [lblGroupName setFont:[UIFont boldSystemFontOfSize:14]];
    lblGroupName.textAlignment=NSTextAlignmentLeft;
    lblGroupName.numberOfLines=2;
    lblGroupName.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];//userChatName
    lblGroupName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    [viewDesign addSubview:lblGroupName];
    
    UILabel *lblGroupType = [[UILabel alloc] initWithFrame:CGRectMake(120, 180,SCREEN_SIZE.width-120,20)];
    [lblGroupType setFont:[UIFont boldSystemFontOfSize:14]];
    lblGroupType.textAlignment=NSTextAlignmentLeft;
    lblGroupType.numberOfLines=2;
    lblGroupType.textColor=[UIColor blackColor];//userChatName
    lblGroupType.text=[NSString stringWithFormat:@"Public Group - %@",[dict objectForKey:@"catagory"]];
    [viewDesign addSubview:lblGroupType];
    
    
    UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(10, 211,SCREEN_SIZE.width-20 , 1)];
    sepUpView.backgroundColor=[UIColor darkGrayColor];
    sepUpView.alpha=0.4;
    [viewDesign addSubview:sepUpView];
    return viewDesign;
}

-(UIView *)tblInfoSection2:(NSDictionary *)dict1{
    
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 80)];
    viewDesign.backgroundColor=[UIColor clearColor];
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 80)];
    
    long xAxis=16;
    for (int i=0; i<arryGroupMember.count; i++) {
        NSDictionary *dict=[arryGroupMember objectAtIndex:i];
        NSString *strIsAdmin=[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_admin"]];
        if([strIsAdmin isEqualToString:@"1"]){
            UILabel *lblIsAdmin = [[UILabel alloc] initWithFrame:CGRectMake(xAxis, 0,50,10)];
            [lblIsAdmin setFont:[UIFont italicSystemFontOfSize:8]];
            lblIsAdmin.textAlignment=NSTextAlignmentCenter;
            lblIsAdmin.numberOfLines=2;
            lblIsAdmin.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];//userChatName
            lblIsAdmin.text=@"ADMIN";//[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
            [scrollView addSubview:lblIsAdmin];
            
        }
        
        float width=[self getLabelWidth:[dict objectForKey:@"name"]];
        if(width<50){
            width=50;
        }
        
        UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(xAxis,60,width,20)];
        [lblUserName setFont:[UIFont boldSystemFontOfSize:14]];
        lblUserName.textAlignment=NSTextAlignmentLeft;
        lblUserName.numberOfLines=2;
        lblUserName.textColor=[UIColor blackColor];//userChatName
        lblUserName.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
        [scrollView addSubview:lblUserName];
        
        
        
        AsyncImageView *imgUser=[[AsyncImageView alloc]initWithFrame:CGRectMake(xAxis+(width/2)-25, 10,50,50)];
        imgUser.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString  *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
        imgUser.imageURL=[NSURL URLWithString:strUrl];
        imgUser.clipsToBounds=YES;
        [imgUser setContentMode:UIViewContentModeScaleAspectFill];
        imgUser.layer.cornerRadius=25;
        [scrollView addSubview:imgUser];
        
        
        xAxis=xAxis+width+8;
        
    }
    scrollView.contentSize = (CGSize){xAxis, 70};
    [viewDesign addSubview:scrollView];
    return viewDesign;
}

-(UIView *)tblActivity:(NSDictionary *)dict indexPath:(NSIndexPath *)indexPath{
    
    UIView *viewDesign=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 125+[self getLabelHeight:[dict objectForKey:@"discription"]])];
    viewDesign.backgroundColor=[UIColor clearColor];
    
    if(![[dict objectForKey:@"images"] isEqualToString:@""]){
        viewDesign.frame=CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125);
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        viewDesign.frame=CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125);
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
    [viewDesign addSubview:banner];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 20,SCREEN_SIZE.width-100,20)];
    [name setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.textColor=[UIColor blackColor];//userChatName
    name.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
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
    
    
    UITextView *status=[[UITextView alloc] initWithFrame:CGRectMake(20, 80,SCREEN_SIZE.width-40,[self getLabelHeight:[dict objectForKey:@"discription"]])];
    [status setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    status.textColor=[UIColor blackColor];
    status.text=[dict objectForKey:@"discription"];
    status.editable=NO;
    status.backgroundColor=[UIColor clearColor];
    status.scrollEnabled=NO;
    status.textContainerInset = UIEdgeInsetsZero;
    status.dataDetectorTypes=UIDataDetectorTypeAll;
    [viewDesign addSubview:status];
    
    UIButton *btnLike=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
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
    btnLike.layer.cornerRadius=8;//0,160,223
    btnLike.layer.borderWidth=1;
    btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnLike.tag=indexPath.row;
    
    
    
    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countcomments"]] forState:UIControlStateNormal];
    
    [btnComment addTarget:self
                   action:@selector(cmdCommentAllPost:)
         forControlEvents:UIControlEventTouchUpInside];
    
    
    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnComment.layer.cornerRadius=8;//0,160,223
    btnComment.layer.borderWidth=1;
    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnComment.tag=indexPath.row;
    
    [viewDesign addSubview:btnComment];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
    [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    
    [btnShare addTarget:self
                 action:@selector(cmdShareAllPost:)
       forControlEvents:UIControlEventTouchUpInside];
    
    
    
    btnShare.tag=indexPath.row;
    btnShare.layer.cornerRadius=8;//0,160,223
    btnShare.layer.borderWidth=1;
    btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [viewDesign addSubview:btnShare];
    
    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
    
    
        //        [btnView addTarget:self
        //                    action:@selector(cmdShareAllPost:)
        //          forControlEvents:UIControlEventTouchUpInside];
    
    
    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
    btnView.layer.cornerRadius=8;//0,160,223
    btnView.layer.borderWidth=1;
    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnView.tag=indexPath.row;
    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [viewDesign addSubview:btnView];
    
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){
        
        UIView *viewImage=[[UIView alloc]initWithFrame:CGRectMake(0, [self getLabelHeight:[dict objectForKey:@"discription"]]+80,SCREEN_SIZE.width,SCREEN_SIZE.width-40)];
        
        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:[dict objectForKey:@"discription"]]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
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
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        
        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:[dict objectForKey:@"discription"]]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
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
    }
    
    
    
    UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(10, btnComment.frame.origin.y+37,SCREEN_SIZE.width-20 , 1)];
    sepUpView.backgroundColor=[UIColor darkGrayColor];
    sepUpView.alpha=0.4;
    [viewDesign addSubview:sepUpView];
    
    return viewDesign;
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
-(void)cmdMoreALL:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary  *dict=[arryAllPost objectAtIndex:btn.tag];
    NSString *PostUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Delete Post"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   if([PostUserId isEqualToString:USERID]){
                                           // mSocket.emit("showAllVideos",UserID);
                                           //  [appDelegate().socket emit:@"showAllVideos" with:@[@"5d12dbf3-82f2-45b9-8fde-3ef69a187092"];
                                   }else{
                                       [AlertView showAlertWithMessage:@"You don't have permission to delete this post." view:self];
                                   }
                                   
                               }];
    
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
    
    
    NSDictionary  *dict=[arryAllPost objectAtIndex:btn.tag];
    
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
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
    //[self.navigationController presentViewController:cont animated:YES completion:nil];
    [self.navigationController pushViewController:cont animated:YES];
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
                                 alertControllerWithTitle:@""
                                 message:@"Share this post on your wall?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
        //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Share"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        //mSocket.emit("sharePost", user_id, post_id, title,  discription,  posttype, lat, lon,"", postimages, "", type, location, other_user_id
                                    [appDelegate().socket emit:@"sharePost" with:@[USERID,strPost_id,strTitle,strDiscription,strPosttype,strLat,strLon,@"",strPostimages,@"",strType,strLocation,@"5d12dbf3-82f2-45b9-8fde-3ef69a187092"]];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                               }];
    
        //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)bigButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
    UIView *view=(UIView *)tapRecognizer.view;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSDictionary  *dict=[arryAllPost objectAtIndex:view.tag];
    
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    
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
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
    imageVC.startingIndex = 0;
    [self presentViewController:imageVC animated:YES completion:nil];
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
        imgGroup.imageURL=[NSURL URLWithString:strUrl];
    }
    
    
    imgGroup.clipsToBounds=YES;
    [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
    [viewDesign addSubview:imgGroup];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [imgGroup addGestureRecognizer:tap];
    [imgGroup setUserInteractionEnabled:YES];
    
    
    
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
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeRedraw];
    [containierView addSubview:banner];
    [viewDesign addSubview:containierView];
    banner.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(smallButtonTappedImages:)];
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
        banner.imageURL=[NSURL URLWithString:strUrl];
        banner.clipsToBounds=YES;
        [banner setContentMode:UIViewContentModeRedraw];
        [containierView addSubview:banner];
        banner.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(smallButtonTappedImages:)];
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


@end

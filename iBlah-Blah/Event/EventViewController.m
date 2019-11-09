//
//  EventViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "EventViewController.h"
#import "EventDetails ViewController.h"
#import "AddEventViewController.h"
#import "LocationSearchViewController.h"
#import "CommentViewController.h"
#import "InvitePeopleViewController.h"
@interface EventViewController (){
    NSArray *arryAllEvent;
    NSArray *arryMyEvent;
    IndecatorView *ind;
    
    NSString  *currentAllPostPage;
    NSString *currentFrndPost;
    NSString *totalAllPostPage;
    NSString *totalFrndPost;
    DGActivityIndicatorView *spinner;
}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@property (nonatomic) BOOL noMoreResultsAvailFrnd;
@property (nonatomic) BOOL loadingFrnd;
@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noMoreResultsAvailAllPost =NO;
    self.noMoreResultsAvailFrnd =NO;
    currentAllPostPage=@"0";
    currentFrndPost=@"0";
    
    [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllEvent"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MyEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"RefreshEvent"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getEvents" with:@[USERID,currentAllPostPage]];
    [appDelegate().socket emit:@"getMyEvents" with:@[USERID,currentFrndPost]];
    
    
  //  emit("getEvents", user_id, page_number);
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllEvent"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        
        if([currentAllPostPage isEqualToString:@"0"]){
            arryAllEvent=json;
        }else{
            if(json.count){
                NSMutableArray *arryTemp=[arryAllEvent  mutableCopy];
                [arryTemp addObjectsFromArray:json];
                arryAllEvent=arryTemp;
            }else{
                self.loadingAllPost=NO;
                self.noMoreResultsAvailAllPost=YES;
                [self.tblEvent reloadData];
            }
        }
        
        [_tblEvent reloadData];
        
    }else if ([[notification name] isEqualToString:@"RefreshEvent"]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        
        self.noMoreResultsAvailAllPost =NO;
        self.noMoreResultsAvailFrnd =NO;
        currentAllPostPage=@"0";
        currentFrndPost=@"0";
        [appDelegate().socket emit:@"getEvents" with:@[USERID,currentAllPostPage]];
        [appDelegate().socket emit:@"getMyEvents" with:@[USERID,currentFrndPost]];
    }else  if ([[notification name] isEqualToString:@"MyEvent"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        
        if([currentFrndPost isEqualToString:@"0"]){
            arryMyEvent=json;
        }else{
            if(json.count){
                NSMutableArray *arryTemp=[arryMyEvent  mutableCopy];
                [arryTemp addObjectsFromArray:json];
                arryMyEvent=arryTemp;
            }else{
                self.loadingFrnd=NO;
                self.noMoreResultsAvailFrnd=YES;
                [self.tblMyEvent reloadData];
            }
        }
        
        [_tblMyEvent reloadData];
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self checkLayout];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ind removeFromSuperview];
}
- (IBAction)cmdMyEvent:(id)sender {
    
    [self.scrollview setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
}

- (IBAction)cmdEvent:(id)sender {
    [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
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
    
    self.title=@"EVENTS";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddEvent:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}

-(void)cmdAddEvent:(id)sender{
    AddEventViewController *cont=[[AddEventViewController alloc]initWithNibName:@"AddEventViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}

-(void)checkLayout{
    
    
    CGRect frame=self.tblEvent.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblEvent.frame=frame;
    
    frame=self.tblMyEvent.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblMyEvent.frame=frame;
    frame=self.tblMyEvent.frame;
    
    frame= _btnEvent.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btnEvent.frame=frame;
    
    frame= _btnMyEvent.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnMyEvent.frame=frame;
    
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
    float tobbarhig             = CGRectGetHeight(self.tblEvent.frame);
    float btnhig                = CGRectGetHeight(_tblEvent.frame);
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
        
    }else{
        if( _SelectedTabanimation.frame.origin.x>=SCREEN_SIZE.width/2){
            if (!self.loadingFrnd) {
                
                float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
                if (endScrolling >= scrollView.contentSize.height)
                {
                     self.loadingAllPost=YES;
                    
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
                    int currentPageAll=[currentFrndPost intValue];
                    currentFrndPost=  [NSString stringWithFormat:@"%d",currentPageAll];
                    [appDelegate().socket emit:@"getMyEvents" with:@[USERID,currentFrndPost]];
                    
                 
                   
                   
                }
            }
        }else{
            if (!self.loadingAllPost) {
                
                float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
                if (endScrolling >= scrollView.contentSize.height)
                {
                    self.loadingAllPost=YES;
                    
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *USERID = [prefs stringForKey:@"USERID"];
                    int currentPageAll=[totalAllPostPage intValue];
                    totalAllPostPage=  [NSString stringWithFormat:@"%d",currentPageAll];
                    [appDelegate().socket emit:@"getEvents" with:@[USERID,totalAllPostPage]];
                    
                    
                  
                    
                   
                }
            }
        }
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


#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(_tblEvent==tableView){
        return arryAllEvent.count;
    }else{
        return arryMyEvent.count;
    }
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 330;
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
      //  cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_SIZE.width-20, 260)];
    view.backgroundColor=[UIColor colorWithRed:229/225.0 green:229/225.0 blue:229/225.0 alpha:1.0];
    [cell.contentView addSubview:view];
    
    UIView *viewSide=[[UIView alloc]initWithFrame:CGRectMake(10, 10, view.frame.size.width/3, 110)];
    viewSide.backgroundColor=[[UIColor colorWithRed:177/255.0 green:203/255.0 blue:236/255.0 alpha:1.0] colorWithAlphaComponent:0.1] ;//r177,203,236
    [cell.contentView addSubview:viewSide];
    NSDictionary *dict;
    if(_tblEvent==tableView){
        
        
        if(indexPath.row>=arryAllEvent.count){
            
            
            if (!self.noMoreResultsAvailAllPost && (arryAllEvent && arryAllEvent.count>0)) {
                cell.textLabel.text=nil;
                
                spinner.hidden=NO;
                spinner = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
                CGFloat width = 25;
                CGFloat height = 25;
                
                spinner.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, 12, width, height);
                [cell.contentView addSubview:spinner];
                
                if (indexPath.row>=arryAllEvent.count) {
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
        
        
        dict=[arryAllEvent objectAtIndex:indexPath.row];
    }else{
        
        if(indexPath.row>=arryMyEvent.count){
            
            if (!self.noMoreResultsAvailFrnd && (arryMyEvent && arryMyEvent.count >0 )) {
                cell.textLabel.text=nil;
                
                spinner.hidden=NO;
                spinner = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
                CGFloat width = 25;
                CGFloat height = 25;
                
                spinner.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, 12, width, height);
                [cell.contentView addSubview:spinner];
                
                if (indexPath.row>=arryMyEvent.count) {
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
                loadingLabel.numberOfLines = 2;
                loadingLabel.text=@"No More data Available";
                loadingLabel.backgroundColor=[UIColor clearColor];
                cell.backgroundColor=[UIColor clearColor];
                loadingLabel.frame=CGRectMake((self.view.frame.size.width)/2-151,0, 302,50);
                [cell addSubview:loadingLabel];
                [loadingLabel setUserInteractionEnabled:YES];
            }
            
            
            
            
            
            return cell;
        }
        
        
        
        dict=[arryMyEvent objectAtIndex:indexPath.row];
    }
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 10,SCREEN_SIZE.width-40-view.frame.size.width/3,40)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.backgroundColor=[UIColor clearColor];
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"title"];
    [cell.contentView addSubview:name];
    
    UILabel *venue = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 50,SCREEN_SIZE.width-40-view.frame.size.width/3,20)];
    [venue setFont:[UIFont systemFontOfSize:14]];
    venue.textAlignment=NSTextAlignmentLeft;
    venue.numberOfLines=11;
    venue.textColor=[UIColor blackColor];
    venue.text=[NSString stringWithFormat:@"%@, %@",[dict objectForKey:@"location"],[dict objectForKey:@"country"]];
    venue.backgroundColor=[UIColor whiteColor];
    [cell.contentView addSubview:venue];
    
    UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 70,SCREEN_SIZE.width-view.frame.size.width/3-40,20)];
    [byWhome setFont:[UIFont systemFontOfSize:14]];
    byWhome.textAlignment=NSTextAlignmentLeft;
    byWhome.numberOfLines=11;
    byWhome.text=[NSString stringWithFormat:@"By %@",[dict objectForKey:@"name"]];
    byWhome.textColor=[UIColor blackColor];
    [cell.contentView addSubview:byWhome];
    
    
    UILabel *startTime = [[UILabel alloc] initWithFrame:CGRectMake(20+view.frame.size.width/3, 90,SCREEN_SIZE.width-view.frame.size.width/3-40,20)];
    [startTime setFont:[UIFont systemFontOfSize:14]];
    startTime.textAlignment=NSTextAlignmentLeft;
    startTime.numberOfLines=11;
    startTime.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"startTime"]];
    startTime.textColor=[UIColor blackColor];
    [cell.contentView addSubview:startTime];
    
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
    [cell.contentView addSubview:startDate];
    
    UILabel *endDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 60,(SCREEN_SIZE.width-40)/3,30)];
    [endDate setFont:[UIFont systemFontOfSize:16]];
    endDate.textAlignment=NSTextAlignmentCenter;
    endDate.numberOfLines=2;
    endDate.backgroundColor=[UIColor clearColor];
    endDate.text=strMonth;
    endDate.textColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [cell.contentView addSubview:endDate];
    
    
//    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-65, 85, 50, 32)];
//    [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
//    [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
//    btnView.layer.cornerRadius=10;//0,160,223
//    btnView.layer.borderWidth=1;
//    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
//    btnView.tag=indexPath.row;
//    btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
//    [cell.contentView addSubview:btnView];
    
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
    [cell.contentView addSubview:imgGroup];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [imgGroup addGestureRecognizer:tap];
    [imgGroup setUserInteractionEnabled:YES];

    
    NSString *PostUserId=[dict objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    if([PostUserId isEqualToString:USERID]){
        UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
        [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
        btnMore.tag=indexPath.row;
        if(_tblEvent==tableView){
            [btnMore addTarget:self action:@selector(cmdMore:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btnMore addTarget:self action:@selector(cmdMoreMy:) forControlEvents:UIControlEventTouchUpInside];
        }
       
        [cell.contentView addSubview:btnMore];
    }
    
    
   
    
    UIView *viewBottom=[[UIView alloc]initWithFrame:CGRectMake(0, 275, (SCREEN_SIZE.width)/4, 45)];
    
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
    
    
    
    UIView *viewBottom1=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width)/4, 275, (SCREEN_SIZE.width)/4, 45)];
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
    imageView.image=[UIImage imageNamed:@"viewPost"];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    [viewBottom1 addSubview:imageView];
    
    
    UILabel *lblView=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
    lblView.text=[NSString stringWithFormat:@"%@ Views",[dict objectForKey:@"view_count"]];
    lblView.textAlignment=NSTextAlignmentCenter;
    lblView.font=[UIFont systemFontOfSize:12];
    [viewBottom1 addSubview:lblView];
    
    [cell.contentView addSubview:viewBottom1];
    
    
    UIView *viewBottom2=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*2, 275, (SCREEN_SIZE.width)/4, 45)];
   
    
    UIImageView *imageComment=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
    imageComment.image=[UIImage imageNamed:@"chat-comment"];
    imageComment.contentMode=UIViewContentModeScaleAspectFit;
    [viewBottom2 addSubview:imageComment];
    

    UILabel *lblComments=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
    lblComments.text=[NSString stringWithFormat:@"%@ Comments",[dict objectForKey:@"countcomments"]];
    lblComments.textAlignment=NSTextAlignmentCenter;
    lblComments.font=[UIFont systemFontOfSize:12];
    [viewBottom2 addSubview:lblComments];
    
    [cell.contentView addSubview:viewBottom2];
    
    UIView *viewBottom3=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*3, 275, (SCREEN_SIZE.width)/4, 45)];
    
    UIImageView *imageLike=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
    
    NSString *strLikeStatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likestatus"]];
    if([strLikeStatus isEqualToString:@"0"]){
        imageLike.image=[UIImage imageNamed:@"like11"];
    }else{
        imageLike.image=[UIImage imageNamed:@"like-1"];
    }
    imageLike.contentMode=UIViewContentModeScaleAspectFit;
    [viewBottom3 addSubview:imageLike];
    
    UILabel *lblLike=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
    
    lblLike.text=[NSString stringWithFormat:@"%@ Likes",[dict objectForKey:@"countLikes"]];
    lblLike.textAlignment=NSTextAlignmentCenter;
    lblLike.font=[UIFont systemFontOfSize:12];
    [viewBottom3 addSubview:lblLike];
    
    [cell.contentView addSubview:viewBottom3];
    

    
    MYTapGestureRecognizer *tapShare = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdShareAll:)];
    tapShare.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if(_tblEvent==tableView){
        tapShare.data=@"0";
    }else{
        tapShare.data=@"1";
    }
    [viewBottom addGestureRecognizer:tapShare];
    [viewBottom setUserInteractionEnabled:YES];
    
    
    MYTapGestureRecognizer *tapComment = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdCommentAll:)];
    tapComment.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if(_tblEvent==tableView){
        tapComment.data=@"0";
    }else{
        tapComment.data=@"1";
    }
    [viewBottom2 addGestureRecognizer:tapComment];
    [viewBottom2 setUserInteractionEnabled:YES];
    
    
    MYTapGestureRecognizer *tapLike = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdLikeAll:)];
    tapLike.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if(_tblEvent==tableView){
        tapLike.data=@"0";
    }else{
        tapLike.data=@"1";
    }
    [viewBottom3 addGestureRecognizer:tapLike];
    [viewBottom3 setUserInteractionEnabled:YES];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view addSubview:ind];
    EventDetails_ViewController *cont=[[EventDetails_ViewController alloc]initWithNibName:@"EventDetails ViewController" bundle:nil];
    if(_tblEvent==tableView){
          cont.dictPost=[arryAllEvent objectAtIndex:indexPath.row];
    }else{
          cont.dictPost=[arryMyEvent objectAtIndex:indexPath.row];
    }
  
    [self.navigationController pushViewController:cont animated:YES];
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
                                           attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:15.0f]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
#pragma mark api
-(void)cmdMore:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary  *dict=[arryAllEvent objectAtIndex:btn.tag];
    
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Delete Event"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];
                                   // mSocket.emit("delete_post", post_id);
                                   // mSocket.emit("showAllVideos",UserID);
                                   [appDelegate().socket emit:@"delete_post" with:@[strPost_id]];
                                   [self performSelector:@selector(refresh) withObject:nil afterDelay:1.5];
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

-(void)cmdMoreMy:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary  *dict=[arryMyEvent objectAtIndex:btn.tag];
    
    
    
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Delete Event"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   NSString *strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];
                                   // mSocket.emit("delete_post", post_id);
                                   // mSocket.emit("showAllVideos",UserID);
                                   [appDelegate().socket emit:@"delete_post" with:@[strPost_id]];
                                   [self performSelector:@selector(refresh) withObject:nil afterDelay:1.5];
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
-(void)refresh{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RefreshEvent"
     object:self userInfo:nil];
}
- (void)cmdShareAll:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    NSLog(@"data : %@", tap.data);
    NSLog(@"data : %@", tap.tagValue);
    
    
    NSDictionary *dict;
    if([tap.data isEqualToString:@"0"]){
        dict=[arryAllEvent objectAtIndex:[tap.tagValue integerValue]];
    }else{
        dict=[arryMyEvent objectAtIndex:[tap.tagValue integerValue]];
    }
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
        // [alert addAction:btnSharewithFrnd];
    [alert addAction:btnSharewithOtherApp];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}



-(void)shareWithOtherApp:(NSDictionary *)dict{
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
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    NSDictionary *dict;
    if([tap.data isEqualToString:@"0"]){
        dict=[arryAllEvent objectAtIndex:[tap.tagValue integerValue]];
    }else{
        dict=[arryMyEvent objectAtIndex:[tap.tagValue integerValue]];
    }
    
    
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
    NSDictionary *dict;
    if([tap.data isEqualToString:@"0"]){
        dict=[arryAllEvent objectAtIndex:[tap.tagValue integerValue]];
    }else{
        dict=[arryMyEvent objectAtIndex:[tap.tagValue integerValue]];
    }
    
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
            
            NSMutableArray *temp=[arryAllEvent mutableCopy];
            
            [temp replaceObjectAtIndex:[tap.tagValue integerValue] withObject:dictNew];
            
            arryAllEvent=temp;
        }else{
            NSMutableArray *temp=[arryMyEvent mutableCopy];
             [temp replaceObjectAtIndex:[tap.tagValue integerValue] withObject:dictNew];
            arryMyEvent=temp;
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
            
            NSMutableArray *temp=[arryAllEvent mutableCopy];
            
            [temp replaceObjectAtIndex:[tap.tagValue integerValue] withObject:dictNew];
            
            arryAllEvent=temp;
        }else{
            NSMutableArray *temp=[arryMyEvent mutableCopy];
            [temp replaceObjectAtIndex:[tap.tagValue integerValue] withObject:dictNew];
            arryMyEvent=temp;
        }
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tap.tagValue integerValue] inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    if([tap.data isEqualToString:@"0"]){
        
       [self.tblEvent reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }else{
        [self.tblEvent reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [self.tblMyEvent reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    
    
}
@end

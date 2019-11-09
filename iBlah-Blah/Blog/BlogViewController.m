//
//  BlogViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "BlogViewController.h"
#import "AddBlogViewController.h"
#import "BlogDetailsViewController.h"
@interface BlogViewController (){
    NSArray *arryAllBlog;
    NSArray *arryMyBlog;
    IndecatorView *ind;
}

@end

@implementation BlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    // Do any additional setup after loading the view from its nib.
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllBlog"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MyBlog"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UpdateBlog"
                                               object:nil];
    //
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllBlogs" with:@[USERID,@"0"]];
    [appDelegate().socket emit:@"showMyBlogs" with:@[USERID,@"0"]];
   
    
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllBlog"]) {
         [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryAllBlog=[json mutableCopy];
        
        [_tblBlog reloadData];
        
    }else if ([[notification name] isEqualToString:@"UpdateBlog"]) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"showAllBlogs" with:@[USERID,@"0"]];
         [appDelegate().socket emit:@"showMyBlogs" with:@[USERID,@"0"]];
    } else if ([[notification name] isEqualToString:@"MyBlog"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryMyBlog=[json mutableCopy];
        
        [_tblMyBlog reloadData];
        
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

- (IBAction)cmdMyBlog:(id)sender {
    
    [self.scrollview setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
}

- (IBAction)cmdBlog:(id)sender {
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
    
    self.title=@"BLOGS";
    self.navigationController.navigationBarHidden=NO;
    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddBlog:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}

-(void)cmdAddBlog:(id)sender{
    AddBlogViewController *cont=[[AddBlogViewController alloc]initWithNibName:@"AddBlogViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
-(void)checkLayout{
    
    
    CGRect frame=self.tblBlog.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblBlog.frame=frame;
    
    frame=self.tblMyBlog.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblMyBlog.frame=frame;
    frame=self.tblMyBlog.frame;
    
    frame= _btnBlog.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btnBlog.frame=frame;
    
    frame= _btnMyBlog.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnMyBlog.frame=frame;
    
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
    float tobbarhig             = CGRectGetHeight(self.tblBlog.frame);
    float btnhig                = CGRectGetHeight(_tblBlog.frame);
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


#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(_tblBlog ==tableView){
        return  arryAllBlog.count;
    }else{
        return  arryMyBlog.count;
    }
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    
    return 90;
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
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict;
    if(_tblBlog ==tableView){
        dict=[arryAllBlog objectAtIndex:indexPath.row];
    }else{
        dict=[arryAllBlog objectAtIndex:indexPath.row];
    }
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 5,self.view.frame.size.width-16,20)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"title"];
    [cell.contentView addSubview:name];
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 25,40,40)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    banner.layer.cornerRadius=20;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    
    
    UILabel *groupMemberCount = [[UILabel alloc] initWithFrame:CGRectMake(50, 22,self.view.frame.size.width-80,20)];
    [groupMemberCount setFont:[UIFont boldSystemFontOfSize:12]];
    groupMemberCount.textAlignment=NSTextAlignmentLeft;
    groupMemberCount.numberOfLines=2;
    groupMemberCount.lineBreakMode=NSLineBreakByWordWrapping;
    groupMemberCount.textColor=[UIColor blackColor];
    groupMemberCount.text=[dict objectForKey:@"name"];
    [cell.contentView addSubview:groupMemberCount];
    
    
    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"time"]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
    NSString *strDatetoShow=[dateFormat stringFromDate:date];
    
    
    UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(50, 44,self.view.frame.size.width-80,20)];
    [lblDate setFont:[UIFont systemFontOfSize:12]];
    lblDate.textAlignment=NSTextAlignmentLeft;
    lblDate.numberOfLines=2;
    lblDate.lineBreakMode=NSLineBreakByWordWrapping;
    lblDate.textColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
    lblDate.text=strDatetoShow;
    [cell.contentView addSubview:lblDate];
   
    
    UILabel *lblTlblGroupInfo = [[UILabel alloc] initWithFrame:CGRectMake(8, 60,SCREEN_SIZE.width-16,27)];
    [lblTlblGroupInfo setFont:[UIFont systemFontOfSize:10]];
    lblTlblGroupInfo.textAlignment=NSTextAlignmentLeft;
    lblTlblGroupInfo.numberOfLines=3;
    lblTlblGroupInfo.lineBreakMode=NSLineBreakByWordWrapping;
    lblTlblGroupInfo.textColor=[UIColor blackColor];
    lblTlblGroupInfo.text=[dict objectForKey:@"post"];
    [cell.contentView addSubview:lblTlblGroupInfo];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 89, SCREEN_SIZE.width-40, 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlogDetailsViewController *cont=[[BlogDetailsViewController alloc]initWithNibName:@"BlogDetailsViewController" bundle:nil];
    if(tableView==_tblMyBlog){
        cont.dictPost=[arryMyBlog objectAtIndex:indexPath.row];
    }else{
        cont.dictPost=[arryAllBlog objectAtIndex:indexPath.row];
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


@end

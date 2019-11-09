//
//  PagesViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PagesViewController.h"
#import "PagesDetailsViewController.h"
#import "AddPageViewController.h"
@interface PagesViewController (){
    NSArray *arryAllPages;
    NSArray *arryMyPages;
    IndecatorView *ind;
  
}

@end

@implementation PagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllPages"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllPages" with:@[USERID]];
    // Do any additional setup after loading the view from its nib.
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
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
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllPages"]) {
          [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryAllPages=[json mutableCopy];
        [_tblPages reloadData];
        [_tblMyPages reloadData];
        
    }
}
- (IBAction)cmdPages:(id)sender {
    [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (IBAction)cmdMyPages:(id)sender {
    [self.scrollview setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
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
    
    self.title=@"PAGES";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddPage:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}

-(void)cmdAddPage:(id)sender{
    AddPageViewController *cont=[[AddPageViewController alloc]initWithNibName:@"AddPageViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}
-(void)checkLayout{
    
    
    CGRect frame=self.tblPages.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblPages.frame=frame;
    
    frame=self.tblMyPages.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblMyPages.frame=frame;
    frame=self.tblMyPages.frame;
    
    frame= _btPages.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btPages.frame=frame;
    
    frame= _btnMyPages.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnMyPages.frame=frame;
    
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
    float tobbarhig             = CGRectGetHeight(self.tblPages.frame);
    float btnhig                = CGRectGetHeight(_tblPages.frame);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(_tblPages ==tableView){
        return arryAllPages.count;
    }else{
        return arryMyPages.count;
    }
    return 10;
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
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict;
    if(_tblPages ==tableView){
        dict=[arryAllPages objectAtIndex:indexPath.row];
    }else{
         dict=[arryMyPages objectAtIndex:indexPath.row];
    }
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 15,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"page_image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    banner.layer.cornerRadius=25;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
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
    
    UILabel *groupMemberCount = [[UILabel alloc] initWithFrame:CGRectMake(75, 27,100,20)];
    [groupMemberCount setFont:[UIFont boldSystemFontOfSize:12]];
    groupMemberCount.textAlignment=NSTextAlignmentCenter;
    groupMemberCount.numberOfLines=2;
    groupMemberCount.lineBreakMode=NSLineBreakByWordWrapping;
    groupMemberCount.textColor=[UIColor blackColor];
    groupMemberCount.text=[NSString stringWithFormat:@"Photography %@",[dict objectForKey:@"memberCount"]];
    [cell.contentView addSubview:groupMemberCount];
    
    
    AsyncImageView *imgGroup=[[AsyncImageView alloc]initWithFrame:CGRectMake(175, 27,20,20)];
    imgGroup.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    imgGroup.image=[UIImage imageNamed:@"groupSmall"];
    imgGroup.clipsToBounds=YES;
    [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:imgGroup];
    
    UILabel *lblTlblGroupInfo = [[UILabel alloc] initWithFrame:CGRectMake(75, 50,SCREEN_SIZE.width-175,30)];
    [lblTlblGroupInfo setFont:[UIFont systemFontOfSize:11]];
    lblTlblGroupInfo.textAlignment=NSTextAlignmentLeft;
    lblTlblGroupInfo.numberOfLines=2;
    lblTlblGroupInfo.lineBreakMode=NSLineBreakByWordWrapping;
    lblTlblGroupInfo.textColor=[UIColor blackColor];
    lblTlblGroupInfo.text=[dict objectForKey:@"description"];
    [cell.contentView addSubview:lblTlblGroupInfo];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 79, SCREEN_SIZE.width-40, 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict;
    if(_tblPages==tableView){
        dict=[arryAllPages objectAtIndex:indexPath.row];
    }else{
        dict=[arryMyPages objectAtIndex:indexPath.row];
    }
    PagesDetailsViewController *cont=[[PagesDetailsViewController alloc]initWithNibName:@"PagesDetailsViewController" bundle:nil];
    cont.dictPages=dict;
    [self.navigationController pushViewController:cont animated:YES];
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

//
//  MarketplaceViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "MarketplaceViewController.h"
#import "HPGrowingTextView.h"
#import "MarketPlaceDetailsViewController.h"
#import "AddMarketPlaceViewController.h"
@interface MarketplaceViewController (){
     NSArray *arryMarketplace;
     NSArray *arryMyMarketplace;
    IndecatorView *ind;
}

@end

@implementation MarketplaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Marketplace"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UpdateMarketplace"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MyMarketplace"
                                               object:nil];

    //emit("showAllLists", user_id)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
     [appDelegate().socket emit:@"showAllLists" with:@[USERID]];
     [appDelegate().socket emit:@"showMyLists" with:@[USERID]];

    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    // Do any additional setup after loading the view from its nib.
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"Marketplace"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryMarketplace=[json mutableCopy];
        [_tblAllListing reloadData];
       [_tblMyListing reloadData];
        
    } else if ([[notification name] isEqualToString:@"UpdateMarketplace"]) {//MyMarketplace
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"showAllLists" with:@[USERID]];

    }else if ([[notification name] isEqualToString:@"MyMarketplace"]) {
        
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        arryMyMarketplace=[json mutableCopy];
        [_tblAllListing reloadData];
        [_tblMyListing reloadData];

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

- (IBAction)cmdMyListing:(id)sender {
    
    [self.scrollview setContentOffset:CGPointMake(SCREEN_SIZE.width, 0) animated:YES];
}

- (IBAction)cmdAllListing:(id)sender {
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
    
    self.title=@"MARKETPLACE";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddMarketPlace:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}
-(void)cmdAddMarketPlace:(id)sender{
    AddMarketPlaceViewController *cont=[[AddMarketPlaceViewController alloc]initWithNibName:@"AddMarketPlaceViewController" bundle:nil];
    [self.navigationController pushViewController:cont animated:YES];
}

-(void)checkLayout{
    
    
    CGRect frame=self.tblAllListing.frame;
    frame.size.width=SCREEN_SIZE.width;
    self.tblAllListing.frame=frame;
    
    frame=self.tblMyListing.frame;
    frame.size.width=SCREEN_SIZE.width;
    frame.origin.x=SCREEN_SIZE.width;
    self.tblMyListing.frame=frame;
    frame=self.tblMyListing.frame;
    
    frame= _btnAllListing.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    _btnAllListing.frame=frame;
    
    frame= _btnMyListing.frame;
    frame.size.width=SCREEN_SIZE.width/2;
    frame.origin.x=SCREEN_SIZE.width/2;
    _btnMyListing.frame=frame;
    
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
    float tobbarhig             = CGRectGetHeight(self.tblAllListing.frame);
    float btnhig                = CGRectGetHeight(_tblAllListing.frame);
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
    
    if(_tblAllListing ==tableView){
        return arryMarketplace.count;
    }else{
        return arryMyMarketplace.count;
    }
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
        return 195;
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
    NSDictionary *dict;
    if(_tblAllListing ==tableView){
        dict=[arryMarketplace objectAtIndex:indexPath.row];
    }else{
        dict=[arryMyMarketplace objectAtIndex:indexPath.row];
    }
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSArray *arr=[[dict objectForKey:@"images"] componentsSeparatedByString:@","];
    if(arr.count>0){
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arr[0]];
        banner.imageURL=[NSURL URLWithString:strUrl];
    }
    
    banner.clipsToBounds=YES;
    //banner.layer.cornerRadius=25;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
//    [banner addGestureRecognizer:tap];
//    [banner setUserInteractionEnabled:YES];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"title"];
    [cell.contentView addSubview:name];
    
    
    AsyncImageView *imgGroup=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 170,20,20)];
    imgGroup.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    imgGroup.image=[UIImage imageNamed:@"SendLocation"];
    imgGroup.clipsToBounds=YES;
    [imgGroup setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:imgGroup];
    
    
    UILabel *groupMemberCount = [[UILabel alloc] initWithFrame:CGRectMake(20, 170,SCREEN_SIZE.width-180,20)];
    [groupMemberCount setFont:[UIFont boldSystemFontOfSize:14]];
    groupMemberCount.textAlignment=NSTextAlignmentLeft;
    groupMemberCount.numberOfLines=2;
    groupMemberCount.lineBreakMode=NSLineBreakByWordWrapping;
    groupMemberCount.textColor=[UIColor blackColor];
    groupMemberCount.text=[NSString stringWithFormat:@"%@, %@",[dict objectForKey:@"location"],[dict objectForKey:@"city"]];
    [cell.contentView addSubview:groupMemberCount];
    
    
    
    
    UILabel *lblTlblGroupInfo = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-160, 170,SCREEN_SIZE.width-(SCREEN_SIZE.width-150),20)];
    [lblTlblGroupInfo setFont:[UIFont systemFontOfSize:14]];
    lblTlblGroupInfo.textAlignment=NSTextAlignmentRight;
    lblTlblGroupInfo.numberOfLines=2;
    lblTlblGroupInfo.lineBreakMode=NSLineBreakByWordWrapping;
    lblTlblGroupInfo.textColor=[UIColor orangeColor];
    lblTlblGroupInfo.text=[NSString stringWithFormat:@"$ %@",[dict objectForKey:@"price"]];
    [cell.contentView addSubview:lblTlblGroupInfo];
//
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 193, SCREEN_SIZE.width-40, 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarketPlaceDetailsViewController *cont=[[MarketPlaceDetailsViewController alloc]initWithNibName:@"MarketPlaceDetailsViewController" bundle:nil];
    if(tableView==_tblMyListing){
        cont.dictPost=[arryMyMarketplace objectAtIndex:indexPath.row];
    }else{
        cont.dictPost=[arryMarketplace objectAtIndex:indexPath.row];
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

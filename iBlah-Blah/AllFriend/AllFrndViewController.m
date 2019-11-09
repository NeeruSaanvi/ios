//
//  AllFrndViewController.m
//  iBlah-Blah
//
//  Created by Arun on 02/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AllFrndViewController.h"

@interface AllFrndViewController (){
    NSArray *arryFrnd;
    IndecatorView *ind;
    NSMutableArray *searchResults;
    NSMutableArray *arryRowValue;
    NSMutableArray *arrySelectedValue;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;
    NSString *totalAllPostPage;
}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@end

@implementation AllFrndViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    currentAllPostPage=@"0";
    totalAllPostPage=@"2";
    arrySelectedValue=[[NSMutableArray alloc]init];
    ind=[[IndecatorView alloc]init];
    [self setNavigationBar];
        //mSocket.emit("showAllMyFriends
        // ", user_id);
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllUser"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllMyFriends" with:@[USERID,currentAllPostPage ,@""]];
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllUser"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        if([currentAllPostPage isEqualToString:@"0"]){
            arryFrnd=json;
        }else{
            if(json.count){
                NSMutableArray *arryTemp=[arryFrnd  mutableCopy];
                [arryTemp addObjectsFromArray:json];
                arryFrnd=arryTemp;
            }else{
                self.noMoreResultsAvailAllPost=YES;
                totalAllPostPage=currentAllPostPage;
            }
        }
        self.loadingAllPost=NO;
        NSLog(@"Json %@",json);
        searchResults =[arryFrnd mutableCopy];
        [_tblFrnd reloadData];
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
    
    self.title=@"FRIENDS";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Add" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 40, 32);
    
    [btnClear addTarget:self action:@selector(cmdSave:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)cmdSave:(id)sender{
    if(arrySelectedValue.count>0){
        NSArray *arr=arrySelectedValue;
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:arr forKey:@"DATA"];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"AddTagedFrnd"
         object:self userInfo:dict];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        [AlertView showAlertWithMessage:@"Please select friend first." view:self];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchResults.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
        //    cell = [tableView dequeueReusableCellWithIdentifier:
        //            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:
                cellIdentifier];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    
    NSDictionary *dict=[searchResults objectAtIndex:indexPath.row];
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(10, 10,40,40)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    banner.showActivityIndicator=YES;
     NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    banner.layer.cornerRadius=20;
    [cell.contentView addSubview:banner];
    
    
    UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(60, 10, 160, 40)];
    lblName.backgroundColor=[UIColor clearColor];
    lblName.numberOfLines=2;
    lblName.lineBreakMode=NSLineBreakByWordWrapping;
    lblName.font = [UIFont fontWithName:@"KabelMedium" size:14];
    lblName.textColor=  [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    lblName.text=[dict objectForKey:@"name"];
    lblName.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:lblName];
    

    
    
    if([_searchBar.text isEqualToString:@""])
    {
        
            //        if ([arrySelectedValue containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
            //
            //            banner1.hidden=NO;
            //        }else {
            //            banner1.hidden=YES;
            //        }
        
        for(int i=0; i<arrySelectedValue.count;i++)
        {
            
            if ([[[searchResults objectAtIndex:indexPath.row] valueForKey:@"user_id"] isEqualToString:[[arrySelectedValue objectAtIndex:i] valueForKey:@"user_id"]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                break;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    }
    else
    {
        if(!(arrySelectedValue.count>0))
        {
             cell.accessoryType = UITableViewCellAccessoryNone;
        }
        for(int i=0; i<arrySelectedValue.count;i++)
        {
            
            if ([[[searchResults objectAtIndex:indexPath.row] valueForKey:@"user_id"] isEqualToString:[[arrySelectedValue objectAtIndex:i] valueForKey:@"user_id"]])
            {
                 cell.accessoryType = UITableViewCellAccessoryCheckmark;
                break;
            }
            else
            {
               cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(39, 59,self.view.frame.size.width-40 , 1)];
    sepView.backgroundColor= [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    sepView.alpha=0.3;
    [cell.contentView addSubview:sepView];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([arrySelectedValue containsObject:[searchResults objectAtIndex:indexPath.row]])
    {
        [arrySelectedValue removeObject:[searchResults objectAtIndex:indexPath.row]];
    }
    else
    {
        [arrySelectedValue addObject:[searchResults objectAtIndex:indexPath.row]];
    }
    [self.tblFrnd reloadData];
    [self showPeople];
    
    
}
-(void)showPeople{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    float xAxis=0;
    for (int i=0; i<arrySelectedValue.count; i++)
    {
        NSMutableDictionary *dataDict=[[arrySelectedValue objectAtIndex:i] mutableCopy] ;
            //        [dataDict setObject:@"0" forKey:@"is_host"];
        UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(xAxis, 3, [self getLabelHeight:[dataDict objectForKey:@"name"]], 40)];
        lblName.numberOfLines=2;
        lblName.lineBreakMode=NSLineBreakByWordWrapping;
        lblName.font = [UIFont boldSystemFontOfSize:14];
        lblName.textColor= [UIColor whiteColor];
        lblName.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];;
        lblName.layer.cornerRadius=8;
        lblName.clipsToBounds=YES;
        lblName.text=[dataDict objectForKey:@"name"];
        lblName.textAlignment = NSTextAlignmentCenter;
        [_scrollView addSubview:lblName];
        xAxis=xAxis+[self getLabelHeight:[dataDict objectForKey:@"name"]]+5;
    }
    
    _scrollView.contentSize = CGSizeMake( xAxis, 40);
    if(xAxis>320){
        CGPoint bottomOffset = CGPointMake( self.scrollView.contentSize.width - self.scrollView.bounds.size.width,0);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
    
        //    CGPoint bottomOffset = CGPointMake(0, xAxis);
        //    [self.scrollView setContentOffset:bottomOffset animated:YES];
    
        //[dict setObject:UserName forKey:@"name"];
}
#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, 40);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
}

#pragma mark searchbar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
    
}
-(void)searchBar:(UISearchBar*)searchbar textDidChange:(NSString*)text
{
    if ([text length] == 0)
    {
        searchResults=[arryFrnd mutableCopy];
        arryRowValue=nil;
        arryRowValue=[[NSMutableArray alloc]init];
        for (int i=0; i<searchResults.count; i++) {
            [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.tblFrnd reloadData];
        return;
    }else{
        
       
    }
        //    [arrySelectedValue removeAllObjects];
    [arryRowValue removeAllObjects];
    arryRowValue=nil;
    [searchResults removeAllObjects];
    searchResults=nil;
    searchResults=[[NSMutableArray alloc]init];
    arryRowValue=[[NSMutableArray alloc]init];
    for (int i=0; i<arryFrnd.count; i++) {
        NSDictionary *Dict=[arryFrnd objectAtIndex:i];
        NSString *strName=[Dict objectForKey:@"name"];
        
        NSRange r=[strName rangeOfString:text options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
            [searchResults addObject:Dict];
        }
        
    }
    
    [self.tblFrnd  reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
    
    searchResults=[arryFrnd mutableCopy];
    arryRowValue=nil;
    arryRowValue=[[NSMutableArray alloc]init];
    for (int i=0; i<searchResults.count; i++) {
        [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tblFrnd reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(!([_searchBar.text isEqualToString:@""])){
        return;
    }
    if (!self.loadingAllPost) {
        
        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (endScrolling >= scrollView.contentSize.height)
        {
            self.loadingAllPost=YES;
            int countAllPost=[totalAllPostPage intValue];
            int currentPageAll=[currentAllPostPage intValue];
            if(currentPageAll<countAllPost-1){
                currentPageAll++;
                countAllPost++;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *USERID = [prefs stringForKey:@"USERID"];
                currentAllPostPage=[NSString stringWithFormat:@"%d",currentPageAll];
                totalAllPostPage=[NSString stringWithFormat:@"%d",countAllPost];
                
                [appDelegate().socket emit:@"showAllMyFriends" with:@[USERID,currentAllPostPage ,_searchBar.text]];
                
            }else{
                self.loadingAllPost=NO;
                self.noMoreResultsAvailAllPost=YES;
                [self.tblFrnd reloadData];
                //  [self.tblFrnd reloadData];
            }
        }
    }
}

@end

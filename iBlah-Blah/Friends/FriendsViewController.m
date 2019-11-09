//
//  FriendsViewController.m
//  iBlah-Blah
//
//  Created by webHex on 22/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "FriendsViewController.h"
#import "AGChatViewController.h"
@interface FriendsViewController (){
    NSArray *arryFrnd;
    IndecatorView *ind;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;
    NSString *totalAllPostPage;

}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentAllPostPage=@"0";
    totalAllPostPage=@"2";
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
  //  emit("showAllMyFriends", user_id, page_number, search_text)
   // arryFrnd=@[@"",@"",@"",@"",@"",@"",@"",@"",@"",@""];
     [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
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
        [_tblFriend reloadData];
    }
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
    
    self.title=@"FRIENDS";
    self.navigationController.navigationBarHidden=NO;
}
#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    

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
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 230;//SCREEN_SIZE.width/2;
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
       // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    
    
    if(indexPath.row>=arryFrnd.count){
        
        
        if (!self.noMoreResultsAvailAllPost && (arryFrnd && arryFrnd.count>0)) {
            cell.textLabel.text=nil;
            
            spinner.hidden=NO;
            spinner = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
            CGFloat width = 25;
            CGFloat height = 25;
            
            spinner.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, 12, width, height);
            [cell.contentView addSubview:spinner];
            
            if (indexPath.row>=arryFrnd.count) {
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
            NSDictionary *dict=[arryFrnd objectAtIndex:valueTag];
            
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
            banner.imageURL=[NSURL URLWithString:strUrl];
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
            [btnSendMsg setTitle:@"Send Message" forState:UIControlStateNormal];
            [btnSendMsg addTarget:self action:@selector(cmdSendMsg:) forControlEvents:UIControlEventTouchUpInside];
            btnSendMsg.layer.cornerRadius=20;
            btnSendMsg.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
            btnSendMsg.layer.borderWidth=1;
            [btnSendMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnSendMsg.titleLabel.font=[UIFont boldSystemFontOfSize:14];
            [viewFrame addSubview:btnSendMsg];
            
            [cell.contentView addSubview:viewFrame];
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
                 banner.imageURL=[NSURL URLWithString:strUrl];
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
                [btnSendMsg addTarget:self action:@selector(cmdSendMsg:) forControlEvents:UIControlEventTouchUpInside];
                [btnSendMsg setTitle:@"Send Message" forState:UIControlStateNormal];
               // [btnSendMsg addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
                btnSendMsg.layer.cornerRadius=20;
                btnSendMsg.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
                btnSendMsg.layer.borderWidth=1;
                [btnSendMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                btnSendMsg.titleLabel.font=[UIFont boldSystemFontOfSize:14];
                [viewFrame1 addSubview:btnSendMsg];
                [cell.contentView addSubview:viewFrame1];
                
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark ---------- ScrollView delegate --------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
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
                [self.tblFriend reloadData];
                //  [self.tblFrnd reloadData];
            }
        }
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // [self sendNewIndex:scrollView];
}


#pragma mark searchbar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    currentAllPostPage=@"0";
    totalAllPostPage=@"2";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    [appDelegate().socket emit:@"showAllMyFriends" with:@[USERID,currentAllPostPage ,searchBar.text]];
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{

    currentAllPostPage=@"0";
    totalAllPostPage=@"2";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showAllMyFriends" with:@[USERID,currentAllPostPage ,@""]];
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
}

-(void)cmdSendMsg:(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryFrnd objectAtIndex:btn.tag];
    AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
    R2VC.dictChatData=dict;
    [self.navigationController pushViewController:R2VC animated:YES];
    
}
@end

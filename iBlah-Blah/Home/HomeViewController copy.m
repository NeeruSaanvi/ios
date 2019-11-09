//
//  HomeViewController.m
//  iBlah-Blah
//
//  Created by Arun on 20/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController (){
    NSMutableArray *arryAllPost;
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;

}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     currentAllPostPage=@"1";
      self.noMoreResultsAvailAllPost =NO;
    [self setNavigationBar];
    [self getData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------------- Table View Delegate Methods ------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView==self.tblAllPost){
        if(arryAllPost.count>0){
            return arryAllPost.count+1;
        }else{
            return 1;
        }
    }
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(tableView==self.tblAllPost){
        if(indexPath.row>=arryAllPost.count){
            return 50;
        }
        NSDictionary *dict=[arryAllPost objectAtIndex:indexPath.row];
        if(![[dict objectForKey:@"image"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:[dict objectForKey:@"discription"]]+125;
            
        }
        return  125+[self getLabelHeight:[dict objectForKey:@"discription"]];
    }
    
    return 0;
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
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict;
    if(tableView==_tblAllPost){
        
        
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
        
    }
    
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 20,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    banner.showActivityIndicator=YES;
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        //  baseUrl + "thumb/" + image_name
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"userImage"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    banner.layer.cornerRadius=25;
    [cell.contentView addSubview:banner];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 20,SCREEN_SIZE.width-100,20)];
    [name setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.textColor=[UIColor blackColor];//userChatName
    name.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"username"]];
    [cell.contentView addSubview:name];
    
    UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
    [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
    btnMore.tag=indexPath.row;
    
    if(self.tblAllPost == tableView){
        [btnMore addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [cell.contentView addSubview:btnMore];
    
    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-mm-dd HH:mm:ss"];//EEE MMM dd HH:mm:ss z yyyy
    NSDate *date = [dateFormat dateFromString:strDate];
    [dateFormat setDateFormat:@"EEE MMM dd yyyy HH:mm"];
    NSString *strDatetoShow=[dateFormat stringFromDate:date];
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(75, 40,SCREEN_SIZE.width-110,20)];
    [time setFont:[UIFont fontWithName:@"OpenSans-Italic" size:12]];
    time.textAlignment=NSTextAlignmentLeft;
    time.numberOfLines=2;
    time.textColor=[UIColor darkGrayColor];
    time.text=strDatetoShow;
    time.alpha=0.6;
    [cell.contentView addSubview:time];
    
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
    [cell.contentView addSubview:status];
    
    UIButton *btnLike=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-52, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 40, 32)];
    [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
//    countLikes = 4;
//    countcomments = 2;
//view_count
    [btnLike setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countLikes"]] forState:UIControlStateNormal];
    [cell.contentView addSubview:btnLike];
    
    if(self.tblAllPost ==tableView){
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];
        
    }
    btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLike.layer.cornerRadius=8;//0,160,223
    btnLike.layer.borderWidth=1;
    btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    
    btnLike.tag=indexPath.row;
    
    
    
    UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-100, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 40, 32)];
    [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"countcomments"]] forState:UIControlStateNormal];
    if(self.tblAllPost ==tableView){
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllPost:)
             forControlEvents:UIControlEventTouchUpInside];
        
    }
    btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnComment.layer.cornerRadius=8;//0,160,223
    btnComment.layer.borderWidth=1;
    btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnComment.tag=indexPath.row;
    
    [cell.contentView addSubview:btnComment];
    
    UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 40, 32)];
    [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    if(self.tblAllPost ==tableView){
        [btnShare addTarget:self
                     action:@selector(cmdShareAllPost:)
           forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    btnShare.tag=indexPath.row;
    btnShare.layer.cornerRadius=8;//0,160,223
    btnShare.layer.borderWidth=1;
    btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [cell.contentView addSubview:btnShare];
    
    
    UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-148, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 40, 32)];
    [btnView setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    if(self.tblAllPost ==tableView){
        [btnView addTarget:self
                     action:@selector(cmdShareAllPost:)
           forControlEvents:UIControlEventTouchUpInside];
        
    }
     [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
    btnView.layer.cornerRadius=8;//0,160,223
    btnView.layer.borderWidth=1;
    btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    btnView.tag=indexPath.row;
     btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [cell.contentView addSubview:btnView];
    
    if(!([[dict objectForKey:@"image"] isEqualToString:@""])){
        AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:[dict objectForKey:@"discription"]]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost.showActivityIndicator=YES;
        bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
         NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
        bannerPost.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost.clipsToBounds=YES;
        bannerPost.layer.cornerRadius=10;
        [cell.contentView addSubview:bannerPost];
        bannerPost.userInteractionEnabled=YES;
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
        [bannerPost addGestureRecognizer:tap];
        [bannerPost setUserInteractionEnabled:YES];
        
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-52, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 40, 32);
        btnComment.frame=CGRectMake(SCREEN_SIZE.width-100, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 40, 32);
        btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 40, 32);
        btnView.frame=CGRectMake(SCREEN_SIZE.width-148, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 40, 32);
    }
    
   
    
//    UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(10, totalComment.frame.origin.y+21,SCREEN_SIZE.width-20 , 1)];
//    sepUpView.backgroundColor=[UIColor darkGrayColor];
//    sepUpView.alpha=0.4;
//    [cell.contentView addSubview:sepUpView];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hedderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 50)];
    UIButton *btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEdit addTarget:self
               action:@selector(cmdEdit:)
     forControlEvents:UIControlEventTouchUpInside];//camera editPost
    [btnEdit setImage:[UIImage imageNamed:@"editPost"] forState:UIControlStateNormal];
    btnEdit.frame = CGRectMake(0, 0, SCREEN_SIZE.width/3, 50);
    [hedderView addSubview:btnEdit];
    
    UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCamera addTarget:self
                action:@selector(cmdCamera:)
      forControlEvents:UIControlEventTouchUpInside];
    [btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    btnCamera.frame = CGRectMake(SCREEN_SIZE.width/3, 0, SCREEN_SIZE.width/3, 50);
    [hedderView addSubview:btnCamera];
    
    UIButton *btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLocation addTarget:self
                  action:@selector(cmdLocation:)
        forControlEvents:UIControlEventTouchUpInside];
    [btnLocation setImage:[UIImage imageNamed:@"SendLocation"] forState:UIControlStateNormal];
    btnLocation.frame = CGRectMake((SCREEN_SIZE.width/3)*2, 0, SCREEN_SIZE.width/3, 50);
    [hedderView addSubview:btnLocation];
    
    hedderView.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    return hedderView;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
-(void)cmdCamera:(id)sender{
    
}
-(void)cmdEdit:(id)sender{
    
}
-(void)cmdLocation:(id)sender{
    
}
#pragma mark ---------- ScrollView delegate --------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
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
                
                [self performSelector:@selector(getDataInBackground) withObject:nil afterDelay:1];
            }else{
                self.loadingAllPost=NO;
                self.noMoreResultsAvailAllPost=YES;
                [self.tblAllPost reloadData];
                    //  [self.tblFrnd reloadData];
            }
        }
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
   // [self sendNewIndex:scrollView];
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
    
    self.title=@"Home";
    self.navigationController.navigationBarHidden=NO;
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
  //  UIButton* btn = sender;
    //NSDictionary *dict=[arryAllPost objectAtIndex:btn.tag];
  //  NSString* postId =[dict objectForKey:@"cpId"];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Report Abuse"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                  
                                   
                               }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
    [alert addAction:btnAbuse];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)cmdShareAllPost:(id)sender{
}
- (void)bigButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
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
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
        // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}

-(void)cmdLikeAllPost:(id)sender{
    //UIButton *btn=(UIButton *)sender;
   // NSDictionary *dict=[arryAllPost objectAtIndex:btn.tag];
        //    MouthyPointViewController *cont=[[MouthyPointViewController alloc]initWithNibName:@"MouthyPointViewController" bundle:nil];
        //    cont.dictData=dict;
        //    [self.navigationController presentViewController:cont animated:YES completion:nil];
}

-(void)cmdCommentAllPost:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryAllPost objectAtIndex:btn.tag];
        //    CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        //    cont.dictPost=dict;
        //    [self.navigationController presentViewController:cont animated:YES completion:nil];
}
#pragma mark api
-(void)getData{
    
    IndecatorView *ind=[[IndecatorView   alloc]init];
    [self.view addSubview:ind];
    [[ApiClient sharedInstance]getPost:currentAllPostPage success:^(id responseObject) {
        [ind removeFromSuperview];
        NSDictionary *dict=responseObject;
        arryAllPost=[[dict objectForKey:@"posts"] mutableCopy];
        totalAllPostPage =[dict objectForKey:@"post_number"];
        
        [_tblAllPost reloadData];
        
    } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
        [ind removeFromSuperview];
    }];
}
-(void)getDataInBackground{
    
    [[ApiClient sharedInstance]getPost:currentAllPostPage success:^(id responseObject) {
        self.loadingAllPost=NO;
       
        
        NSDictionary *dict=responseObject;
      
        int countAllPost=[totalAllPostPage intValue];
        int currentPageAll=[currentAllPostPage intValue];
        if(currentPageAll<countAllPost-1){
            [arryAllPost addObjectsFromArray:[[dict objectForKey:@"posts"] mutableCopy]];
        }else{
            if(currentPageAll==1){
                arryAllPost=[[dict objectForKey:@"posts"] mutableCopy];
            }else{
                [arryAllPost addObjectsFromArray:[[dict objectForKey:@"posts"] mutableCopy]];
            }
        }
        if([currentAllPostPage isEqualToString:@"1"]){
            arryAllPost=[[dict objectForKey:@"data"] mutableCopy];
        }
        [_tblAllPost reloadData];
    } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
        
    }];
}
@end

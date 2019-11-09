//
//  HomeViewController.m
//  iBlah-Blah
//
//  Created by Arun on 20/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "HomeViewController.h"
#import "DSCellDetail.h"
    //import your custom cell
#import "DSPhotoCell.h"
#import "AddPostViewController.h"
#define KEY_INDEXPATH         @"indexPath"
@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>{
    NSMutableArray *arryAllPost;
    NSString *totalAllPostPage;
    NSString  *currentAllPostPage;
    DGActivityIndicatorView *spinner;

}
@property (nonatomic) BOOL noMoreResultsAvailAllPost;
@property (nonatomic) BOOL loadingAllPost;



@property (strong, nonatomic) NSArray *cardDetailsArray;
@property (nonatomic,readwrite)NSMutableDictionary *postDict;
@property (strong, nonatomic) IBOutlet UITableView *timeLineTableView;
@property (strong,nonatomic) NSDictionary *timeLineDetails;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"UpdatePost"
                                               object:nil];
    
     currentAllPostPage=@"0";
    self.noMoreResultsAvailAllPost =NO;
    self.timeLineTableView.emptyDataSetSource = self;
    self.timeLineTableView.emptyDataSetDelegate = self;
    [self.timeLineTableView registerNib:[UINib nibWithNibName:@"DSPhotoCell" bundle:nil] forCellReuseIdentifier:@"DSPhotoCell"];
    self.timeLineTableView.estimatedRowHeight = 465;
    self.timeLineTableView.rowHeight = UITableViewAutomaticDimension;
    [self.timeLineTableView setDataSource:self];
    [self.timeLineTableView setDelegate:self];
    [self.timeLineTableView reloadData];
    
    
    [self setNavigationBar];
    [self getData];
   // [self setTableView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"UpdatePost"]) {
           currentAllPostPage=@"0";
          [self getDataInBackground];
    }
}
#pragma mark ------------- Table View Delegate Methods ------------
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Posts found!";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.000 green:0.718 blue:0.137 alpha:1.00]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithHex:@"F3F3F3"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -35.0;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 10.0f;
}

#pragma mark - DZNEmptyDataSetDelegate Methods
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return NO;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma setup table view delegates and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cardDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DSPhotoCell* Cell = [tableView dequeueReusableCellWithIdentifier:@"DSPhotoCell" forIndexPath:indexPath];
    _postDict = [NSMutableDictionary dictionaryWithDictionary:[_cardDetailsArray objectAtIndex:indexPath.row]];
    [_postDict setObject:indexPath forKey:KEY_INDEXPATH];
    Cell.embededDetails = _postDict;
    NSArray *mediaList =  [_postDict objectOrNilForKey:@"medialist"];
    if (mediaList.count>0) {
        [Cell loadEmbedPhotos:mediaList];
    }
    [Cell laodCellContents];
    [Cell.contentView layoutIfNeeded];
    return Cell;
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
    AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
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


#pragma mark api
-(void)getData{
    
    IndecatorView *ind=[[IndecatorView   alloc]init];
    [self.view addSubview:ind];
    [[ApiClient sharedInstance]getPost:currentAllPostPage success:^(id responseObject) {
        [ind removeFromSuperview];
        NSDictionary *dict=responseObject;
        arryAllPost=[[dict objectForKey:@"posts"] mutableCopy];
        totalAllPostPage =[dict objectForKey:@"post_number"];
        
       [self setTableView];;
        
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
        if([currentAllPostPage isEqualToString:@"0"]){
            arryAllPost=[[dict objectForKey:@"data"] mutableCopy];
        }
        [self setTableView];;
        [_tblAllPost reloadData];
    } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
        
    }];
}
-(void)dealloc{
        // ****** Do this only if the memory warnig causes crash *****//
    self.timeLineTableView.emptyDataSetSource = nil;
    self.timeLineTableView.emptyDataSetDelegate = nil;
}
-(void)setTableView{
    
    NSMutableArray *tableData=[[NSMutableArray alloc]init];

    for (int i=0; i<arryAllPost.count; i++) {
        NSDictionary *dict=[arryAllPost objectAtIndex:i];
        //image
        NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-mm-dd HH:mm:ss"];//EEE MMM dd HH:mm:ss z yyyy
        NSDate *date = [dateFormat dateFromString:strDate];
        long timesemp=[date timeIntervalSince1970];
        NSString *strImageList=[dict objectForKey:@"image"];
        NSArray *arr = [strImageList componentsSeparatedByString:@","];
        NSMutableArray *imageList=[[NSMutableArray alloc]init];
        
        for (int i=0; i<arr.count; i++) {
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            NSString *strImgName=arr[i];
            if(strImgName.length>0){
                NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arr[i]];
                [dict setObject:strUrl forKey:@"mediaurl"];
                [imageList addObject:dict];
            }
           
        }
        
        NSString *strLat=[dict objectForKey:@"lat"];
        NSString *strLon=[dict objectForKey:@"lon"];
        
        if(strLat.length>0 && strLon.length>0){
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            //
            NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",strLat,strLon,strLat,strLon];
            [dict setObject:strUrl forKey:@"mediaurl"];
            [imageList addObject:dict];
        }
        NSMutableDictionary *dictFortable=[[NSMutableDictionary alloc]init];
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"userImage"]];
        
         [dictFortable setObject:[dict objectForKey:@"username"] forKey:@"author"];
         [dictFortable setObject:[dict objectForKey:@"username"] forKey:@"ownerName"];
         [dictFortable setObject:strUrl forKey:@"photo"];
         [dictFortable setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]] forKey:@"favorited"];
         [dictFortable setObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"countcomments"]] forKey:@"favoritecnt"];
        if(imageList.count>0){
             [dictFortable setObject:imageList forKey:@"medialist"];
        }else{
             [dictFortable setObject:[NSArray new] forKey:@"medialist"];
        }
         [dictFortable setObject:[NSString stringWithFormat:@"%lu",timesemp] forKey:@"modifieddate"];
         [dictFortable setObject:[dict objectForKey:@"discription"] forKey:@"contenttext"];
        [tableData addObject:dictFortable];
    }
    
    _cardDetailsArray=tableData;
    [_timeLineTableView reloadData];
   
}

@end

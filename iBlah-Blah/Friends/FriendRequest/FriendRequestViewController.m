//
//  FriendRequestViewController.m
//  iBlah-Blah
//
//  Created by Arun on 26/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "FriendRequestViewController.h"

@interface FriendRequestViewController (){
    NSArray *arryFrndRequest;
    IndecatorView *ind;
}

@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationBar];
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"FrndRequest"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
     [appDelegate().socket emit:@"getAllFriendRequest" with:@[USERID]];
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
    
    if ([[notification name] isEqualToString:@"FrndRequest"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryFrndRequest=json;
        [_tblFrndRequest reloadData];
        NSLog(@"%@",json);
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
    
    self.title=@"FRIEND REQUESTS";
    self.navigationController.navigationBarHidden=NO;

}
#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    
    return arryFrndRequest.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
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
        //cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict=[arryFrndRequest objectAtIndex:indexPath.row];
    

    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 5,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    banner.layer.cornerRadius=25;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
    [banner addGestureRecognizer:tap];
    [banner setUserInteractionEnabled:YES];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 5,self.view.frame.size.width-190,20)];
    [name setFont:[UIFont boldSystemFontOfSize:14]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"name"];
    [cell.contentView addSubview:name];
    
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(75, 27,SCREEN_SIZE.width-175,20)];
    [lblText setFont:[UIFont systemFontOfSize:11 ]];
    lblText.textAlignment=NSTextAlignmentLeft;
    lblText.numberOfLines=2;
    lblText.lineBreakMode=NSLineBreakByWordWrapping;
    lblText.textColor=[UIColor blackColor];
    [cell.contentView addSubview:lblText];
    lblText.text=[NSString stringWithFormat:@"has sent you friend request"];
    
    
    
    
    
    UIButton *btnAccept = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-60, 5, 50, 22)];
    [btnAccept addTarget:self
                  action:@selector(cmdAccept:)
        forControlEvents:UIControlEventTouchUpInside];
    btnAccept.tag=indexPath.row;
    btnAccept.backgroundColor=[UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1.0];
    [btnAccept setTitle:@"Accept" forState:UIControlStateNormal];
    [btnAccept setBackgroundColor:[UIColor colorWithRed:31/255.0 green:152/255.0 blue:207/255.0 alpha:1.0]];////31,152,207
    btnAccept.layer.cornerRadius=4;
    [btnAccept.titleLabel setFont:[UIFont boldSystemFontOfSize:10 ]];
    [cell.contentView  addSubview:btnAccept];
    
    UIButton *btnReject = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-115, 5, 50, 22)];
    [btnReject addTarget:self
                  action:@selector(cmdReject:)
        forControlEvents:UIControlEventTouchUpInside];
    btnReject.tag=indexPath.row;
    btnReject.backgroundColor=[UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1.0];
    [btnReject setTitle:@"Reject" forState:UIControlStateNormal];
    [btnReject setBackgroundColor:[UIColor clearColor]];//255,64,129
    [btnReject setTitleColor:[UIColor colorWithRed:255/255.0 green:64/255.0 blue:204/255.0 alpha:1.0] forState:UIControlStateNormal];
    btnReject.layer.cornerRadius=4;
    btnReject.layer.borderColor=[UIColor colorWithRed:255/255.0 green:64/255.0 blue:204/255.0 alpha:1.0].CGColor;
    btnReject.layer.borderWidth=1;
    [btnReject.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
    [cell.contentView  addSubview:btnReject];
    
    
    
    return cell;
}

-(void)cmdAccept:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryFrndRequest objectAtIndex:btn.tag];
  // mSocket.emit("acceptFriendRequest", user_id, sender_id,  UserName , UserImage, friendRequestid, sender_name )
//    {
//        "from_id" = "daa843b2-05c3-45c0-be84-9a6ce5b993f4";
//        id = "10ea56c0-4929-11e8-acb5-253ef70f2e59";
//        image = "1523779766_9135749998.png";
//        name = "Goru Sarswa";
//        time = "2018-04-26T08:08:56.000Z";
//        "to_id" = "5d12dbf3-82f2-45b9-8fde-3ef69a187092"; //Perez Ivan, 1519410306_2534903982.png
//    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 NSString *Username = [prefs stringForKey:@"username"];
    NSString *strSenderId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"from_id"]];
    NSString *strUserName=[NSString stringWithFormat:@"%@", Username];
    NSString *strImage=[NSString stringWithFormat:@"%sthumb/1519410306_2534903982.png",BASEURl];
    NSString *strfriendRequestid=[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSString *strsender_name=[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"acceptFriendRequest" with:@[USERID,strSenderId,strUserName,strImage,strfriendRequestid,strsender_name]];
    [self performSelector:@selector(callApi) withObject:nil afterDelay:3.0];
    
    NSMutableArray *arryTemp=[arryFrndRequest mutableCopy];
    [arryTemp removeObjectAtIndex:btn.tag];
    arryFrndRequest=arryTemp;
    [_tblFrndRequest reloadData];
    
}
-(void)callApi{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllFriendRequest" with:@[USERID]];
    
}
-(void)cmdReject:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryFrndRequest objectAtIndex:btn.tag];
        //emit("rejectFriendRequest",  user_id, requestID)
    NSString *strfriendRequestid=[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"rejectFriendRequest" with:@[USERID,strfriendRequestid]];
    [self performSelector:@selector(callApi) withObject:nil afterDelay:3.0];
    
    NSMutableArray *arryTemp=[arryFrndRequest mutableCopy];
    [arryTemp removeObjectAtIndex:btn.tag];
    arryFrndRequest=arryTemp;
    [_tblFrndRequest reloadData];
    
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
@end

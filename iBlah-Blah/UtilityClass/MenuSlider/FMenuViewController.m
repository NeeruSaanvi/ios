//
//  FMenuViewController.m
//  FootballApp
//
//  Created by Ambika on 22/07/14.
//  Copyright (c) 2014 Manpreet Singh. All rights reserved.
//

#import "FMenuViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "AsyncImageView.h"
#import "GroupViewController.h"
#import "HomeViewController.h"
#import "PagesViewController.h"
#import "MarketplaceViewController.h"
#import "EventViewController.h"
#import "SettingViewController.h"
#import "LanguageViewController.h"
#import "BlogViewController.h"
#import "VideoViewController.h"
#import "FriendsViewController.h"
#import "AllUserViewController.h"
#import "FriendRequestViewController.h"
#import "LoginViewController.h"
#import "QBCore.h"
#import "SideMenuCollectionViewCell.h"
#import "AddImageViewController.h"
#import "PreviewOfPicViewController.h"

@interface FMenuViewController (){
    NSArray *arryMenu;
    NSArray *arryMenuImage;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *viewProfileBG;

@end

@implementation FMenuViewController
@synthesize menuTbleVw;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // [self setNeedsStatusBarAppearanceUpdate];
    
    // self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting-bg.png"]];
    // self.menuTbleVw.backgroundColor = [UIColor clearColor];
    //self.bgImgVw.image = [UIImage imageNamed:@"menu_bg.png"];
    //self.bgImgVw.image = [UIImage imageNamed:@"menu_bgnew.png"];
    
   arryMenu =@[@"Feeds",
      @"Group",
      @"Marketplace",
      @"Event",
      @"Friends",
      @"Friend Requests",
      @"All Members",@"All Blogs",@"Settings",@"Videos",@"Share App",@"Logout"];
    
    
    arryMenuImage =@[@"FEEDS",
                @"GROUPS",
                @"MARKET",
                @"EVENTS",
                @"FRIENDS",
                @"ADDFRIENDS", @"MEMBERS",@"BLOGS",@"SETTINGS",@"MUSIC",@"SHARE-1",@"LOGOUT"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Address Found"
                                               object:nil];
    
    //self.menuTbleVw.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"setting-bg.png"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProfileEdited:) name:@"profileEditedNotification" object:nil];
    self.menuTbleVw.backgroundColor=[UIColor clearColor];
}



-(void)ProfileEdited:(NSNotification *)notification
{
    [self.menuTbleVw reloadData];
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"Address Found"]) {
        // NSLog(@"changenotifion");
        
        //[ menuTbleVw reloadData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self.imgProfilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%simages/%@",BASEURl,[defaults valueForKey:@"profile_pic"]]] placeholderImage:nil];
    self.viewProfileBG.layer.borderColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    self.viewProfileBG.layer.borderWidth = 2;
    self.viewProfileBG.layer.cornerRadius = self.viewProfileBG.frame.size.height/2;

    self.imgProfilePic.layer.borderColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    self.imgProfilePic.layer.borderWidth = 1;
    self.imgProfilePic.layer.cornerRadius = self.imgProfilePic.frame.size.height/2;
    self.imgProfilePic.clipsToBounds = YES;

    self.lblName.text = [defaults valueForKey:@"username"];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPorfilePic:)];
    [self.imgProfilePic addGestureRecognizer:gesture];
}


-(void)viewPorfilePic:(UITapGestureRecognizer *)gesture
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        PreviewOfPicViewController *preview = [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"PreviewOfPicViewController"];
        preview.imgArray = @[[NSString stringWithFormat:@"%simages/%@",BASEURl,[defaults valueForKey:@"profile_pic"]]];
        [self presentViewController:preview animated:YES completion:nil];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}




#pragma mark collectionview delegate

#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return arryMenu.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"cell";

    SideMenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        //    NSArray *nib;
        //        nib = [[NSBundle mainBundle] loadNibNamed:@"HomeFeedCustomCell" owner:self options:nil];
        //        cell = [nib objectAtIndex:1];

        cell = (SideMenuCollectionViewCell *)[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:identifier];

        //        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }


    cell.imgMenu.image = [UIImage imageNamed:[arryMenuImage objectAtIndex:indexPath.row]];

    cell.lblName.text = [arryMenu objectAtIndex:indexPath.row];

    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat width = (CGRectGetWidth(self.view.frame)/3.0f) - 15;
    return CGSizeMake(width, (width * 1.1f));
}




- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UINavigationController *navigationController = [SupportClass getNavigationController];

    if(indexPath.row==0){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];
    }else if (indexPath.row==1){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[GroupViewController alloc]init]];
    }else if (indexPath.row==20){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[PagesViewController alloc]init]];
    }else if (indexPath.row==2){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[MarketplaceViewController alloc]init]];
    }else if (indexPath.row==3){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[EventViewController alloc]init]];
    }else if (indexPath.row==4){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[FriendsViewController alloc]init]];
    }else if (indexPath.row==5){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[FriendRequestViewController alloc]init]];
    }else if (indexPath.row==6){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[AllUserViewController alloc]init]];
    }else if (indexPath.row==7){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[BlogViewController alloc]init]];
    }else if (indexPath.row==8){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[SettingViewController alloc]init]];
    }else if (indexPath.row==111){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[LanguageViewController alloc]init]];
    }else if (indexPath.row==10){
        NSArray *Items   = [NSArray arrayWithObjects:
                            @"Get the most astounding evaluated bombastic application for iOS and Android, Love the delightful way the iBlah-Blah look",@"https://itunes.apple.com/in/app/iblah-blah-for-iphone/id1192127152?mt=8",@"https://play.google.com/store/apps/details?id=com.iblahblahapp.app",[UIImage imageNamed:@"Logo"] ,nil];

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
    }else if (indexPath.row==9){
        self.sidePanelController.centerPanel = [navigationController initWithRootViewController:[[VideoViewController alloc]init]];
    }else if (indexPath.row==11){
        [self resetDefaults];
        self.sidePanelController.centerPanel = [navigationController  initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    }

}



#pragma mark ----------------------------------- UITableViewDataSource --------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryMenu.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 44;
    }
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    }
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 6,32,32)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    banner.showActivityIndicator=YES;
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        //  baseUrl + "thumb/" + image_name
    banner.image=[UIImage imageNamed:arryMenuImage[indexPath.row]];
    banner.clipsToBounds=YES;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(55, 0,SCREEN_SIZE.width-100,44)];
    [name setFont:[UIFont boldSystemFontOfSize:14]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.textColor=[UIColor blackColor];
    name.text=arryMenu[indexPath.row];
    [cell.contentView addSubview:name];
    
   // cell.textLabel.text=arryMenu[indexPath.row];
    
    cell.backgroundColor=[UIColor whiteColor];
    
    if(!(indexPath.row==0)){
        UIView *sep=[[UIView alloc]initWithFrame:CGRectMake(0, 43,menuTbleVw.frame.size.width, 0.5)];
        sep.backgroundColor=[UIColor darkGrayColor];
        [cell.contentView addSubview:sep];
    }
    
    return cell;
}

-(void)EditBtnAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles:@"Notifications",@"Edit Profile", @"More",@"Logout", nil];
    [actionSheet showInView:self.view];
    
    
}



//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//    return 95;
//
//}
//
//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerVw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, menuTbleVw.frame.size.width, 50)];
//    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(headerVw.frame.origin.x, headerVw.frame.origin.y+20, headerVw.frame.size.width, 30)];
//
//    lbl.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:51.0/255.0 alpha:0.5];
//
//
//    lbl.font = [UIFont fontWithName:@"Helvetica" size:18.0];
//    NSDictionary *sectionname=[CatData objectAtIndex:section];
//
//    lbl.text = [sectionname objectForKey:@"categoryname"];
//    [headerVw addSubview:lbl];
//    UIView *lineVw = [[UIView alloc]initWithFrame:CGRectMake(5, lbl.frame.origin.y+lbl.frame.size.height+2, headerVw.frame.size.width, 1)];
//    lineVw.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"separator_line_new.png"                                          ]];
//    [headerVw addSubview:lineVw];
//
//    return headerVw;
//
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0)
//        return 0;
//    else
//        return 60;
//}

#pragma mark ------------------------------ UITableViewDelegate --------------------------------

NSIndexPath *selectedindexpath;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if(indexPath.row==1){
         self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"HomeViewController"]];
    }else if (indexPath.row==2){
         self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[GroupViewController alloc]init]];
    }else if (indexPath.row==20){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[PagesViewController alloc]init]];
    }else if (indexPath.row==3){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[MarketplaceViewController alloc]init]];
    }else if (indexPath.row==4){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[EventViewController alloc]init]];
    }else if (indexPath.row==5){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[FriendsViewController alloc]init]];
    }else if (indexPath.row==6){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[FriendRequestViewController alloc]init]];
    }else if (indexPath.row==7){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[AllUserViewController alloc]init]];
    }else if (indexPath.row==8){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[BlogViewController alloc]init]];
    }else if (indexPath.row==9){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SettingViewController alloc]init]];
    }else if (indexPath.row==111){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[LanguageViewController alloc]init]];
    }else if (indexPath.row==11){
        NSArray *Items   = [NSArray arrayWithObjects:
                            @"Get the most astounding evaluated bombastic application for iOS and Android, Love the delightful way the iBlah-Blah look",@"https://itunes.apple.com/in/app/iblah-blah-for-iphone/id1192127152?mt=8",@"https://play.google.com/store/apps/details?id=com.iblahblahapp.app",[UIImage imageNamed:@"Logo"] ,nil];
        
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
    }else if (indexPath.row==10){
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[VideoViewController alloc]init]];
    }else if (indexPath.row==12){
        [self resetDefaults];
        self.sidePanelController.centerPanel = [[SupportClass getNavigationController] initWithRootViewController:[[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    }
    
}
- (void)resetDefaults {
    
    
     [Core logout];
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}


- (IBAction)cmdBack:(id)sender {
//    if(checkcat==0){
//        self.btnback.hidden=YES;
//    }else if(checkcat==1){
//        checkcat=0;
//        CATransition *transition = [CATransition animation];
//        transition.type = kCATransitionPush;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        transition.fillMode = kCAFillModeForwards;
//        transition.duration = 0.3;
//        transition.subtype = kCATransitionFromLeft;
//
//        [menuTbleVw.layer addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
//        [menuTbleVw reloadData];
//        self.btnback.hidden=YES;
//    }else if(checkcat==2){
//        checkcat=1;
//        CATransition *transition = [CATransition animation];
//        transition.type = kCATransitionPush;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        transition.fillMode = kCAFillModeForwards;
//        transition.duration = 0.3;
//        transition.subtype = kCATransitionFromLeft;
//
//        [menuTbleVw.layer addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
//        [menuTbleVw reloadData];
//    }
}
@end

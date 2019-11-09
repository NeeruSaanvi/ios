//
//  MarketPlaceDetailsViewController.m
//  iBlah-Blah
//
//  Created by Arun on 06/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "MarketPlaceDetailsViewController.h"
#import "HPGrowingTextView.h"
#import "AddMarketPlaceViewController.h"
#import "AGChatViewController.h"
#import "RecentChatListViewController.h"
@interface MarketPlaceDetailsViewController ()<HPGrowingTextViewDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
    NSArray *arrComments;
    NSDictionary *dictMarketPlaceDetails;
     IndecatorView *ind;
}

@end

@implementation MarketPlaceDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
  //mSocket.emit("getcmntsListing", user_id, post_id);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MarketPlaceDetails"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MarketPlaceLikeDetails"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"ALLComment"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tblMarketPlaceDetails addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
                _viewHeadder.frame=CGRectMake(_viewHeadder.frame.origin.x, _viewHeadder.frame.origin.y, SCREEN_SIZE.width, 85);
            //    _tblMarketPlaceDetails.frame=CGRectMake(_tblMarketPlaceDetails.frame.origin.x, 85, SCREEN_SIZE.width, SCREEN_SIZE.height-85-50);
                break;
            default:
                printf("unknown");
        }
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    _lblHeadder.frame=CGRectMake(0, _lblHeadder.frame.origin.y, SCREEN_SIZE.width, _lblHeadder.frame.size.height);
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    [appDelegate().socket emit:@"showDetailLists" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    
    
   
    
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"MarketPlaceDetails"]) {
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];

        arrComments =[Arr objectAtIndex:1];
        [_tblMarketPlaceDetails reloadData];
    }else if([[notification name] isEqualToString:@"MarketPlaceLikeDetails"]){
          [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        if(json.count>0){
            dictMarketPlaceDetails=[json objectAtIndex:0];
        }
        
        NSString *strUserId=[dictMarketPlaceDetails objectForKey:@"user_id"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        if([strUserId isEqualToString:USERID]){
            NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
            UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnClear setTitle:@"More" forState:UIControlStateNormal];
            btnClear.frame = CGRectMake(0, 0, 50, 13);
            
            [btnClear addTarget:self action:@selector(cmdDone:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
            [arrRightBarItems addObject:btnSearchBar];
            self.navigationItem.rightBarButtonItems=arrRightBarItems;
        }
        
        
        [_tblMarketPlaceDetails reloadData];
    }else   if ([[notification name] isEqualToString:@"ALLComment"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        
        arrComments = [Arr objectAtIndex:1];
        NSString *strCount=[NSString stringWithFormat:@"%lu",arrComments.count];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:strCount forKey:@"countcomments"];
        _dictPost=dictNew;
        
        
        [_tblMarketPlaceDetails reloadData];
    }
}
- (void) hideKeyboard {
    [self.view endEditing:YES];
}
- (IBAction)cmdBack:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(SCREEN_SIZE.width-70, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title=@"Detail";
    [super viewWillAppear:animated];
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    containerView.backgroundColor=[UIColor colorWithRed:31/255.0 green:152/255.0 blue:207/255.0 alpha:1.0];//31,152,207
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, self.view.frame.size.width-69, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];//0,153,204
    textView.placeholder = @"Type to Comment...";
    
    
    [self.view addSubview:containerView];
    
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    [containerView addSubview:textView];
    
    
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"Post" forState:UIControlStateNormal];
    [doneBtn addTarget:self
                action:@selector(cmdAddComment)
      forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//0,153,204
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    [textView.layer setShadowColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1.0].CGColor];
    [textView.layer setShadowOpacity:1.0];
    [textView.layer setShadowRadius:3.0];
    [textView.layer setCornerRadius:5];
    [textView.layer setShadowOffset:CGSizeMake(1, 1)];
    textView.layer.masksToBounds = NO;
    
    [containerView.layer setShadowColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0].CGColor];
    [containerView.layer setShadowOpacity:1.0];
    [containerView.layer setShadowRadius:3.0];
    [containerView.layer setCornerRadius:0];
    [containerView.layer setShadowOffset:CGSizeMake(1, 1)];
    containerView.layer.masksToBounds = YES;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 395+20;
    }else{
            NSDictionary *dict=[arrComments objectAtIndex:indexPath.row];
        return 90+[self getLabelHeight:[dict objectForKey:@"comment"]];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return 1;
    else
        return  arrComments.count;//arrComments.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.backgroundColor=[UIColor clearColor];
    
    if(indexPath.section==0){
        
//        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
//        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
//        NSArray *arr=[[_dictPost objectForKey:@"images"] componentsSeparatedByString:@","];
//        if(arr.count>0){
//            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arr[0]];
//            banner.imageURL=[NSURL URLWithString:strUrl];
//        }
//
//        banner.clipsToBounds=YES;
//            //banner.layer.cornerRadius=25;
//        [banner setContentMode:UIViewContentModeScaleAspectFill];
//        [cell.contentView addSubview:banner];
        NSArray *arr=[[_dictPost objectForKey:@"images"] componentsSeparatedByString:@","];
        UIScrollView *scrollView=[[UIScrollView   alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        scrollView.pagingEnabled=YES;
        scrollView.showsVerticalScrollIndicator=NO;
        scrollView.showsHorizontalScrollIndicator=NO;
        int XAxix=0;
        for (int i=0; i<arr.count; i++) {
            AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(XAxix, 0,SCREEN_SIZE.width,150)];
            banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arr[i]];
            banner.imageURL=[NSURL URLWithString:strUrl];
            banner.clipsToBounds=YES;
            [banner setContentMode:UIViewContentModeScaleAspectFill];
            [scrollView addSubview:banner];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
            [banner addGestureRecognizer:tap];
            [banner setUserInteractionEnabled:YES];

            XAxix=XAxix+SCREEN_SIZE.width;
        }
        scrollView.contentSize = CGSizeMake(XAxix,110);
        [cell.contentView addSubview:scrollView];
        
        UIImageView *imgLeft=[[UIImageView alloc]initWithFrame:CGRectMake(2, 75, 6, 12)];
        imgLeft.image=[UIImage imageNamed:@"left_arrow"];
        [cell.contentView addSubview:imgLeft];
        
        UIImageView *imgRight=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-14, 75, 6, 12)];
        imgRight.image=[UIImage imageNamed:@"right_arrow"];
        [cell.contentView addSubview:imgRight];

        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
        [name setFont:[UIFont boldSystemFontOfSize:16]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textColor=[UIColor blackColor];
        name.text=[_dictPost objectForKey:@"title"];
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
        groupMemberCount.text=[NSString stringWithFormat:@"%@, %@",[_dictPost objectForKey:@"location"],[_dictPost objectForKey:@"city"]];
        [cell.contentView addSubview:groupMemberCount];
        
        UILabel *lblTlblGroupInfo = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-160, 170,SCREEN_SIZE.width-(SCREEN_SIZE.width-150),20)];
        [lblTlblGroupInfo setFont:[UIFont systemFontOfSize:14]];
        lblTlblGroupInfo.textAlignment=NSTextAlignmentRight;
        lblTlblGroupInfo.numberOfLines=2;
        lblTlblGroupInfo.lineBreakMode=NSLineBreakByWordWrapping;
        lblTlblGroupInfo.textColor=[UIColor orangeColor];
        lblTlblGroupInfo.text=[NSString stringWithFormat:@"$ %@",[_dictPost objectForKey:@"price"]];
        [cell.contentView addSubview:lblTlblGroupInfo];
        

        UIButton *btnContactSeller=[[UIButton alloc]initWithFrame:CGRectMake(16, 195, SCREEN_SIZE.width-32, 40)];
        [btnContactSeller setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
        [btnContactSeller setTitle:@"Contact Seller" forState:UIControlStateNormal];
        [btnContactSeller setTintColor:[UIColor whiteColor]];
        [btnContactSeller addTarget:self
                   action:@selector(cmdContactSeller:)
         forControlEvents:UIControlEventTouchUpInside];
        btnContactSeller.layer.cornerRadius=8;
        [cell.contentView  addSubview:btnContactSeller];
        
        UILabel *lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(20, 240,80,20)];
        [lblPrice setFont:[UIFont boldSystemFontOfSize:14]];
        lblPrice.textAlignment=NSTextAlignmentLeft;
        lblPrice.numberOfLines=2;
        lblPrice.lineBreakMode=NSLineBreakByWordWrapping;
        lblPrice.textColor=[UIColor blackColor];
        lblPrice.text=@"Price :";
        [cell.contentView addSubview:lblPrice];
        
        UILabel *lblPriceValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 240,SCREEN_SIZE.width-110,20)];
        [lblPriceValue setFont:[UIFont boldSystemFontOfSize:14]];
        lblPriceValue.textAlignment=NSTextAlignmentCenter;
        lblPriceValue.numberOfLines=2;
        lblPriceValue.lineBreakMode=NSLineBreakByWordWrapping;
        lblPriceValue.textColor=[UIColor orangeColor];
        lblPriceValue.text=[NSString stringWithFormat:@"$ %@",[_dictPost objectForKey:@"price"]];
        [cell.contentView addSubview:lblPriceValue];
        
        UILabel *lblCategory = [[UILabel alloc] initWithFrame:CGRectMake(20, 260,80,20)];
        [lblCategory setFont:[UIFont boldSystemFontOfSize:14]];
        lblCategory.textAlignment=NSTextAlignmentLeft;
        lblCategory.numberOfLines=2;
        lblCategory.lineBreakMode=NSLineBreakByWordWrapping;
        lblCategory.textColor=[UIColor blackColor];
        lblCategory.text=@"Category :";
        [cell.contentView addSubview:lblCategory];
        
        UILabel *lblCategoryValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 260,SCREEN_SIZE.width-110,20)];
        [lblCategoryValue setFont:[UIFont boldSystemFontOfSize:14]];
        lblCategoryValue.textAlignment=NSTextAlignmentCenter;
        lblCategoryValue.numberOfLines=2;
        lblCategoryValue.lineBreakMode=NSLineBreakByWordWrapping;
        lblCategoryValue.textColor=[UIColor orangeColor];
        lblCategoryValue.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"category"]];;
        [cell.contentView addSubview:lblCategoryValue];
        
        
        UILabel *lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(20, 280,80,20)];
        [lblLocation setFont:[UIFont boldSystemFontOfSize:14]];
        lblLocation.textAlignment=NSTextAlignmentLeft;
        lblLocation.numberOfLines=2;
        lblLocation.lineBreakMode=NSLineBreakByWordWrapping;
        lblLocation.textColor=[UIColor blackColor];
        lblLocation.text=@"Location :";
        [cell.contentView addSubview:lblLocation];
        
        UILabel *lblLocationValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 280,SCREEN_SIZE.width-110,20)];
        [lblLocationValue setFont:[UIFont boldSystemFontOfSize:14]];
        lblLocationValue.textAlignment=NSTextAlignmentCenter;
        lblLocationValue.numberOfLines=2;
        lblLocationValue.lineBreakMode=NSLineBreakByWordWrapping;
        lblLocationValue.textColor=[UIColor orangeColor];
        lblLocationValue.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"location"]];
        [cell.contentView addSubview:lblLocationValue];
        
        UILabel *lblCity = [[UILabel alloc] initWithFrame:CGRectMake(20, 300,80,20)];
        [lblCity setFont:[UIFont boldSystemFontOfSize:14]];
        lblCity.textAlignment=NSTextAlignmentLeft;
        lblCity.numberOfLines=2;
        lblCity.lineBreakMode=NSLineBreakByWordWrapping;
        lblCity.textColor=[UIColor blackColor];
        lblCity.text=@"City :";
        [cell.contentView addSubview:lblCity];
        
        UILabel *lblCityValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 300,SCREEN_SIZE.width-110,20)];
        [lblCityValue setFont:[UIFont boldSystemFontOfSize:14]];
        lblCityValue.textAlignment=NSTextAlignmentCenter;
        lblCityValue.numberOfLines=2;
        lblCityValue.lineBreakMode=NSLineBreakByWordWrapping;
        lblCityValue.textColor=[UIColor orangeColor];
        lblCityValue.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"city"]];;
        [cell.contentView addSubview:lblCityValue];
        
        
        UILabel *lblZip = [[UILabel alloc] initWithFrame:CGRectMake(20, 320,80,20)];
        [lblZip setFont:[UIFont boldSystemFontOfSize:14]];
        lblZip.textAlignment=NSTextAlignmentLeft;
        lblZip.numberOfLines=2;
        lblZip.lineBreakMode=NSLineBreakByWordWrapping;
        lblZip.textColor=[UIColor blackColor];
        lblZip.text=@"Zip :";
        [cell.contentView addSubview:lblZip];
        
        UILabel *lblZipValue = [[UILabel alloc] initWithFrame:CGRectMake(100, 320,SCREEN_SIZE.width-110,20)];
        [lblZipValue setFont:[UIFont boldSystemFontOfSize:14]];
        lblZipValue.textAlignment=NSTextAlignmentCenter;
        lblZipValue.numberOfLines=2;
        lblZipValue.lineBreakMode=NSLineBreakByWordWrapping;
        lblZipValue.textColor=[UIColor orangeColor];
        lblZipValue.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"zipcode"]];
        [cell.contentView addSubview:lblZipValue];
        
        
        UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(8, 340,SCREEN_SIZE.width-16,20)];
        [lblAddress setFont:[UIFont boldSystemFontOfSize:14]];
        lblAddress.textAlignment=NSTextAlignmentLeft;
        lblAddress.numberOfLines=2;
        lblAddress.lineBreakMode=NSLineBreakByWordWrapping;
        lblAddress.textColor=[UIColor blackColor];
        lblAddress.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"description"]];;;
        [cell.contentView addSubview:lblAddress];
        
        
        UIView *viewBottom=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lblAddress.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageShare=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageShare.image=[UIImage imageNamed:@"send"];
        imageShare.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom addSubview:imageShare];
        
        
        UILabel *lblShare=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblShare.text=@"Share";
        lblShare.textAlignment=NSTextAlignmentCenter;
        lblShare.font=[UIFont systemFontOfSize:12];
        [viewBottom addSubview:lblShare];
        
        [cell.contentView addSubview:viewBottom];
        
        
        
        UIView *viewBottom1=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width)/4, CGRectGetMaxY(lblAddress.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageView.image=[UIImage imageNamed:@"eye"];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom1 addSubview:imageView];
        
        
        UILabel *lblView=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblView.text=[NSString stringWithFormat:@"%@ Views",[dictMarketPlaceDetails objectForKey:@"view_count"]];
        lblView.textAlignment=NSTextAlignmentCenter;
        lblView.font=[UIFont systemFontOfSize:12];
        [viewBottom1 addSubview:lblView];
        
        [cell.contentView addSubview:viewBottom1];
        
        
        UIView *viewBottom2=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*2, CGRectGetMaxY(lblAddress.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        
        UIImageView *imageComment=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        imageComment.image=[UIImage imageNamed:@"speech-bubble"];
        imageComment.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom2 addSubview:imageComment];
        
        
        UILabel *lblComments=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        lblComments.text=[NSString stringWithFormat:@"%lu Comments",arrComments.count];
        lblComments.textAlignment=NSTextAlignmentCenter;
        lblComments.font=[UIFont systemFontOfSize:12];
        [viewBottom2 addSubview:lblComments];
        
        [cell.contentView addSubview:viewBottom2];
        
        UIView *viewBottom3=[[UIView alloc]initWithFrame:CGRectMake(((SCREEN_SIZE.width)/4)*3, CGRectGetMaxY(lblAddress.frame)+5, (SCREEN_SIZE.width)/4, 45)];
        
        UIImageView *imageLike=[[UIImageView alloc]initWithFrame:CGRectMake((viewBottom.frame.size.width/2)-9, 0, 18, 18)];
        
        NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"isLiked"]];
        
        if([strLikestatus isEqualToString:@"0"]){
             imageLike.image=[UIImage imageNamed:@"like11"];
        }else{
             imageLike.image=[UIImage imageNamed:@"heart"];
        }

        imageLike.contentMode=UIViewContentModeScaleAspectFit;
        [viewBottom3 addSubview:imageLike];
        
        UILabel *lblLike=[[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewBottom.frame.size.width, 20)];
        
        lblLike.text=[NSString stringWithFormat:@"%@ Likes",[dictMarketPlaceDetails objectForKey:@"countLikes"]];
        lblLike.textAlignment=NSTextAlignmentCenter;
        lblLike.font=[UIFont systemFontOfSize:12];
        [viewBottom3 addSubview:lblLike];
        
        [cell.contentView addSubview:viewBottom3];
        
        
        
        MYTapGestureRecognizer *tapShare = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdShareAll:)];
        tapShare.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [viewBottom addGestureRecognizer:tapShare];
        [viewBottom setUserInteractionEnabled:YES];
        
        
        MYTapGestureRecognizer *tapLike = [[MYTapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdLikeAll:)];
        tapLike.tagValue=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        [viewBottom3 addGestureRecognizer:tapLike];
        [viewBottom3 setUserInteractionEnabled:YES];
        
        
        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 394+20, SCREEN_SIZE.width-40 , 1)];
        sepView.backgroundColor=[UIColor blackColor];
        [cell.contentView addSubview:sepView];
        
    }else{
        NSDictionary *dict=[arrComments objectAtIndex:indexPath.row];
        AsyncImageView* userProImgVw = [[AsyncImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
        userProImgVw.activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
        [userProImgVw setContentMode:UIViewContentModeScaleAspectFill];
        userProImgVw.layer.cornerRadius = 20.0;
        userProImgVw.clipsToBounds = YES;
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
              userProImgVw.imageURL=[NSURL URLWithString:strUrl];
        
        [cell.contentView addSubview:userProImgVw];
        userProImgVw.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
        [userProImgVw addGestureRecognizer:tap];
        [userProImgVw setUserInteractionEnabled:YES];
        
        
        UILabel *lblname=[[UILabel alloc] initWithFrame:CGRectMake(60, 5, SCREEN_SIZE.width-160, 40)];
        lblname.textColor = [UIColor colorWithRed:0.0f/255.0f green:42.0f/255.0f blue:65.0f/255.0f alpha:1.0f];
        lblname.textAlignment = NSTextAlignmentLeft;
        lblname.text=[dict  objectForKey:@"name"];
        [lblname setFont:[UIFont boldSystemFontOfSize:13]];
        [cell.contentView addSubview:lblname];
        
        
                    NSString *strDate=[NSString stringWithFormat:@"%@",[dict objectForKey:@"date"]];
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
                    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    NSDate *date = [dateFormat dateFromString:strDate];
                    [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
                    NSString *strDatetoShow=[dateFormat stringFromDate:date];
        
        UILabel *time=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-128, 5, 120, 40)];
        time.text = strDatetoShow;
        time.textColor = [UIColor colorWithRed:0.0f/255.0f green:42.0f/255.0f blue:65.0f/255.0f alpha:0.5f];
        time.textAlignment = NSTextAlignmentRight;
        [time setFont:[UIFont italicSystemFontOfSize:10 ]];
        [cell.contentView addSubview:time];
        
        
        UILabel *comment=[[UILabel alloc] initWithFrame:CGRectMake(60, 43, SCREEN_SIZE.width-70, [self getLabelHeight:[dict objectForKey:@"comment"]])];//[self getLabelHeight:[dict objectForKey:@"comment"]]
        
        const char *jsonString = [[dict objectForKey:@"comment"] UTF8String];
        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        comment.text = msg;
        comment.textColor = [UIColor colorWithRed:0.0f/255.0f green:42.0f/255.0f blue:65.0f/255.0f alpha:0.5f];
        comment.textAlignment = NSTextAlignmentLeft;
        comment.numberOfLines=150;
        [comment setFont:[UIFont systemFontOfSize:13 ]];
        [cell.contentView addSubview:comment];
        
     
        
        UIButton *btnLike=[[UIButton alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(comment.frame)+5, 50, 32)];
        
        [btnLike setTitle:[NSString stringWithFormat:@"%@ Likes",[dict objectForKey:@"countLikes"]] forState:UIControlStateNormal];
        
        btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLike.layer.cornerRadius=8;//0,160,223
        btnLike.layer.borderWidth=1;
        btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnLike.tag=indexPath.row;
        
        
        NSString *strIsCmtLiked=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isCmtLiked"]];
        if(!([strIsCmtLiked isEqualToString:@"0"])){
            btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
            [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [cell.contentView addSubview:btnLike];
        
        UIButton *btnDelete=[[UIButton alloc]initWithFrame:CGRectMake(70, CGRectGetMaxY(comment.frame)+5, 50, 32)];
        
        [btnDelete setTitle:[NSString stringWithFormat:@"Delete"] forState:UIControlStateNormal];
        
        btnDelete.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnDelete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnDelete.layer.cornerRadius=8;//0,160,223
        btnDelete.layer.borderWidth=1;
        btnDelete.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnDelete.tag=indexPath.row;
        
        [cell.contentView addSubview:btnDelete];
        [btnLike addTarget:self
                    action:@selector(cmdLikeComment:)
          forControlEvents:UIControlEventTouchUpInside];
        NSString *strUserId=[dict objectForKey:@"user_id"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        if([strUserId isEqualToString:USERID]){
            [btnDelete addTarget:self
                          action:@selector(cmdDeleteComment:)
                forControlEvents:UIControlEventTouchUpInside];
        }else{
            btnDelete.hidden=YES;
        }
        
        
        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(0, 89+[self getLabelHeight:[dict objectForKey:@"comment"]], SCREEN_SIZE.width, 1)];//43+[self getLabelHeight:[dict objectForKey:@"comment"]]
        sepView.backgroundColor=[UIColor lightGrayColor];//0,153,204
        [cell.contentView addSubview:sepView];
        
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 0;
    else
       return 60;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    view.backgroundColor=[UIColor   clearColor];
    
    AsyncImageView *imgBackground = [[AsyncImageView alloc]initWithFrame:CGRectMake(0 , 0, SCREEN_SIZE.width, 44)];
    imgBackground.image =[UIImage imageNamed:@"comment_sect_separator.png"];
    imgBackground.backgroundColor= [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    [view addSubview:imgBackground];
    
    UILabel *comment=[[UILabel alloc] initWithFrame:CGRectMake(0 , 0, SCREEN_SIZE.width, 44)];
    comment.text = @"Comments";
    comment.textColor = [UIColor whiteColor];
    comment.textAlignment = NSTextAlignmentCenter;
    [comment setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:comment];
    
    NSString *strLikeCount=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"countLikes"]];
    int LikeCount=[strLikeCount intValue];
    
    UILabel *Likes=[[UILabel alloc] initWithFrame:CGRectMake(0 , 44, SCREEN_SIZE.width, 20)];
    NSString *strISLike=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"isLiked"]];
    if([strISLike isEqualToString:@"1"]){
        Likes.text = [NSString stringWithFormat:@"You and %d other like the post",--LikeCount];
    }else{
        Likes.text = [NSString stringWithFormat:@" %d like the post",LikeCount];
    }
    
    Likes.textColor = [UIColor blackColor];
    Likes.textAlignment = NSTextAlignmentLeft;
    [Likes setFont:[UIFont boldSystemFontOfSize:12]];
    [view addSubview:Likes];
    return view;
}


-(void)resignTextView
{
    [textView resignFirstResponder];
}
    //Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
        // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
        // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
        // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
        // set views with new info
    containerView.frame = containerFrame;
    
    
        // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    [_tblMarketPlaceDetails setFrame:CGRectMake(_tblMarketPlaceDetails.frame.origin.x
                                     , _tblMarketPlaceDetails.frame.origin.y, _tblMarketPlaceDetails.frame.size.width, SCREEN_SIZE.height-114)];
    
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
        // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
        // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
        // set views with new info
    containerView.frame = containerFrame;
    
        // commit animations
    [UIView commitAnimations];
}

-(void) keyboardDidShow:(NSNotification *)note{
    
    
    
    NSDictionary* info = [note userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    CGRect aRect = self.view.frame;
    
    aRect.size.height -= kbSize.height;
    
    float height =100;
    float yPoint = aRect.size.height-height;
    
    
    [_tblMarketPlaceDetails setFrame:CGRectMake(_tblMarketPlaceDetails.frame.origin.x
                                     , _tblMarketPlaceDetails.frame.origin.y, _tblMarketPlaceDetails.frame.size.width, yPoint)];
    
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
        // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
        // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
        // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
        // set views with new info
    containerView.frame = containerFrame;
    
    
        // commit animations
    [UIView commitAnimations];
    
    
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void)cmdAddComment{
    [self.view endEditing:YES];
    NSString *strComment=[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(strComment.length>0){
        [self addComment:textView.text];
    }else{
        [AlertView showAlertWithMessage:@"Not a proper comment" view:self];
    }
}
-(void)addComment:(NSString *)comment{
    textView.text=@"";
    
    NSString *uniText = [NSString stringWithUTF8String:[comment UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    comment = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    [AlertView showAlertWithMessage:@"comment added successfully." view:self];
    [self.view endEditing:YES];
    NSString *postId=[_dictPost objectForKey:@"id"];
    NSString *uuid = [[NSUUID UUID] UUIDString];
        //emit("commentONPost", user_id, post_id, comment, sender_image, sender_name, comment_id, page_id)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *profilePic = [prefs stringForKey:@"profile_pic"];
    NSString *Username = [prefs stringForKey:@"username"];
    [appDelegate().socket emit:@"commentONPost" with:@[USERID,postId,comment,profilePic,Username,uuid,@"1"]];
        //    IndecatorView *ind=[[IndecatorView alloc]init];
        //    [self.view addSubview:ind];
    [self performSelector:@selector(newfetch) withObject:nil afterDelay:1.5];
}
-(void)newfetch{
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,strPost_id]];
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
-(void)cmdLikeAllVideo:(id)sender{
    

    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"isLiked"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
   // NSString *strViewCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"view_count"]];
    if([strLikestatus isEqualToString:@"0"]){
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
       // long countView = [strViewCOunt intValue];
        
        NSMutableDictionary *dictNew=[dictMarketPlaceDetails mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"countLikes"];
        [dictNew setValue:@"1" forKey:@"isLiked"];
        //[dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        
        dictMarketPlaceDetails=dictNew;
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[_dictPost objectForKey:@"id"],@"0"]];
        
    }else{
        
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
     //   long countView = [strViewCOunt intValue];
        NSMutableDictionary *dictNew=[dictMarketPlaceDetails mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"countLikes"];
      //  [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [dictNew setValue:@"0" forKey:@"isLiked"];
        
        dictMarketPlaceDetails=dictNew;
        [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[_dictPost objectForKey:@"id"],@"0"]];
    }
    

    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    
    [self.tblMarketPlaceDetails reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tblMarketPlaceDetails reloadData];

}
-(void)cmdCommentAllVideo:(id)sender{
    
}
-(void)cmdShareAllvideo:(id)sender{
 
  
    
    NSString *strShare=[NSString stringWithFormat:@"Title: %@\nDescription: %@\nPrice: $%@\nCity: %@",[dictMarketPlaceDetails objectForKey:@"title"],[dictMarketPlaceDetails objectForKey:@"description"],[dictMarketPlaceDetails objectForKey:@"price"],[dictMarketPlaceDetails objectForKey:@"city"]];
    
   
    NSArray *Items   = [NSArray arrayWithObjects:
                        strShare,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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

-(void)cmdDeleteComment:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arrComments objectAtIndex:btn.tag];
    
    [appDelegate().socket emit:@"deleteComment" with:@[[dict objectForKey:@"comment_id"]]];
    
    NSMutableArray *temp=[arrComments mutableCopy];
    [temp removeObject:dict];
    arrComments=temp;
    [_tblMarketPlaceDetails reloadData];
  
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,strPost_id]];
}
-(void)cmdLikeComment:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arrComments objectAtIndex:btn.tag];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strlikeCount = [NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
    int Count = [strlikeCount intValue];
    NSString *strIsLike = [NSString stringWithFormat:@"%@",[dict objectForKey:@"isCmtLiked"]];
    NSString *strIsLike1;
    if([strIsLike isEqualToString:@"0"]){
        Count ++ ;
        strIsLike1 =@"1";
    }else{
        Count --;
        strIsLike1 =@"0";
    }
    NSMutableDictionary *dictTemp = [dict mutableCopy];
    [dictTemp setValue:[NSString stringWithFormat:@"%d",Count] forKey:@"countLikes"];
    [dictTemp setValue:[NSString stringWithFormat:@"%@",strIsLike1] forKey:@"isCmtLiked"];
    NSMutableArray *temp = [arrComments  mutableCopy];
    
    [temp replaceObjectAtIndex:btn.tag withObject:dictTemp];
    arrComments = temp;
    [_tblMarketPlaceDetails reloadData];
    if([strIsLike isEqualToString:@"0"]){
            //mSocket.emit("likeAcomment", user_id, comment_id);
        [appDelegate().socket emit:@"likeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }else{
        
        [appDelegate().socket emit:@"unLikeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }
}

-(void)cmdEdit:(id)sender{
    AddMarketPlaceViewController *cont=[[AddMarketPlaceViewController alloc]initWithNibName:@"AddMarketPlaceViewController" bundle:nil];
    cont.dictDetails=dictMarketPlaceDetails;
    cont.dictPost=_dictPost;
    [self.navigationController pushViewController:cont animated:YES];
}
-(void)cmdDeleteList:(id)sender{
     NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
     [appDelegate().socket emit:@"deletelLists" with:@[strPost_id]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMarketplace" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cmdContactSeller:(id)sender{
    NSString *strUserId=[dictMarketPlaceDetails objectForKey:@"user_id"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if([strUserId isEqualToString:USERID]){
        RecentChatListViewController *R2VC = [[RecentChatListViewController alloc]initWithNibName:@"RecentChatListViewController" bundle:nil];
        R2VC.dictPost=_dictPost;
        R2VC.strFromMarketPlace=@"yes";
        [self.navigationController pushViewController:R2VC animated:YES];
    }else{
        AGChatViewController *R2VC = [[AGChatViewController alloc]initWithNibName:@"AGChatViewController" bundle:nil];
        R2VC.dictChatData=_dictPost;
        [self.navigationController pushViewController:R2VC animated:YES];
    }

}


- (void)cmdShareAll:(UITapGestureRecognizer *)tapRecognizer {
    [self cmdShareAllvideo:nil];
}
- (void)cmdCommentAll:(UITapGestureRecognizer *)tapRecognizer {
        
        MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
        NSLog(@"data : %@", tap.data);
        NSLog(@"data : %@", tap.tagValue);
        

        
        
}
- (void)cmdLikeAll:(UITapGestureRecognizer *)tapRecognizer {
        
        MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
        NSLog(@"data : %@", tap.data);
        NSLog(@"data : %@", tap.tagValue);
        
    [self cmdLikeAllVideo:nil];
        
}
-(void)cmdDone:(id)sender{
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                      //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Edit"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Take a photo"
                                  [self cmdEdit:nil];
                              
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Delete"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      //  The user tapped on "Choose existing"
                                 [self cmdDeleteList:nil];
                              }];
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
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
@end

    //
    //  CommentViewController.m
    //  iBlah-Blah
    //
    //  Created by Arun on 30/03/18.
    //  Copyright © 2018 webHax. All rights reserved.
    //
#import "CommentViewController.h"
#import "HPGrowingTextView.h"
#import "LikesViewController.h"
#import "NSDate+Utils.h"


@interface CommentViewController ()<HPGrowingTextViewDelegate,UIViewControllerPreviewingDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
    NSArray *arrComments;
}

@property (strong, nonatomic) NSArray *imgURLs;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
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
    
        // arrComments=[_dictPost objectForKey:@"comments"];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tblComment addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
        // [self getData];
        //emit("getcmnts", "this is user_id", "this is post_id");//post_id
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
                _viewHeadder.frame=CGRectMake(_viewHeadder.frame.origin.x, _viewHeadder.frame.origin.y, SCREEN_SIZE.width, 85);
                //_tblComment.frame=CGRectMake(_tblComment.frame.origin.x, 85, SCREEN_SIZE.width, SCREEN_SIZE.height-85-50);
                break;
            default:
                printf("unknown");
        }
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
     _lblHeadder.frame=CGRectMake(0, _lblHeadder.frame.origin.y, SCREEN_SIZE.width, _lblHeadder.frame.size.height);
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,strPost_id]];
    
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"ALLComment"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        
        arrComments = [Arr objectAtIndex:1];
        NSString *strCount=[NSString stringWithFormat:@"%lu",arrComments.count];
        NSArray *arryData=@[@"",[_dictPost objectForKey:@"post_id"],strCount];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        [dict setValue:arryData forKey:@"DATA"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"getCommentCount"
         object:self userInfo:dict];
        //[[dict objectForKey:@"posts"] mutableCopy];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:strCount forKey:@"countcomments"];
        _dictPost=dictNew;
        [_tblComment reloadData];
        if(arrComments.count>0){
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: arrComments.count-1 inSection: 1];
            [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

        }
      
        
    }
}
- (void) hideKeyboard {
    [self.view endEditing:YES];
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
    
        // textView.text = @"test\n\ntest";
        // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    
        //    UIImage *rawEntryBackground = [UIImage imageNamed:@"comment_sect_separator.png"];
        //    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        //    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        //    entryImageView.frame = CGRectMake(5, 0, 248, 40);
        //    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //
        //    UIImage *rawBackground = [UIImage imageNamed:@"comment_sect_separator.png"];
        //    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        //    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        //    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        //    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
        // view hierachy
    
    [containerView addSubview:textView];
        //[containerView addSubview:entryImageView];
    
    
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        if(![[_dictPost objectForKey:@"images"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:[_dictPost objectForKey:@"discription"]]+125;
            
        }else if(![[_dictPost objectForKey:@"lat"] isEqualToString:@""] && ![[_dictPost objectForKey:@"lon"] isEqualToString:@""]){
            return SCREEN_SIZE.width-40+[self getLabelHeight:[_dictPost objectForKey:@"discription"]]+125;
        }
        return  125+[self getLabelHeight:[_dictPost objectForKey:@"discription"]];
        
        
    }else{
        NSDictionary *dict=[arrComments objectAtIndex:indexPath.row];
        return 90+[self getLabelHeight:[dict objectForKey:@"comment"]];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return 1;
    else
        return arrComments.count;//arrComments.count;
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
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 20,50,50)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        banner.showActivityIndicator=YES;
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            //  baseUrl + "thumb/" + image_name
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[_dictPost objectForKey:@"image"]];
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
        name.text=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"name"]];
        [cell.contentView addSubview:name];
        
        UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
        [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
        btnMore.tag=indexPath.row;
        
        
        [btnMore addTarget:self action:@selector(cmdMoreALL:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell.contentView addSubview:btnMore];
        
        NSString *strDate=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"date"]];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];//EEE MMM dd HH:mm:ss z yyyy
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *date = [dateFormat dateFromString:strDate];
        NSDate *localDate = [date toLocalTime];
        [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
        NSString *strDatetoShow=[dateFormat stringFromDate:localDate];
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(75, 40,SCREEN_SIZE.width-110,20)];
        [time setFont:[UIFont systemFontOfSize:12]];
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
        
        
        UITextView *status=[[UITextView alloc] initWithFrame:CGRectMake(20, 80,SCREEN_SIZE.width-40,[self getLabelHeight:[_dictPost objectForKey:@"discription"]])];
        [status setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        status.textColor=[UIColor blackColor];
        
        const char *jsonString = [[_dictPost objectForKey:@"discription"] UTF8String];
        NSData *data = [NSData dataWithBytes: jsonString length:strlen(jsonString)];
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        status.text=msg;//[_dictPost objectForKey:@"discription"];
        status.editable=NO;
        status.backgroundColor=[UIColor clearColor];
        status.scrollEnabled=NO;
        status.textContainerInset = UIEdgeInsetsZero;
        status.dataDetectorTypes=UIDataDetectorTypeAll;
        [cell.contentView addSubview:status];

        UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[_dictPost objectForKey:@"discription"]], 50, 32);

//        UIButton *btnLike=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[_dictPost objectForKey:@"discription"]], 50, 32)];
        [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
                                                                                      //    countLikes = 4;
                                                                                      //    countcomments = 2;
                                                                                      //view_count
        NSString *strCount = [_dictPost objectForKey:@"countLikes"];

        if([[_dictPost objectForKey:@"countLikes"] intValue] > 99)
        {
            strCount = @"99+";
        }
        [btnLike setTitle:[NSString stringWithFormat:@" %@",strCount] forState:UIControlStateNormal];

//        [btnLike setTitle:[NSString stringWithFormat:@" %@",[_dictPost objectForKey:@"countLikes"]] forState:UIControlStateNormal];
        [cell.contentView addSubview:btnLike];
        
        
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];
        
        
        btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLike.layer.cornerRadius=8;//0,160,223
        btnLike.layer.borderWidth=1;
        btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        
        btnLike.tag=indexPath.row;
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];


        NSString *strLikestatus=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likestatus"]];
        if([strLikestatus isEqualToString:@"0"]){
            btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }else{
            btnLike.tintColor = [UIColor whiteColor];//
            [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }
        
        UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 85+[self getLabelHeight:[_dictPost objectForKey:@"discription"]], 50, 32)];
        [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];


        NSString *strCommentCount = [_dictPost objectForKey:@"countcomments"];

        if([strCommentCount intValue] > 99)
        {
            strCommentCount = @"99+";
        }
        [btnComment setTitle:[NSString stringWithFormat:@" %@",strCommentCount] forState:UIControlStateNormal];


//        [btnComment setTitle:[NSString stringWithFormat:@" %@",[_dictPost objectForKey:@"countcomments"]] forState:UIControlStateNormal];

        
        
        
        btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnComment.layer.cornerRadius=8;//0,160,223
        btnComment.layer.borderWidth=1;
        btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnComment.tag=indexPath.row;
        
        [cell.contentView addSubview:btnComment];
        
        UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 85+[self getLabelHeight:[_dictPost objectForKey:@"discription"]], 50, 32)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        
        [btnShare addTarget:self
                     action:@selector(cmdShareAllPost:)
           forControlEvents:UIControlEventTouchUpInside];
        
        
        
        btnShare.tag=indexPath.row;
        btnShare.layer.cornerRadius=8;//0,160,223
        btnShare.layer.borderWidth=1;
        btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        [cell.contentView addSubview:btnShare];
        
        UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 85+[self getLabelHeight:[_dictPost objectForKey:@"discription"]], 50, 32)];
        [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
        
        
//        [btnView addTarget:self
//                    action:@selector(cmdShareAllPost:)
//          forControlEvents:UIControlEventTouchUpInside];
        
        
        [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnView setTitle:[NSString stringWithFormat:@" %@",[_dictPost objectForKey:@"view_count"]] forState:UIControlStateNormal];
        btnView.layer.cornerRadius=8;//0,160,223
        btnView.layer.borderWidth=1;
        btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnView.tag=indexPath.row;
        btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [cell.contentView addSubview:btnView];
        
        if(!([[_dictPost objectForKey:@"images"] isEqualToString:@""])){
            
            UIView *viewImage=[[UIView alloc]initWithFrame:CGRectMake(0, [self getLabelHeight:[_dictPost objectForKey:@"discription"]]+80,SCREEN_SIZE.width,SCREEN_SIZE.width-40)];
            
            AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:[_dictPost objectForKey:@"discription"]]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            bannerPost.showActivityIndicator=YES;
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[_dictPost objectForKey:@"images"]];
            bannerPost.imageURL=[NSURL URLWithString:strUrl];
            [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
            bannerPost.clipsToBounds=YES;
            bannerPost.layer.cornerRadius=10;
                //[cell.contentView addSubview:bannerPost];
            bannerPost.userInteractionEnabled=YES;
            
            NSString *strImageList=[_dictPost objectForKey:@"images"];
            NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
            
            viewImage =  [self addImageView:arryImageList view:viewImage];
            viewImage.tag=indexPath.row;
            [cell.contentView addSubview:viewImage];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigButtonTapped:)];
            [viewImage addGestureRecognizer:tap];
            [viewImage setUserInteractionEnabled:YES];
            
            btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        }else if(![[_dictPost objectForKey:@"lat"] isEqualToString:@""] && ![[_dictPost objectForKey:@"lon"] isEqualToString:@""]){
            
            AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, [self getLabelHeight:[_dictPost objectForKey:@"discription"]]+80,SCREEN_SIZE.width-40,SCREEN_SIZE.width-40)];
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            bannerPost.showActivityIndicator=YES;
            bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
            NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[_dictPost objectForKey:@"lat"],[_dictPost objectForKey:@"lon"],[_dictPost objectForKey:@"lat"],[_dictPost objectForKey:@"lon"]];
            bannerPost.imageURL=[NSURL URLWithString:strUrl];
            [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
            bannerPost.clipsToBounds=YES;
            bannerPost.layer.cornerRadius=10;
            [cell.contentView addSubview:bannerPost];
            bannerPost.userInteractionEnabled=YES;
            btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnComment.frame=CGRectMake(SCREEN_SIZE.width-116, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnShare.frame=CGRectMake(20, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
            btnView.frame=CGRectMake(SCREEN_SIZE.width-174, 5+bannerPost.frame.origin.y+SCREEN_SIZE.width-40, 50, 32);
        }
        
        
            //
            //        UIView *sepUpView=[[UIView alloc]initWithFrame:CGRectMake(10, btnComment.frame.origin.y+37,SCREEN_SIZE.width-20 , 1)];
            //        sepUpView.backgroundColor=[UIColor darkGrayColor];
            //        sepUpView.alpha=0.4;
            //        [cell.contentView addSubview:sepUpView];
        
        return cell;
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
        
//        [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSDate *date = [dateFormat dateFromString:strDate];

        NSDate *localDate = [date toLocalTime];

        [dateFormat setDateFormat:@"EEE MMM dd yyyy hh:mm"];
        NSString *strDatetoShow=[dateFormat stringFromDate:localDate];
        
        UILabel *time=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-128, 5, 120, 40)];
        time.text = strDatetoShow;
        time.textColor = [UIColor colorWithRed:0.0f/255.0f green:42.0f/255.0f blue:65.0f/255.0f alpha:0.5f];
        time.textAlignment = NSTextAlignmentLeft;
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
    
    NSString *strLikeCount=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"countLikes"]];
    int LikeCount=[strLikeCount intValue];
    
    UILabel *Likes=[[UILabel alloc] initWithFrame:CGRectMake(0 , 44, SCREEN_SIZE.width, 20)];
    NSString *strISLike=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likestatus"]];
    if([strISLike isEqualToString:@"1"]){
        if(LikeCount == 1)
        {
            Likes.text = [NSString stringWithFormat:@"You like the post"];
        }
        else
        {
            Likes.text = [NSString stringWithFormat:@"You and %d other like the post",--LikeCount];
        }

    }else{
        Likes.text = [NSString stringWithFormat:@" %d like the post",LikeCount];
    }
    
    Likes.textColor = [UIColor blackColor];
    Likes.textAlignment = NSTextAlignmentLeft;
    [Likes setFont:[UIFont boldSystemFontOfSize:12]];
    [view addSubview:Likes];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cmdLikeUser)];
    [view addGestureRecognizer:tap];
    [view setUserInteractionEnabled:YES];
    
    
    return view;
}

-(void)cmdLikeUser{
//    LikesViewController *R2VC = [[LikesViewController alloc]initWithNibName:@"LikesViewController" bundle:nil];
//    R2VC.dictPost=_dictPost;
//    [self.navigationController pushViewController:R2VC animated:YES];
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
    
    [_tblComment setFrame:CGRectMake(_tblComment.frame.origin.x
                                     , _tblComment.frame.origin.y, _tblComment.frame.size.width, SCREEN_SIZE.height-114)];
    
    
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
    
    
    [_tblComment setFrame:CGRectMake(_tblComment.frame.origin.x
                                     , _tblComment.frame.origin.y, _tblComment.frame.size.width, yPoint)];
    
    
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
    
//    [AlertView showAlertWithMessage:@"comment added successfully." view:self];
    [self.view endEditing:YES];
    NSString *postId=[_dictPost objectForKey:@"post_id"];
    NSString *uuid = [[NSUUID UUID] UUIDString];
        //emit("commentONPost", user_id, post_id, comment, sender_image, sender_name, comment_id, page_id)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"commentONPost" with:@[USERID,postId,comment,[_dictPost objectForKey:@"image"],[_dictPost objectForKey:@"name"],uuid,@"1"]];
        //    IndecatorView *ind=[[IndecatorView alloc]init];
        //    [self.view addSubview:ind];
    [self performSelector:@selector(newfetch) withObject:nil afterDelay:1.5];
}
-(void)newfetch{
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,strPost_id]];
}
-(void)getData{
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    
    
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
- (IBAction)cmdBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(UIView *)addImageView:(NSArray *)arryImage view:(UIView *)view{
    
    if(arryImage.count==5 || arryImage.count>5){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        if(arryImage.count>5){
            
            int count=arryImage.count-5;
            
            UIView *viewOverLay=[[UIView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/3)];
            viewOverLay.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
            UILabel* lblCount = [[UILabel alloc]init];
            lblCount.font=[UIFont boldSystemFontOfSize:34.0];
            lblCount.textAlignment = NSTextAlignmentCenter;
            lblCount.textColor = [UIColor whiteColor];
            lblCount.numberOfLines = 0;
            lblCount.backgroundColor=[UIColor clearColor];
            lblCount.frame=CGRectMake(0, 0, view.frame.size.width/2, view.frame.size.height/3);
            lblCount.text=[NSString stringWithFormat:@"+%d",count];
            [viewOverLay addSubview:lblCount];
            [view addSubview:viewOverLay];
            
        }
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/3, view.frame.size.width/2-1, view.frame.size.height/3-1)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost5=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, (view.frame.size.height/3)*2, view.frame.size.width/2, view.frame.size.height/3)];
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost5.showActivityIndicator=YES;
        bannerPost5.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[4]];
        bannerPost5.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost5 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost5.clipsToBounds=YES;
        [view addSubview:bannerPost5];
        bannerPost5.userInteractionEnabled=YES;
        
        
        
    }else if(arryImage.count==4){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height/2-1)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, view.frame.size.height/2, view.frame.size.width/2-1, view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, 0, view.frame.size.width/2, view.frame.size.height/2-1)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost4=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2, view.frame.size.height/2, view.frame.size.width/2, view.frame.size.height/2)];
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost4.showActivityIndicator=YES;
        bannerPost4.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[3]];
        bannerPost4.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost4 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost4.clipsToBounds=YES;
        [view addSubview:bannerPost4];
        bannerPost3.userInteractionEnabled=YES;
        
        
    }else if(arryImage.count==3){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, (view.frame.size.width/3)*2, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, view.frame.size.height/2,(view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
        AsyncImageView *bannerPost3=[[AsyncImageView alloc]initWithFrame:CGRectMake((view.frame.size.width/3)*2, 0, (view.frame.size.width/3), view.frame.size.height/2)];
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost3.showActivityIndicator=YES;
        bannerPost3.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[2]];
        bannerPost3.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost3 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost3.clipsToBounds=YES;
        [view addSubview:bannerPost3];
        bannerPost3.userInteractionEnabled=YES;
        
        
        
        
    }else if(arryImage.count==2){
        
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width/2-1, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
        
        
        AsyncImageView *bannerPost2=[[AsyncImageView alloc]initWithFrame:CGRectMake(view.frame.size.width/2,0 , view.frame.size.width/2, view.frame.size.height)];
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost2.showActivityIndicator=YES;
        bannerPost2.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[1]];
        bannerPost2.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost2 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost2.clipsToBounds=YES;
        [view addSubview:bannerPost2];
        bannerPost2.userInteractionEnabled=YES;
        
        
        
    }else if(arryImage.count==1){
        AsyncImageView *bannerPost1=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        bannerPost1.showActivityIndicator=YES;
        bannerPost1.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImage[0]];
        bannerPost1.imageURL=[NSURL URLWithString:strUrl];
        [bannerPost1 setContentMode:UIViewContentModeScaleAspectFill];
        bannerPost1.clipsToBounds=YES;
        [view addSubview:bannerPost1];
        bannerPost1.userInteractionEnabled=YES;
    }
    
    return view;
}

-(void)cmdMoreALL:(id)sender{
        //  UIButton* btn = sender;
        //NSDictionary *dict=[arryAllPost objectAtIndex:btn.tag];
        //  NSString* postId =[dict objectForKey:@"cpId"];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* btnAbuse = [UIAlertAction actionWithTitle:@"Report"
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
-(void)cmdLikeAllPost:(id)sender{
    
    
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likestatus"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strViewCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"view_count"]];
    if([strLikestatus isEqualToString:@"0"]){
        
       
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"countLikes"];
        [dictNew setValue:@"1" forKey:@"likestatus"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
       
        _dictPost=dictNew;
        [appDelegate().socket emit:@"likeApost" with:@[USERID,[_dictPost objectForKey:@"post_id"],@"0"]];
        
    }else{
       
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
        long countView = [strViewCOunt intValue];
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"countLikes"];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [dictNew setValue:@"0" forKey:@"likestatus"];

        _dictPost=dictNew;
         [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[_dictPost objectForKey:@"post_id"],@"0"]];
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    NSArray *arryData=@[@"",[_dictPost objectForKey:@"post_id"],[_dictPost objectForKey:@"countLikes"]];

    [dict setValue:arryData forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LikeClicked"
     object:self userInfo:dict];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    
    [self.tblComment reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tblComment  reloadData];
}
-(void)cmdShareAllPost:(id)sender{
    
    
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    NSString *strTitle=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"title"]];
    NSString *strDiscription=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"discription"]];
    NSString *strPosttype=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"posttype"]];
    NSString *strLat=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"lat"]];
    NSString *strLon=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"lon"]];
    NSString *strPostimages=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"images"]];
    NSString *strType=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"type"]];
    NSString *strLocation=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"location"]];
        //    NSString *strOtheruserID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"location"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
        //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Share on your wall"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        //mSocket.emit("sharePost", user_id, post_id, title,  discription,  posttype, lat, lon,"", postimages, "", type, location, other_user_id
                                    [appDelegate().socket emit:@"sharePost" with:@[USERID,strPost_id,strTitle,strDiscription,strPosttype,strLat,strLon,@"",strPostimages,@"",strType,strLocation,@"5d12dbf3-82f2-45b9-8fde-3ef69a187092"]];
                                }];
    
    UIAlertAction* btnSharewithFrnd = [UIAlertAction
                                       actionWithTitle:@"Share with Friends"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                           [AlertView showAlertWithMessage:@"Coming soon" view:self];
                                       }];
    
    UIAlertAction* btnSharewithOtherApp = [UIAlertAction
                                           actionWithTitle:@"Share on other app"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                                   //Handle no, thanks button
                                               [self performSelector:@selector(shareWithOtherApp:) withObject:_dictPost afterDelay:0];
                                           }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                       //Handle no, thanks button
                               }];
    
        //Add your buttons to alert controller
    [alert addAction:yesButton];
    [alert addAction:btnSharewithFrnd];
    [alert addAction:btnSharewithOtherApp];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
   
    
    
    
}


-(void)shareWithOtherApp:(NSDictionary *)dict{


    [SupportClass shareWithOtherAppRefrenceClass:self withImagesArray:[[dict objectForKey:@"images"] isEqualToString:@""] ? @[] : [[dict objectForKey:@"images"] componentsSeparatedByString:@","] withTitle:[NSString stringWithFormat:@"%@",[dict objectForKey:@"discription"]] withLat:[dict objectForKey:@"lat"] withLong:[dict objectForKey:@"lon"]];

/*
    IndecatorView *ind=[[IndecatorView alloc]init];
    [self.view addSubview:ind];
    
    NSArray *arraImages = [[dict objectForKey:@"images"] componentsSeparatedByString:@","];


    //if(arraImages.count > 0)
    //{
    //    NSString *strImageUrl = [NSString stringWithFormat:@"%simages/%@",BASEURl,arraImages[0] ];
    //    imgShare = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImageUrl]];
    //
    //}



    [SVProgressHUD showWithStatus:@"Please wait"];
    NSString *strTitle=[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];

    UIActivityItemProvider *message = [[UIActivityItemProvider alloc] initWithPlaceholderItem:strTitle];

    NSMutableArray *Items = [[NSMutableArray alloc]init];


    int index = 0;
    for(NSString *strTemp in arraImages)
    {
        NSString *strImageUrl = [NSString stringWithFormat:@"%simages/%@",BASEURl,strTemp ];
        NSData *imgShare = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImageUrl]];

        UIImage *img = [UIImage imageWithData:imgShare];

        ImageActivityItemProvider *itemProvider = [[ImageActivityItemProvider alloc] initWithImage:img index:index shouldShowIndex:index];

        [Items addObject:itemProvider];

        index ++;
    }


    [SVProgressHUD dismiss];
    if(!([[dict objectForKey:@"images"] isEqualToString:@""])){

        [Items addObject:message];
        [Items addObject:@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8"];
        [Items addObject:@"Via iBlah-Blah"];

//        Items  = [NSArray arrayWithObjects:
//                  strTitle,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
//                  @"Via iBlah-Blah", nil];

        
    }else if(![[dict objectForKey:@"lat"] isEqualToString:@""] && ![[dict objectForKey:@"lon"] isEqualToString:@""]){
        NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",[dict objectForKey:@"lat"],[dict objectForKey:@"lon"],[dict objectForKey:@"lat"],[dict objectForKey:@"lon"]];
        Items  = [NSMutableArray arrayWithObjects:
                  strTitle,strUrl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                  @"Via iBlah-Blah", nil];
    }
    
    
    
    
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
    */
}

- (void)bigButtonTapped:(UITapGestureRecognizer *)tapRecognizer {
   // UIView *view=(UIView *)tapRecognizer.view;
    
    
    NSString *strImageList=[_dictPost objectForKey:@"images"];
    NSArray *arryImageList=[strImageList componentsSeparatedByString:@","];
    NSMutableArray *arryimglink=[[NSMutableArray  alloc]init];
    for (int i=0; i<arryImageList.count; i++) {
        NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,arryImageList[i]];
        NSURL *url=[NSURL URLWithString:strUrl];
        [arryimglink addObject:url];
    }
    self.imgURLs=arryimglink;
    BFRImageViewController *imageVC = [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
    imageVC.startingIndex = 0;
    [self presentViewController:imageVC animated:YES completion:nil];
}

#pragma mark - 3D Touch
- (void)check3DTouch {
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return [[BFRImageViewController alloc] initWithImageSource:self.imgURLs];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self check3DTouch];
    }
}

-(void)cmdDeleteComment:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arrComments objectAtIndex:btn.tag];
    
    [appDelegate().socket emit:@"deleteComment" with:@[[dict objectForKey:@"comment_id"]]];
    
    NSMutableArray *temp=[arrComments mutableCopy];
    [temp removeObject:dict];
    arrComments=temp;
    [_tblComment reloadData];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UpdatePost"
     object:self userInfo:nil];
     NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
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
    [_tblComment reloadData];
    if([strIsLike isEqualToString:@"0"]){
            //mSocket.emit("likeAcomment", user_id, comment_id);
        [appDelegate().socket emit:@"likeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }else{
        
        [appDelegate().socket emit:@"unLikeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }
}


@end

//
//  BlogDetailsViewController.m
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "BlogDetailsViewController.h"
#import "HPGrowingTextView.h"
#import "AddBlogViewController.h"
@interface BlogDetailsViewController ()<HPGrowingTextViewDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
    NSArray *arrComments;
    NSArray *arrImages;
    NSDictionary *dictMarketPlaceDetails;
    IndecatorView *ind;
}

@end

@implementation BlogDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //  mSocket.emit("showDetailedBlog", user_id, blog_id);

    
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
    [self.tblBlogDetails addGestureRecognizer:gestureRecognizer];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"BlogDetails"
                                               object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"ALLComment"
                                               object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"showDetailedBlog" with:@[USERID,[_dictPost objectForKey:@"id"]]];
    [appDelegate().socket emit:@"getcmnts" with:@[USERID,[_dictPost objectForKey:@"id"]]];
 [appDelegate().socket emit:@"addToView" with:@[USERID,@"",[_dictPost objectForKey:@"id"]]];
    
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"BlogDetails"]) {//countLikes,isLiked
        [ind removeFromSuperview];
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        NSError *jsonError;
        
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        
        if(Arr.count>1){
            NSData *objectData1 = [[Arr objectAtIndex:2] dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *json1 = [NSJSONSerialization JSONObjectWithData:objectData1
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            NSLog(@"Json1 %@",json1);
            arrImages=json1;
        }
        NSLog(@"Json %@",json);
        dictMarketPlaceDetails=[json objectAtIndex:0];
        [_tblBlogDetails reloadData];
    }else   if ([[notification name] isEqualToString:@"ALLComment"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        
        arrComments = [Arr objectAtIndex:1];
        NSString *strCount=[NSString stringWithFormat:@"%lu",arrComments.count];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:strCount forKey:@"countcomments"];
        _dictPost=dictNew;
        [_tblBlogDetails reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        if(indexPath.row==1){
            return 150;
        }
        
        NSString *strLink=[dictMarketPlaceDetails objectForKey:@"link"];
        if(strLink.length>3){
            return 395+87;
        }
        return 395;
    }else{
        NSDictionary *dict=[arrComments objectAtIndex:indexPath.row];
        return 90+[self getLabelHeight:[dict objectForKey:@"comment"]];
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        if(arrImages.count>0){
            return 2;
        }
        return 1;
    }else{
        return  arrComments.count;//arrComments.count;
    }
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
        
        if(indexPath.row==1){
            
            UIScrollView *scrollView=[[UIScrollView   alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
            scrollView.pagingEnabled=YES;
            scrollView.showsVerticalScrollIndicator=NO;
            scrollView.showsHorizontalScrollIndicator=NO;
            int XAxix=0;
            for (int i=0; i<arrImages.count; i++) {
                NSDictionary *imgDict=[arrImages objectAtIndex:i];
                AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(XAxix, 0,SCREEN_SIZE.width,150)];
                banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[imgDict objectForKey:@"image"]];
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

            return cell;
        }
        
        
        NSString *strPost=[_dictPost objectForKey:@"post"];
        strPost= [strPost stringByReplacingOccurrencesOfString:@"11+11@img" withString:@"%1%"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%1%(.*?)%1%" options:NSRegularExpressionCaseInsensitive error:NULL];
        
        NSString *input = strPost;
        NSArray *myArray = [regex matchesInString:input options:0 range:NSMakeRange(0, [input length])] ;
        
        NSMutableArray *matches = [NSMutableArray arrayWithCapacity:[myArray count]];
        
        for (NSTextCheckingResult *match in myArray) {
            NSRange matchRange = [match rangeAtIndex:1];
            [matches addObject:[input substringWithRange:matchRange]];
            NSLog(@"%@", [matches lastObject]);
        }
        strPost= [strPost stringByReplacingOccurrencesOfString:@"%1%" withString:@""];
        for (int i=0; i<matches.count; i++) {
             NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,matches[i]];
            NSString *strImage=[NSString stringWithFormat:@"<br><br/><img src='%@'/><br/>",strUrl];
            strPost= [strPost stringByReplacingOccurrencesOfString:matches[i] withString:strImage];
            
        }
        
        UIWebView *webView=[[UIWebView   alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 355)];
        [webView loadHTMLString:strPost baseURL:nil];
        [cell.contentView addSubview:webView];
        
        UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];
        
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, 360, 50, 32);
        
        [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
        
        [btnLike setTitle:[NSString stringWithFormat:@" %@",[dictMarketPlaceDetails objectForKey:@"countLikes"]] forState:UIControlStateNormal];
        
        btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLike.layer.cornerRadius=8;//0,160,223
        btnLike.layer.borderWidth=1;
        btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        
        btnLike.tag=indexPath.row;
        [cell.contentView addSubview:btnLike];
        NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dictMarketPlaceDetails objectForKey:@"isLiked"]];
        
        if([strLikestatus isEqualToString:@"0"]){
            btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }else{
            btnLike.tintColor = [UIColor whiteColor];//
            [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }
        
        UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116, 360, 50, 32)];
        [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [btnComment setTitle:[NSString stringWithFormat:@" %lu",arrComments.count] forState:UIControlStateNormal];
        
        btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnComment.layer.cornerRadius=8;//0,160,223
        btnComment.layer.borderWidth=1;
        btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnComment.tag=indexPath.row;
        
        [cell.contentView addSubview:btnComment];
        
        UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 360, 50, 32)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        
        
        NSString *strUserId=[dictMarketPlaceDetails objectForKey:@"user_id"];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        
        UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, 360, 50, 32)];
        [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
        [btnView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnView setTitle:[NSString stringWithFormat:@" %@",[dictMarketPlaceDetails objectForKey:@"view_count"]] forState:UIControlStateNormal];
        btnView.layer.cornerRadius=10;//0,160,223
        btnView.layer.borderWidth=1;
        btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnView.tag=indexPath.row;
        btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [cell.contentView addSubview:btnView];
        
        
        if([strUserId isEqualToString:USERID]){
            
            UIButton *btnDeleted=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-232, 360, 50, 32)];
            [btnDeleted setTitle:[NSString stringWithFormat:@"Delete"] forState:UIControlStateNormal];
            btnDeleted.titleLabel.font = [UIFont systemFontOfSize:11.0];
            [btnDeleted setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnDeleted.layer.cornerRadius=8;//0,160,223
            btnDeleted.layer.borderWidth=1;
            btnDeleted.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
            btnDeleted.tag=indexPath.row;
            
            [cell.contentView addSubview:btnDeleted];
            
            UIButton *btnEdit=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-290, 360, 50, 32)];
            
            [btnEdit setTitle:[NSString stringWithFormat:@"Edit"] forState:UIControlStateNormal];
            
            btnEdit.titleLabel.font = [UIFont systemFontOfSize:11.0];
            [btnEdit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnEdit.layer.cornerRadius=8;//0,160,223
            btnEdit.layer.borderWidth=1;
            btnEdit.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
            btnEdit.tag=indexPath.row;
            [cell.contentView addSubview:btnEdit];
            
            
            [btnDeleted addTarget:self
                           action:@selector(cmdDeleteList:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            [btnEdit addTarget:self
                        action:@selector(cmdEdit:)
              forControlEvents:UIControlEventTouchUpInside];
            
        }
        
        btnShare.tag=indexPath.row;
        btnShare.layer.cornerRadius=8;//0,160,223
        btnShare.layer.borderWidth=1;
        btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        [cell.contentView addSubview:btnShare];
        
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllVideo:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllVideo:)
             forControlEvents:UIControlEventTouchUpInside];
        [btnShare addTarget:self
                     action:@selector(cmdShareAllvideo:)
           forControlEvents:UIControlEventTouchUpInside];
        
        
        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 394, SCREEN_SIZE.width-40 , 1)];
        sepView.backgroundColor=[UIColor blackColor];
        [cell.contentView addSubview:sepView];
        
        NSString *strLink=[dictMarketPlaceDetails objectForKey:@"link"];
        if(strLink.length>3){
            
            [MTDURLPreview loadPreviewWithURL:[NSURL URLWithString:[dictMarketPlaceDetails objectForKey:@"link"]] completion:^(MTDURLPreview *preview, NSError *error) {
                //preview.imageURL
                NSLog(@"Image Url %@",preview.imageURL);
                NSLog(@"Image Url %@",preview.title);
                NSLog(@"Image Url %@",preview.domain);
                NSLog(@"Image Url %@",preview.content);
                
                
                UIView *subView=[[UIView alloc]initWithFrame:CGRectMake(10,397, SCREEN_SIZE.width-20, 80)];
                [subView.layer setShadowColor:[UIColor blackColor].CGColor];
                [subView.layer setShadowOpacity:0.3];
                [subView.layer setShadowRadius:3.0];
                [subView.layer setShadowOffset:CGSizeMake(1, 1)];
                subView.backgroundColor=[UIColor whiteColor];
                
                AsyncImageView *bannerPost=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 15,50,50)];
                bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                bannerPost.showActivityIndicator=YES;
                bannerPost.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
                bannerPost.imageURL=preview.imageURL;
                [bannerPost setContentMode:UIViewContentModeScaleAspectFill];
                bannerPost.clipsToBounds=YES;
                bannerPost.layer.cornerRadius=0;
                [subView addSubview:bannerPost];
                
                UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(75, 10,subView.frame.size.width-80,40)];
                [lblDescription setFont:[UIFont boldSystemFontOfSize:12]];
                lblDescription.textAlignment=NSTextAlignmentLeft;
                lblDescription.numberOfLines=5;
                lblDescription.lineBreakMode=NSLineBreakByWordWrapping;
                lblDescription.textColor=[UIColor blackColor];
                lblDescription.text=[NSString stringWithFormat:@"%@:%@",preview.title,preview.content];
                [subView addSubview:lblDescription];
                
                UILabel *lblDomein = [[UILabel alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(lblDescription.frame),subView.frame.size.width-80,20)];
                [lblDomein setFont:[UIFont boldSystemFontOfSize:12]];
                lblDomein.textAlignment=NSTextAlignmentLeft;
                lblDomein.numberOfLines=5;
                lblDomein.lineBreakMode=NSLineBreakByWordWrapping;
                lblDomein.textColor=[UIColor blackColor];
                lblDomein.text=[NSString stringWithFormat:@"%@",preview.domain];
                [subView addSubview:lblDomein];
                
                [cell.contentView addSubview:subView];
                sepView.frame=CGRectMake(0, 389+84,SCREEN_SIZE.width , 1);
                sepView.hidden=YES;
                }];
        }
             
        
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
        comment.text = [dict objectForKey:@"comment"];
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
    
    [_tblBlogDetails setFrame:CGRectMake(_tblBlogDetails.frame.origin.x
                                                , _tblBlogDetails.frame.origin.y, _tblBlogDetails.frame.size.width, SCREEN_SIZE.height-114)];
    
    
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
    
    
    [_tblBlogDetails setFrame:CGRectMake(_tblBlogDetails.frame.origin.x
                                                , _tblBlogDetails.frame.origin.y, _tblBlogDetails.frame.size.width, yPoint)];
    
    
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
    
    
    [self.tblBlogDetails reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
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
    [_tblBlogDetails reloadData];
    
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
    [_tblBlogDetails reloadData];
    if([strIsLike isEqualToString:@"0"]){
            //mSocket.emit("likeAcomment", user_id, comment_id);
        [appDelegate().socket emit:@"likeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }else{
        
        [appDelegate().socket emit:@"unLikeAcomment" with:@[USERID,[dict objectForKey:@"comment_id"]]];
    }
    [_tblBlogDetails reloadData];
}

-(void)cmdEdit:(id)sender{
    AddBlogViewController *cont=[[AddBlogViewController alloc]initWithNibName:@"AddBlogViewController" bundle:nil];
    cont.dictDetails=dictMarketPlaceDetails;
    cont.dictPost=_dictPost;
    cont.imageArryDetails=arrImages;
    [self.navigationController pushViewController:cont animated:YES];
}
-(void)cmdDeleteList:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
    [appDelegate().socket emit:@"deleteMyBlog" with:@[USERID,strPost_id]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateBlog" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

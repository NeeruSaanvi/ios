//
//  AllImagesViewController.m
//  iBlah-Blah
//
//  Created by Arun on 03/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AllImagesViewController.h"
#import "CommentImageViewController.h"



@interface AllImagesViewController ()<UIScrollViewDelegate>{
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSArray *pageImages;
    NSMutableArray *pageViews;
     IndecatorView *ind;
    int currentPageValue;
    double xScrollPosition;
    NSString *firstTime;
}

@end

@implementation AllImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstTime=@"yes";
    xScrollPosition=0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"AllImages"
                                               object:nil];

    self.view.backgroundColor = [UIColor blackColor];

    if(_arryGroupImages){
        [ind removeFromSuperview];
        pageImages=_arryGroupImages;
        pageViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < pageImages.count; ++i) {
            [pageViews addObject:@"no"];
        }
        [self showImages];
    }else{
        ind=[[IndecatorView alloc]init];
        [self.view addSubview:ind];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        
        // mSocket.emit("getAllImages", user_id, post_id);
        NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
        [appDelegate().socket emit:@"getAllImages" with:@[USERID,strPost_id]];
        // Do any additional setup after loading the view from its nib.
        [self performSelector:@selector(hideIndecatorView) withObject:nil afterDelay:5.0];
    }
    

    
}
-(void)hideIndecatorView{
    [ind removeFromSuperview];
}

- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"AllImages"]) {
        [ind removeFromSuperview];
        
        if([firstTime isEqualToString:@"no"]){
            return;
        }
        NSDictionary* userInfo;
        NSArray *Arr;
        NSError *jsonError;
        NSData *objectData ;
        NSArray *json ;
        if(_arryGroupImages){
             pageImages=json;
        }else{
            
             userInfo = notification.userInfo;
            Arr=[userInfo objectForKey:@"DATA"];
           
            objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization JSONObjectWithData:objectData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&jsonError];
            
             pageImages=json;
        }
        for (NSInteger i = 0; i < pageViews.count; ++i) {
            [pageViews addObject:@"no"];
        }
        pageViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < pageImages.count; ++i) {
            [pageViews addObject:@"no"];
        }
        
        [self showImages];
      
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        // Load the pages which are now on screen
   // [self loadVisiblePages];
}
-(void)cmdLikeAllPost:(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[pageImages objectAtIndex:btn.tag];
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_liked"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];//
    NSString *strImageId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_id"]];
    if(_arryGroupImages){
        strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
    }
    //mSocket.emit("addToView", user_id, image_id, post_id);
   // [appDelegate().socket emit:@"addToView" with:@[USERID,strImageId,strPost_id]];
   // NSString *strViewCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"view_count"]];
    if([strLikestatus isEqualToString:@"0"]){
        
        [appDelegate().socket emit:@"likeAnImage" with:@[USERID,strImageId,strPost_id]];
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"like_count"]];
        long count = [strLikeCOunt intValue];
      //  long countView = [strViewCOunt intValue];
        
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"like_count"];
        [dictNew setValue:@"1" forKey:@"is_liked"];
      //  [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        NSMutableArray *temp=[pageImages mutableCopy];
        [temp replaceObjectAtIndex:btn.tag withObject:dictNew];
        pageImages=temp;
        
        
    }else{
        [appDelegate().socket emit:@"unLikeAnImage" with:@[USERID,strImageId,strPost_id]];

        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[dict objectForKey:@"countLikes"]];
        long count = [strLikeCOunt intValue];
      //  long countView = [strViewCOunt intValue];
        NSMutableDictionary *dictNew=[dict mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"countLikes"];
       // [dictNew setValue:[NSString stringWithFormat:@"%lu",++countView] forKey:@"view_count"];
        [dictNew setValue:@"0" forKey:@"is_liked"];
        NSMutableArray *temp=[pageImages mutableCopy];
        [temp replaceObjectAtIndex:btn.tag withObject:dictNew];
        pageImages=temp;

    }

    xScrollPosition=scrollView.contentOffset.x;
    [self showImages];
    
  
  
}
-(void)cmdCommentAllPost:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[pageImages objectAtIndex:btn.tag];
    CommentImageViewController *R2VC = [[CommentImageViewController alloc]initWithNibName:@"CommentImageViewController" bundle:nil];
    R2VC.dictPost=_dictPost;
    R2VC.dictPostImage=dict;
 //  [self.navigationController presentViewController:R2VC animated:YES completion:nil];
    [self.navigationController pushViewController:R2VC animated:YES];
}
-(void)cmdShareAllPost:(id)sender{
     UIButton *btn=(UIButton *)sender;

    NSDictionary *dict=[pageImages objectAtIndex:btn.tag];

    [SupportClass shareWithOtherAppRefrenceClass:self withImagesArray:[[dict objectForKey:@"image"] componentsSeparatedByString:@","] withTitle:[NSString stringWithFormat:@"%@",[dict objectForKey:@"desciption"]] withLat:[dict objectForKey:@"lat"] withLong:[dict objectForKey:@"lon"]];
/*
    NSArray *arraImages = [[dict objectForKey:@"images"] componentsSeparatedByString:@","];


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


//
//    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 20,50,50)];
//    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
//    NSURL *url=[NSURL URLWithString:strUrl];
//    banner.imageURL=url;
//
//    UIImage *anImage = banner.image;
//    NSArray *Items   = [NSArray arrayWithObjects:
//                        anImage, nil];

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
    }*/
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
-(void)showImages{

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    CGFloat topPadding = window.safeAreaInsets.top;
    CGFloat bottomPadding = window.safeAreaInsets.bottom;



    [scrollView removeFromSuperview];
    scrollView=nil;
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, topPadding, SCREEN_SIZE.width,SCREEN_SIZE.height-bottomPadding-bottomPadding)];
    scrollView.delegate=self;
    scrollView.pagingEnabled=YES;
    scrollView.bounces=NO;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    

    for (int page=0; page<pageImages.count; page++) {
        
        
        CGRect frame = scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        int heightVlaue=50;
        
//        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
//            
//            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//                case 2436:
//                    heightVlaue=200;
//                    break;
//                   
//            }
//        }




        NSDictionary *dict=[pageImages objectAtIndex:page];
        UIView *newPageView=[[UIView alloc]initWithFrame:frame];
        AsyncImageView *backImg=[[AsyncImageView alloc]initWithFrame:CGRectMake(0,   40, scrollView.frame.size.width,scrollView.frame.size.height  - heightVlaue)];//background Image
        backImg.contentMode = UIViewContentModeScaleAspectFit;
        backImg.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%simages/%@",BASEURl,[dict objectForKey:@"image"]];
        NSURL *url=[NSURL URLWithString:strUrl];

        [backImg sd_setImageWithURL:url placeholderImage:nil];
//        backImg.imageURL=url;
        [newPageView addSubview:backImg];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallButtonTapped:)];
        [backImg addGestureRecognizer:tap];
        [backImg setUserInteractionEnabled:YES];
        
        UIButton *btnLike=[UIButton buttonWithType:UIButtonTypeSystem];//[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-58, 85+[self getLabelHeight:[dict objectForKey:@"discription"]], 50, 32)];
        
        btnLike.frame=CGRectMake(SCREEN_SIZE.width-58, scrollView.frame.size.height-heightVlaue, 50, 32);
        [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];//heart_c
                                                                                      //    countLikes = 4;
                                                                                      //    countcomments = 2;
                                                                                      //view_count

        NSString *strCount = [dict objectForKey:@"like_count"];

        if([[dict objectForKey:@"like_count"] intValue] > 99)
        {
            strCount = @"99+";
        }
        [btnLike setTitle:[NSString stringWithFormat:@" %@",strCount] forState:UIControlStateNormal];


//        [btnLike setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"like_count"]] forState:UIControlStateNormal];
        [newPageView addSubview:btnLike];
        
        
        [btnLike addTarget:self
                    action:@selector(cmdLikeAllPost:)
          forControlEvents:UIControlEventTouchUpInside];
        
        
        btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLike.layer.cornerRadius=10;//0,160,223
        btnLike.layer.borderWidth=1;
        btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        
        
        NSString *strLikestatus=[NSString stringWithFormat:@"%@",[dict objectForKey:@"is_liked"]];
        if([strLikestatus isEqualToString:@"0"]){
            btnLike.tintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }else{
            btnLike.tintColor = [UIColor whiteColor];//
            [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLike.backgroundColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
        }
        //btnLike.titleLabel.textColor = [UIColor whiteColor];
        [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        btnLike.tag=page;


        UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-116,scrollView.frame.size.height-heightVlaue , 50, 32)];
        [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];

        NSString *strCommentCount = [dict objectForKey:@"comment_count"];

        if([strCommentCount intValue] > 99)
        {
            strCommentCount = @"99+";
        }
        [btnComment setTitle:[NSString stringWithFormat:@" %@",strCommentCount] forState:UIControlStateNormal];


//        [btnComment setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"comment_count"]] forState:UIControlStateNormal];
        [btnComment addTarget:self
                       action:@selector(cmdCommentAllPost:)
             forControlEvents:UIControlEventTouchUpInside];
        
        
        btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnComment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnComment.layer.cornerRadius=10;//0,160,223
        btnComment.layer.borderWidth=1;
        btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnComment.tag=page;
        [newPageView addSubview:btnComment];
        
        UIButton *btnView=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-174, scrollView.frame.size.height-heightVlaue, 50, 32)];
        [btnView setImage:[UIImage imageNamed:@"viewPost"] forState:UIControlStateNormal];
        
        [btnView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnView setTitle:[NSString stringWithFormat:@" %@",[dict objectForKey:@"view_count"]] forState:UIControlStateNormal];
        btnView.layer.cornerRadius=8;//0,160,223
        btnView.layer.borderWidth=1;
        btnView.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnView.tag=page;
        btnView.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [newPageView addSubview:btnView];

        
        UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, scrollView.frame.size.height-heightVlaue, 50, 32)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];

        [btnShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [btnShare addTarget:self action:@selector(cmdShareAllPost:) forControlEvents:UIControlEventTouchUpInside];
        
        btnShare.tag=page;
        btnShare.layer.cornerRadius=10;//0,160,223
        btnShare.layer.borderWidth=1;
        btnShare.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;

        [newPageView addSubview:btnShare];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];//
        if(_arryGroupImages){
            strPost_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"post_id"]];//
        }
        NSString *strImageId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"image_id"]];
        NSString *strView=[pageViews objectAtIndex:page];
        if([strView isEqualToString:@"no"]){
            [appDelegate().socket emit:@"addToView" with:@[USERID,strImageId,strPost_id]];
            [pageViews replaceObjectAtIndex:page withObject:@"yes"];
        }
        
        [scrollView addSubview:newPageView];
        
    }
    
    scrollView.contentSize = CGSizeMake(  SCREEN_SIZE.width* pageImages.count,0);
    if([firstTime isEqualToString:@"yes"]){
        
            firstTime=@"no";
            [scrollView setContentOffset:CGPointMake(SCREEN_SIZE.width*_imgNumber, 0) animated:YES];
       
    }else{
        if(xScrollPosition>10){
            [scrollView setContentOffset:CGPointMake(xScrollPosition, 0) animated:YES];
        }
    }
    
    
    [self.view addSubview:scrollView];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, scrollView.frame.origin.y, 100, 40)];
    [btn setTitle:@"X" forState:normal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    btn.titleLabel.font = [UIFont systemFontOfSize:27];
    [btn addTarget:self action:@selector(btnClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


-(IBAction)btnClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

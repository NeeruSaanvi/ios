//
//  CommentVideoViewController.m
//  iBlah-Blah
//
//  Created by Arun on 06/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "CommentVideoViewController.h"
#import "HPGrowingTextView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "LikesViewController.h"

@interface CommentVideoViewController ()<HPGrowingTextViewDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
    NSArray *arrComments;
}

@end

@implementation CommentVideoViewController

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
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 2436:
                _viewHeadder.frame=CGRectMake(_viewHeadder.frame.origin.x, _viewHeadder.frame.origin.y, SCREEN_SIZE.width, 85);
              //  _tblComment.frame=CGRectMake(_tblComment.frame.origin.x, 85, SCREEN_SIZE.width, SCREEN_SIZE.height-85-50);
                break;
            default:
                printf("unknown");
        }
    }
     _lblHeadder.frame=CGRectMake(0, _lblHeadder.frame.origin.y, SCREEN_SIZE.width, _lblHeadder.frame.size.height);
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
   [appDelegate().socket emit:@"getcmnts" with:@[USERID,strPost_id]];
    [appDelegate().socket emit:@"addToView" with:@[USERID,@"",strPost_id]];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"ALLComment"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        //        NSError *jsonError;
        //        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        //        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
        //                                                        options:NSJSONReadingMutableContainers
        //                                                          error:&jsonError];
        
        //NSDictionary *dict=json;
        arrComments = [Arr objectAtIndex:1];
        NSString *strCount=[NSString stringWithFormat:@"%lu",arrComments.count];
        NSArray *arryData=@[@"",[_dictPost objectForKey:@"id"],strCount];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        [dict setValue:arryData forKey:@"DATA"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"getCommentCount"
         object:self userInfo:dict];
        //[[dict objectForKey:@"posts"] mutableCopy];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:strCount forKey:@"comments_count"];
        _dictPost=dictNew;
        
        
        [_tblComment reloadData];
        if(arrComments.count>0){
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: arrComments.count-1 inSection: 1];
            [_tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            
        }

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

- (IBAction)cmdBack:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 225;
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
        
        AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        NSString *strUrl=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"video_thumb"]];
        banner.imageURL=[NSURL URLWithString:strUrl];
        banner.clipsToBounds=YES;
        [banner setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:banner];
        
        AsyncImageView *playicon=[[AsyncImageView alloc]initWithFrame:CGRectMake((SCREEN_SIZE.width/2)-16, 59,32,32)];
        playicon.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
        playicon.image=[UIImage imageNamed:@"playIcon"];
        playicon.clipsToBounds=YES;
        [playicon setContentMode:UIViewContentModeScaleAspectFill];
        [cell.contentView addSubview:playicon];
        UIButton *btnPlayVideo = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,SCREEN_SIZE.width,150)];
        
        btnPlayVideo.tag=indexPath.row;
        [cell.contentView addSubview:btnPlayVideo];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(8, 150,self.view.frame.size.width-16,20)];
        [name setFont:[UIFont boldSystemFontOfSize:16]];
        name.textAlignment=NSTextAlignmentLeft;
        name.numberOfLines=2;
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textColor=[UIColor blackColor];
        name.text=[_dictPost objectForKey:@"title"];
        [cell.contentView addSubview:name];
        UIButton *btnMore=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-41, name.frame.origin.y, 25, 25)];
        [btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];//heart_c
        btnMore.tag=indexPath.row;
        [cell.contentView addSubview:btnMore];
        [btnPlayVideo addTarget:self
                         action:@selector(cmdplayAllVideo:)
               forControlEvents:UIControlEventTouchUpInside];
        [btnMore addTarget:self action:@selector(cmdMoreALLVideo:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *byWhome = [[UILabel alloc] initWithFrame:CGRectMake(8, 170,self.view.frame.size.width-16,20)];
        [byWhome setFont:[UIFont boldSystemFontOfSize:16]];
        byWhome.textAlignment=NSTextAlignmentLeft;
        byWhome.numberOfLines=2;
        byWhome.lineBreakMode=NSLineBreakByWordWrapping;
        byWhome.textColor=[UIColor blackColor];
        byWhome.text=[NSString stringWithFormat:@"By %@",[_dictPost objectForKey:@"name"]];
        [cell.contentView addSubview:byWhome];
        
        
        UIButton *btnLike=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-52, 190, 40, 32)];
        [btnLike setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
        
        [btnLike setTitle:[NSString stringWithFormat:@" %@",[_dictPost objectForKey:@"likes_count"]] forState:UIControlStateNormal];
        
        btnLike.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnLike setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnLike.layer.cornerRadius=8;//0,160,223
        btnLike.layer.borderWidth=1;
        btnLike.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        
        btnLike.tag=indexPath.row;
        [cell.contentView addSubview:btnLike];
        UIButton *btnComment=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-100, 190, 40, 32)];
        [btnComment setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [btnComment setTitle:[NSString stringWithFormat:@" %@",[_dictPost objectForKey:@"comments_count"]] forState:UIControlStateNormal];
        
        btnComment.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnComment.layer.cornerRadius=8;//0,160,223
        btnComment.layer.borderWidth=1;
        btnComment.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
        btnComment.tag=indexPath.row;
        
        [cell.contentView addSubview:btnComment];
        
        UIButton *btnShare=[[UIButton alloc]initWithFrame:CGRectMake(20, 190, 40, 32)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        
        
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
       
      
        
        
        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 224, SCREEN_SIZE.width-40 , 1)];
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
     //   userProImgVw.image=[UIImage imageNamed:@"Logo"];
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
        
        
        NSString *strDate=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"date"]];
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
        
        
        UILabel *comment=[[UILabel alloc] initWithFrame:CGRectMake(60, 43, SCREEN_SIZE.width-70, [self getLabelHeight:[dict objectForKey:@"comment"]])];//
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
        }
       
        UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(0, 89+[self getLabelHeight:[dict objectForKey:@"comment"]], SCREEN_SIZE.width, 1)];//
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
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
    
    NSString *strLikeCount=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likes_count"]];
    int LikeCount=[strLikeCount intValue];
    
    UILabel *Likes=[[UILabel alloc] initWithFrame:CGRectMake(0 , 44, SCREEN_SIZE.width, 20)];
    NSString *strISLike=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"islike"]];
    if([strISLike isEqualToString:@"1"]){
        Likes.text = [NSString stringWithFormat:@"You and %d other like the post",--LikeCount];
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
    LikesViewController *R2VC = [[LikesViewController alloc]initWithNibName:@"LikesViewController" bundle:nil];
    R2VC.dictPost=_dictPost;
    [self.navigationController pushViewController:R2VC animated:YES];
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
    [AlertView showAlertWithMessage:@"comment added successfully." view:self];
    [self.view endEditing:YES];
    NSString *postId=[_dictPost objectForKey:@"id"];
    NSString *uuid = [[NSUUID UUID] UUIDString];
        //emit("commentONPost", user_id, post_id, comment, sender_image, sender_name, comment_id, page_id)
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"commentONPost" with:@[USERID,postId,comment,[_dictPost objectForKey:@"image"],[_dictPost objectForKey:@"name"],uuid,@"1"]];
        //    IndecatorView *ind=[[IndecatorView alloc]init];
        //    [self.view addSubview:ind];
    [self performSelector:@selector(newfetch) withObject:nil afterDelay:3];
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
-(void)cmdplayAllVideo:(id)sender{
    
    
    NSString *strURl=[_dictPost objectForKey:@"video_url"];
    [self playVideo:strURl];
    
    
}
-(void)playVideo:(NSString *)strUrl{
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *videoURL = [NSURL URLWithString:strUrl];
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
}

-(void)cmdMoreALLVideo:(id)sender{
    [self moreOpetion:_dictPost];
}
-(void)moreOpetion:(NSDictionary *)dict{
    NSString *videoId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
    NSString *strIsFav=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isFav"]];
    NSString *strIsWatchLater=[NSString stringWithFormat:@"%@",[dict objectForKey:@"isWatchLater"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    if([strIsFav isEqualToString:@"1"]){
        UIAlertAction* btnWatchLater = [UIAlertAction actionWithTitle:@"Remove from watch later"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            [appDelegate().socket emit:@"removelaterVideo" with:@[USERID,videoId]];
                                           
                                        }];
        [alert addAction:btnWatchLater];
    }else{
        UIAlertAction* btnWatchLater = [UIAlertAction actionWithTitle:@"Watch later"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            [appDelegate().socket emit:@"laterVideo" with:@[USERID,videoId]];
                                           
                                        }];
        [alert addAction:btnWatchLater];
    }
    
    if([strIsWatchLater isEqualToString:@"1"]){
        UIAlertAction* btnFavorite = [UIAlertAction actionWithTitle:@"Remove from favorite"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          [appDelegate().socket emit:@"removefavVideo" with:@[USERID,videoId]];
                                         
                                      }];
        [alert addAction:btnFavorite];
    }else{
        UIAlertAction* btnFavorite = [UIAlertAction actionWithTitle:@"Favorite"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                      {
                                          [appDelegate().socket emit:@"favVideo" with:@[USERID,videoId]];
                                         
                                      }];
        [alert addAction:btnFavorite];
    }
    
    
    UIAlertAction* btnAddPlayList = [UIAlertAction actionWithTitle:@"Add to playlist"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         
                                         [AlertView showAlertWithMessage:@"Comming soon." view:self];
                                     }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
    
    
    [alert addAction:btnAddPlayList];
    [alert addAction:cancel];
    if ( IDIOM == IPAD ) {
        /* do something specifically for iPad. */
        
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alert
                                                         popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = self.view.bounds;
        
    }
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)cmdLikeAllVideo:(id)sender{
    
    NSString *strLikestatus=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"islike"]];//post_id
    NSString *strPost_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"id"]];//
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if([strLikestatus isEqualToString:@"0"]){
        
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likes_count"]];
        long count = [strLikeCOunt intValue];
        
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",++count] forKey:@"likes_count"];
        [dictNew setValue:@"1" forKey:@"likestatus"];
        
        _dictPost=dictNew;
         [appDelegate().socket emit:@"likeApost" with:@[USERID,[_dictPost objectForKey:@"id"],@"0"]];
        
    }else{
        
        
        NSString *strLikeCOunt=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"likes_count"]];
        long count = [strLikeCOunt intValue];
        NSMutableDictionary *dictNew=[_dictPost mutableCopy];
        [dictNew setValue:[NSString stringWithFormat:@"%lu",--count] forKey:@"likes_count"];
        [dictNew setValue:@"0" forKey:@"likestatus"];
        
        _dictPost=dictNew;
       
  [appDelegate().socket emit:@"unlikeApost" with:@[USERID,[_dictPost objectForKey:@"id"],@"0"]];
        
    }
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    NSArray *arryData=@[@"",[_dictPost objectForKey:@"id"],[_dictPost objectForKey:@"likes_count"]];
    
    [dict setValue:arryData forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LikeClicked"
     object:self userInfo:dict];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    
    [self.tblComment reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tblComment reloadData];
}
-(void)cmdCommentAllVideo:(id)sender{
}
-(void)cmdShareAllvideo:(id)sender{
    NSString *strURl=[_dictPost objectForKey:@"video_url"];
    
    NSArray *Items   = [NSArray arrayWithObjects:
                        strURl,@"\n\nDownload to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
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
    [_tblComment reloadData];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"refreshMyPlayList"
     object:self userInfo:nil];
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

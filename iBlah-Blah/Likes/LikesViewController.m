//
//  LikesViewController.m
//  iBlah-Blah
//
//  Created by webHex on 12/07/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "LikesViewController.h"

@interface LikesViewController (){
    NSArray *aryLikeUser;
}

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //mSocket.emit("getLikes", user_id, post_id);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getLikeUser"
                                               object:nil];
    
    
    NSString *post_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getLikes" with:@[USERID,post_id]];
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"getLikeUser"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        aryLikeUser=[Arr objectAtIndex:1];
        [_tblLikes reloadData];
        NSLog(@"%@",Arr);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryLikeUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  //  NSDictionary *dict1=[arryNotification objectAtIndex:indexPath.row];
    NSDictionary *dict=[aryLikeUser objectAtIndex:indexPath.row];//
    
    NSString *strNotiID=[NSString stringWithFormat:@"noti_id"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"readNotifications" with:@[USERID,strNotiID]];
    
    AsyncImageView *imgUserImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 8, 60, 60)];
    imgUserImage.layer.cornerRadius =30;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image_id"]];
    imgUserImage.imageURL=[NSURL URLWithString:strUrl];
    // imgUserImage.image = [UIImage imageNamed:@"Logo"];
    imgUserImage.clipsToBounds=YES;
    [imgUserImage setContentMode:UIViewContentModeScaleAspectFill];
    imgUserImage.layer.borderWidth=1;
    imgUserImage.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    [cell.contentView addSubview:imgUserImage];
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(imgUserImage.frame.origin.x+imgUserImage.frame.size.width+8, imgUserImage.frame.origin.y, 200, 60)];
    [lblName setFont:[UIFont boldSystemFontOfSize:14.0]];
    lblName.text = [dict objectForKey:@"name"];
    [cell.contentView addSubview:lblName];
    
//    UILabel *lblmessage = [[UILabel alloc]initWithFrame:CGRectMake(imgUserImage.frame.origin.x+imgUserImage.frame.size.width+8, lblName.frame.origin.y+lblName.frame.size.height+1, 200, 30)];
//    lblmessage.text = [dict objectForKey:@"msg"];
//    lblmessage.font = [lblmessage.font fontWithSize:12.0];
//    [cell.contentView addSubview:lblmessage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

@end

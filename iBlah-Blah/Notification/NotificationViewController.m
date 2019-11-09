//
//  NotificationViewController.m
//  iBlah-Blah
//
//  Created by webHex on 06/06/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "NotificationViewController.h"
#import "CommentViewController.h"
#import "AllImagesViewController.h"
#import "MarketPlaceDetailsViewController.h"
#import "BlogDetailsViewController.h"
@interface NotificationViewController (){
    NSArray *arryNotification;
}

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"Notification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"NotificationList"
                                               object:nil];
    [self getNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedNotification:(NSNotification *) notification {

    
    if ([[notification name] isEqualToString:@"NotificationList"]){
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        arryNotification=[Arr objectAtIndex:1];
        [_tblNotification reloadData];
     //   NSLog(@"%@",json);
    }


}
     


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arryNotification.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict1=[arryNotification objectAtIndex:indexPath.row];
    NSDictionary *dict=[dict1 objectForKey:@"noti_data"];//

    NSString *strNotiID=[NSString stringWithFormat:@"%@",[dict objectForKey:@"noti_id"]];
    
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
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(imgUserImage.frame.origin.x+imgUserImage.frame.size.width+8, imgUserImage.frame.origin.y, 200, 30)];
    [lblName setFont:[UIFont boldSystemFontOfSize:14.0]];
    lblName.text = [dict objectForKey:@"name"];
    [cell.contentView addSubview:lblName];
    
    UILabel *lblmessage = [[UILabel alloc]initWithFrame:CGRectMake(imgUserImage.frame.origin.x+imgUserImage.frame.size.width+8, lblName.frame.origin.y+lblName.frame.size.height+1, 200, 30)];
    lblmessage.text = [dict objectForKey:@"msg"];
    lblmessage.font = [lblmessage.font fontWithSize:12.0];
    [cell.contentView addSubview:lblmessage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
//case 1://Message
//case 2://Post Like
//case 3://Post Comment
//case 4://Event Comment
//case 5://Image Like
//case 6://Image Comment
//case 7://Video Like
//case 8://Listing Like
//case 9:// Blog Like
//case 10:// Event Like
    
    
    NSDictionary *dictMain=[arryNotification objectAtIndex:indexPath.row];
    NSDictionary *dictNotifyData=[dictMain objectForKey:@"noti_data"];
    NSDictionary *dictPostData=[dictMain objectForKey:@"post_data"];
    
    NSString *type=[NSString stringWithFormat:@"%@",[dictNotifyData objectForKey:@"type"]];
    if([type isEqualToString:@"0"]){
        
    }else if([type isEqualToString:@"1"]){
        CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        cont.dictPost=dictPostData;
        
        [self.navigationController pushViewController:cont animated:YES];
    }else if([type isEqualToString:@"2"]){//Post Like
        CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        cont.dictPost=dictPostData;
       
        [self.navigationController pushViewController:cont animated:YES];
    }else if([type isEqualToString:@"3"]){////Post Comment
        CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        cont.dictPost=dictPostData;
        
        [self.navigationController pushViewController:cont animated:YES];
    }else if([type isEqualToString:@"4"]){////Event Comment
        
        CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        cont.dictPost=dictPostData;
        
        [self.navigationController pushViewController:cont animated:YES];
        
    }else if([type isEqualToString:@"5"]){//Image Like
        AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
        R2VC.dictPost=dictPostData;
        [self.navigationController pushViewController:R2VC animated:YES];
    }else if([type isEqualToString:@"6"]){
        AllImagesViewController *R2VC = [[AllImagesViewController alloc]initWithNibName:@"AllImagesViewController" bundle:nil];
        R2VC.dictPost=dictPostData;
        [self.navigationController pushViewController:R2VC animated:YES];
    }else if([type isEqualToString:@"7"]){//Listing Like
//        MarketPlaceDetailsViewController *cont=[[MarketPlaceDetailsViewController alloc]initWithNibName:@"MarketPlaceDetailsViewController" bundle:nil];
//        cont.dictPost=dictPostData;
//        [self.navigationController pushViewController:cont animated:YES];
    }else if([type isEqualToString:@"9"]){//Blog Like
//        BlogDetailsViewController *cont=[[BlogDetailsViewController alloc]initWithNibName:@"BlogDetailsViewController" bundle:nil];
//            cont.dictPost=dictPostData;
//        [self.navigationController pushViewController:cont animated:YES];
    }else if([type isEqualToString:@"10"]){//Event Like
        CommentViewController *cont=[[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        cont.dictPost=dictPostData;
        
        [self.navigationController pushViewController:cont animated:YES];
    }
    
}

- (IBAction)cmdClearAll:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
     [appDelegate().socket emit:@"dltAllNotifications" with:@[USERID]];
    arryNotification =nil;
    [_tblNotification reloadData];
}

-(void)getNotification{
//    IndecatorView *ind=[[IndecatorView alloc]init];
//    [self.view addSubview:ind];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllNotifications" with:@[USERID]];

//    [[ApiClient  sharedInstance]getNotification:^(id responseObject) {
//        [ind removeFromSuperview];
//        NSDictionary *dict=responseObject;
//        arryNotification=[dict objectForKey:@"posts"];
//        [_tblNotification   reloadData];
//
//    } failure:^(AFHTTPSessionManager *operation, NSString *errorString) {
//        NSLog(@"%@",errorString);
//        [ind removeFromSuperview];
//        [AlertView showAlertWithMessage:@"Something went wrong please try again" view:self];
//    }];
}


@end

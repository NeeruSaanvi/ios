//
//  AttendingViewController.m
//  iBlah-Blah
//
//  Created by webHex on 13/07/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "AttendingViewController.h"

@interface AttendingViewController (){
    NSArray *aryAttendingUser;
}

@end

@implementation AttendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // mSocket.emit("getAllAttending", user_id, post_id, type);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"getAllAttending"
                                               object:nil];
    
    
    NSString *post_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllAttending" with:@[USERID,post_id,@"1"]];
    self.title=@"Attending People";
}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"getAllAttending"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        aryAttendingUser =[json mutableCopy];
        [_tblAttending reloadData];
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
    return aryAttendingUser.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //  NSDictionary *dict1=[arryNotification objectAtIndex:indexPath.row];
    NSDictionary *dict=[aryAttendingUser objectAtIndex:indexPath.row];//
    
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

- (IBAction)cmdSegment:(id)sender {
    
}

- (IBAction)cmdValueChanged:(id)sender {
    NSString *post_id=[NSString stringWithFormat:@"%@",[_dictPost objectForKey:@"post_id"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    if(_btnSegment.selectedSegmentIndex==0){
        [appDelegate().socket emit:@"getAllAttending" with:@[USERID,post_id,@"1"]];
    }
    else if(_btnSegment.selectedSegmentIndex==1){
        [appDelegate().socket emit:@"getAllAttending" with:@[USERID,post_id,@"2"]];
    }
    else{
        [appDelegate().socket emit:@"getAllAttending" with:@[USERID,post_id,@"3"]];
    }
}
@end

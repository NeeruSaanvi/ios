//
//  BlockUserViewController.m
//  iBlah-Blah
//
//  Created by webHex on 07/08/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "BlockUserViewController.h"

@interface BlockUserViewController (){
    NSArray *arryData;
}

@end

@implementation BlockUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GETAllBlockedUsers"
                                               object:nil];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getAllBlockedUsers" with:@[USERID]];
    self.title=@"Blocked User";

}
- (void)receivedNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"GETAllBlockedUsers"]) {
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryData =json;
        [_tblBlock reloadData];
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
    return arryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //  NSDictionary *dict1=[arryNotification objectAtIndex:indexPath.row];
    NSDictionary *dict=[arryData objectAtIndex:indexPath.row];//
    
    NSString *strNotiID=[NSString stringWithFormat:@"noti_id"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"readNotifications" with:@[USERID,strNotiID]];
    
    AsyncImageView *imgUserImage=[[AsyncImageView alloc]initWithFrame:CGRectMake(8, 8, 60, 60)];
    imgUserImage.layer.cornerRadius =30;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
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
    
    UIButton *btnAccept = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lblName.frame)+5, 17, SCREEN_SIZE.width-CGRectGetMaxX(lblName.frame)-10, 42)];
    [btnAccept addTarget:self
                  action:@selector(cmdUnBlock:)
        forControlEvents:UIControlEventTouchUpInside];
    btnAccept.tag=indexPath.row;
    btnAccept.backgroundColor=[UIColor colorWithRed:0/255.0 green:153/255.0 blue:204/255.0 alpha:1.0];
    [btnAccept setTitle:@"Un Block" forState:UIControlStateNormal];
    [btnAccept setBackgroundColor:[UIColor colorWithRed:31/255.0 green:152/255.0 blue:207/255.0 alpha:1.0]];////31,152,207
    btnAccept.layer.cornerRadius=4;
    [btnAccept.titleLabel setFont:[UIFont boldSystemFontOfSize:17 ]];
    [cell.contentView  addSubview:btnAccept];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}
-(void)cmdUnBlock:(id)sender{
    UIButton *btn=(UIButton *)sender;
    NSDictionary *dict=[arryData objectAtIndex:btn.tag];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Attention!"
                                 message:@"Are You Sure Want to Unblock."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                   //mSocket.emit("unblockAfriend", blocked_user, user_id, id, 6700);
                                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                                    NSString *USERID = [prefs stringForKey:@"USERID"];
                                    [appDelegate().socket emit:@"unblockAfriend" with:@[[dict objectForKey:@"blocked_user"],USERID,[dict objectForKey:@"id"],@"6700"]];
                                    
                                    
                                    NSMutableArray *tempArry=[arryData mutableCopy];
                                    [tempArry removeObjectAtIndex:btn.tag];
                                    arryData=tempArry;
                                    [_tblBlock reloadData];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];}
@end

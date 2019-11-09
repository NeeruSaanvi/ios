//
//  SettingViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "SettingViewController.h"
#import "PersonalInfo ViewController.h"
#import "ProileViewController.h"
#import "ForgotPassViewController.h"
#import "BlockUserViewController.h"
@interface SettingViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSArray *arrySection;
    NSArray *arrSection1;
    NSArray *arrSection2;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
   // @"Primary Language",@"Time Zone",@"Preffered Currency"
    arrSection1=@[@"Personal Information",@"Password",@"Blocked User"];
    arrySection=@[@"Account Setting"];
    arrSection2=@[@"Profile",@"Items",@"Notifications",@"Blocked Users"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrySection.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==4){
        return 200;
    }
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return  arrSection1.count;
    }else if(section==1){
        return  arrSection2.count;
    }
    
    return 0;
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
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if(indexPath.section==0){
        
        cell.textLabel.text=[arrSection1 objectAtIndex:indexPath.row];
        
    }else if(indexPath.section==1){
        cell.textLabel.text=[arrSection2 objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section==0){
        if(indexPath.row==0){
            PersonalInfo_ViewController *cont=[[PersonalInfo_ViewController alloc]initWithNibName:@"PersonalInfo ViewController" bundle:nil];
            [self.navigationController pushViewController:cont animated:YES];
        }else if(indexPath.row==1){
             ForgotPassViewController*cont=[[ForgotPassViewController alloc]initWithNibName:@"ForgotPassViewController" bundle:nil];
            [self.navigationController pushViewController:cont animated:YES];
        }else if (indexPath.row==2){
            BlockUserViewController*cont=[[BlockUserViewController alloc]initWithNibName:@"BlockUserViewController" bundle:nil];
            [self.navigationController pushViewController:cont animated:YES];
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 40)];
    view.backgroundColor=[UIColor clearColor];
    UILabel *type = [[UILabel alloc] initWithFrame:CGRectMake(10, 20,view.frame.size.width-20,20)];
    type.font=[UIFont boldSystemFontOfSize:16];
    type.textAlignment=NSTextAlignmentLeft;
    type.numberOfLines=2;
    type.lineBreakMode=NSLineBreakByWordWrapping;
    
    type.text=[arrySection objectAtIndex:section];
    type.textColor=[UIColor darkGrayColor];
    [view addSubview:type];
    return view;
}
-(void)setNavigationBar{
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        //        statusBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gradient_large"]];
        statusBar.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont systemFontOfSize:17.0f],
      NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    self.title=@"SETTINGS";
    self.navigationController.navigationBarHidden=NO;
}

@end

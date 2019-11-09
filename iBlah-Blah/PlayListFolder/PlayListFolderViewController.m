//
//  PlayListFolderViewController.m
//  iBlah-Blah
//
//  Created by webHex on 28/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PlayListFolderViewController.h"

@interface PlayListFolderViewController ()
@property (nonatomic,retain)NSIndexPath * checkedIndexPath ;
@end

@implementation PlayListFolderViewController{
    
    NSArray *arryPlayListName;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"MyPlayListName"
                                               object:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket emit:@"getMyPlayList" with:@[USERID]];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"MyPlayListName"]) {
        
        NSDictionary* userInfo = notification.userInfo;
        NSArray *Arr=[userInfo objectForKey:@"DATA"];
        
        NSError *jsonError;
        NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&jsonError];
        arryPlayListName = json;
        if (arryPlayListName.count ==0) {
            _tblPlaylist.hidden =YES;
            
            _lbl.hidden= NO;
        }else{
            _lbl.hidden= YES;
            _tblPlaylist.hidden=NO;
            [_tblPlaylist reloadData];
        }
        //arryMyVideo=arryVideo;
        [_tblPlaylist reloadData];
    }
}

#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryPlayListName.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:
            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict=[arryPlayListName objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"playlist_name"];
    if(self.checkedIndexPath==indexPath)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(8, 30, self.view.frame.size.width, 44)];
    view.backgroundColor =[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    
    UILabel *comment=[[UILabel alloc] initWithFrame:CGRectMake(8 , 0, SCREEN_SIZE.width, 44)];
    comment.text = @"Add to";
    comment.textColor = [UIColor whiteColor];
    comment.textAlignment = NSTextAlignmentLeft;
    [comment setFont:[UIFont boldSystemFontOfSize:17]];
    [view addSubview:comment];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *fotterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIButton *btnAdd = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [btnAdd addTarget:self
                   action:@selector(cmdAdd:)
         forControlEvents:UIControlEventTouchUpInside];
    btnAdd.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btnAdd setBackgroundColor:[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0]];
    [btnAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btnAdd setTitle:@"Add to selected playlist" forState:UIControlStateNormal];
    [fotterView addSubview:btnAdd];
    return fotterView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
        return 50;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    [_tblPlaylist reloadData];
}

-(void)cmdAdd:(id)sender{
    if(self.checkedIndexPath){
        NSDictionary *dict=[arryPlayListName objectAtIndex:self.checkedIndexPath.row];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"addToPlayList" with:@[USERID,[dict objectForKey:@"playlist_id"],[self.dictVideoData objectForKey:@"id"]]];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshMyPlayList"
         object:self userInfo:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [AlertView showAlertWithMessage:@"Please select playlist name fisrt" view:self];
    }
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
    
    self.title=@"Add Playlist Name";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setImage:[UIImage imageNamed:@"PlusIcon"] forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 32, 32);
    
    [btnClear addTarget:self action:@selector(cmdAddPlaylist:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)cmdAddPlaylist:(id)sender{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Create Playlist"
                                                                              message: @""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter Playlist Name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
       // emit("createPlayList" , user_id, playlistName, video_id)
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        NSLog(@"%@",namefield.text);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *USERID = [prefs stringForKey:@"USERID"];
        [appDelegate().socket emit:@"createPlayList" with:@[USERID,namefield.text,	[self.dictVideoData objectForKey:@"id"],[self.dictVideoData objectForKey:@"video_thumb"]]];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshMyPlayList"
         object:self userInfo:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

//
//  LanguageViewController.m
//  iBlah-Blah
//
//  Created by webHex on 25/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController (){
    NSArray *arryLanguage;
    NSString *selectedLanguage;
}
@property (nonatomic,retain)NSIndexPath * checkedIndexPath ;

@end

@implementation LanguageViewController
@synthesize checkedIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    // Do any additional setup after loading the view from its nib.
    arryLanguage= @[@"English(US)",@"Hindi",@"German",@"Portuguese",@"Russian",@"French",@"Spainish",@"Dutch"];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *saveData;
    int indexValue=0;
    saveData = [prefs stringForKey:@"SELECTEDLANGUAGE"];
    indexValue = [arryLanguage indexOfObject:saveData];
    if(!(indexValue>=0)){
        indexValue=0;
    }
    NSIndexPath *myIP = [NSIndexPath indexPathForRow:indexValue inSection:1];
    self.checkedIndexPath=myIP;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 
   
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
    
    self.title=@"Select Language";
    self.navigationController.navigationBarHidden=NO;
    
    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Done" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 50, 13);
    
    [btnClear addTarget:self action:@selector(cmdDone:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)cmdDone:(id)sender{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"Are you Sure you want to Change the Language?", nil)
                                 message:NSLocalizedString(@"You need to start the app again by clicking App Icon.", nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* EnglishButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Yes", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                        
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                        [defaults setObject:[arryLanguage objectAtIndex:self.checkedIndexPath.row] forKey:@"SELECTEDLANGUAGE"];
                                        [defaults synchronize];
                                        
//                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                                        [defaults setObject:@"en" forKey:@"SelectedLanguage"];
//                                        [defaults synchronize];
//                                        NSString * l = nil;
//                                        l = @"en";
//                                        [[NSUserDefaults standardUserDefaults]setObject:@"en" forKey:@"AppleLanguages"];
//                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                        exit(0);
                                    }];
    
    UIAlertAction* SpanishButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"No", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                        
                                        
                                    }];
    
    
    //    UIAlertAction* noButton = [UIAlertAction
    //                               actionWithTitle:NSLocalizedString(@"Cancel", nil)
    //                               style:UIAlertActionStyleDefault
    //                               handler:^(UIAlertAction * action) {
    //                                   //Handle no, thanks button
    //
    //                               }];
    
    [alert addAction:EnglishButton];
    [alert addAction:SpanishButton];
    //[alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return arryLanguage.count;
    
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
    if(self.checkedIndexPath.row==indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
        cell.textLabel.text=[arryLanguage objectAtIndex:indexPath.row];
    
    
    return cell;
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
    [_tblLanguage reloadData];
}

@end

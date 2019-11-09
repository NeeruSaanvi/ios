//
//  LocationViewController.m
//  iBlah-Blah
//
//  Created by Arun on 24/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController (){
    NSArray *sortedCountryArray;
    NSMutableArray * searchResults;
    NSString *selectedCountry;
}
@property (nonatomic,retain)NSIndexPath * checkedIndexPath ;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
 
    // Do any additional setup after loading the view from its nib.
    [self getCountry];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.title=@"COUNTRY";
    self.navigationController.navigationBarHidden=NO;
    
    
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Done" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 40, 32);
    
    [btnClear addTarget:self action:@selector(cmdSave:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
}
-(void)cmdSave:(id)sender{
    [self.view endEditing:YES];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:selectedCountry forKey:@"Location"];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MarketplaceLocation"
     object:self userInfo:dict];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getCountry{
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
  NSMutableArray *sortedCountryArray1 = [[NSMutableArray alloc] init];
    
    for (NSString *countryCode in countryArray) {
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        [sortedCountryArray1 addObject:displayNameString];
    }
    
    [sortedCountryArray1 sortUsingSelector:@selector(localizedCompare:)];
    sortedCountryArray=sortedCountryArray1;
    searchResults=[sortedCountryArray1 mutableCopy];
   
}

#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44;
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
            //  cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    cell.textLabel.text=[searchResults objectAtIndex:indexPath.row];
    
    if([cell.textLabel.text isEqualToString:selectedCountry]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    selectedCountry=[searchResults objectAtIndex:indexPath.row];
    [_tblLocation reloadData];
}

#pragma mark searchbar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
    
}
-(void)searchBar:(UISearchBar*)searchbar textDidChange:(NSString*)text
{
    if ([text length] == 0)
    {
        searchResults=[sortedCountryArray mutableCopy];
       
        [self.tblLocation reloadData];
        return;
    }else{
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.view.frame=CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
    }
        //    [arrySelectedValue removeAllObjects];
    
    [searchResults removeAllObjects];
    searchResults=nil;
    searchResults=[[NSMutableArray alloc]init];
   
    for (int i=0; i<sortedCountryArray.count; i++) {
        
        NSString *strName=[sortedCountryArray objectAtIndex:i];
        
        NSRange r=[strName rangeOfString:text options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            
            [searchResults addObject:strName];
        }
        
    }
    
    [self.tblLocation  reloadData];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
    [_searchBar performSelector:@selector(resignFirstResponder)
                     withObject:nil
                     afterDelay:0];
    searchResults=[sortedCountryArray mutableCopy];
    [self.tblLocation reloadData];
}


@end

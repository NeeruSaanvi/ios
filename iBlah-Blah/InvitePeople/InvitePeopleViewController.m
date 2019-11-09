//
//  InvitePeopleViewController.m
//  iBlah-Blah
//
//  Created by webHex on 08/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "InvitePeopleViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>
@interface InvitePeopleViewController (){
    IndecatorView *ind;
    NSArray *arryContact;
    NSMutableArray *searchResults;
    NSMutableArray *arryRowValue;
    NSMutableArray *arrySelectedValue;
    NSArray *AllContact;
    BOOL selectAll;
}

@end

@implementation InvitePeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    selectAll=NO;
    [self askPermissionContact:@"0"];
    // Do any additional setup after loading the view from its nib.
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
    
    self.title=@"INVITE FRIENDS";
    self.navigationController.navigationBarHidden=NO;
    NSMutableArray *arrRightBarItems = [[NSMutableArray alloc] init];
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"Done" forState:UIControlStateNormal];
    btnClear.frame = CGRectMake(0, 0, 40, 32);
    
    [btnClear addTarget:self action:@selector(cmdInvite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btnSearchBar = [[UIBarButtonItem alloc] initWithCustomView:btnClear];
    [arrRightBarItems addObject:btnSearchBar];
    self.navigationItem.rightBarButtonItems=arrRightBarItems;
    
}
-(void)cmdInvite:(id)sender{
    if (arrySelectedValue.count <= 0)
    {
        [AlertView showAlertWithMessage:@"Please select member's to send Invite link" view:self];
    }else{
        NSString *strNumber=@"";
        for (int i=0; i<arrySelectedValue.count; i++)
        {
            NSMutableDictionary *dataDict=[[arrySelectedValue objectAtIndex:i] mutableCopy] ;
            //        [dataDict setObject:@"0" forKey:@"is_host"];
            
            if([strNumber isEqualToString:@""]){
                strNumber= [dataDict objectForKey:@"phone"];
            }else{
                strNumber=[NSString stringWithFormat:@"%@,%@",strNumber, [dataDict objectForKey:@"phone"]];
            }
        }
       // emit("twilioMessages", numbers, message);
        [appDelegate().socket emit:@"twilioMessages" with:@[strNumber,@"Download to know about event helding around you. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                                                            @"Via iBlah-Blah."]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return  60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = nil;
    UITableViewCell * cell  = nil;
    //    cell = [tableView dequeueReusableCellWithIdentifier:
    //            cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:
                cellIdentifier];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary *dict=[searchResults objectAtIndex:indexPath.row];

    
    
    UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(8, 10, 160, 20)];
    lblName.backgroundColor=[UIColor clearColor];
    lblName.numberOfLines=2;
    lblName.lineBreakMode=NSLineBreakByWordWrapping;
    lblName.font = [UIFont fontWithName:@"KabelMedium" size:14];
    lblName.textColor= [UIColor whiteColor];
    
    lblName.text=[dict objectForKey:@"name"];
    lblName.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:lblName];
    lblName.textColor=  [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    UILabel *lblList=[[UILabel alloc]initWithFrame:CGRectMake(8, 30, 200, 25)];
    lblList.backgroundColor=[UIColor clearColor];
    lblList.numberOfLines=2;
    lblList.lineBreakMode=NSLineBreakByWordWrapping;
    lblList.font = [UIFont fontWithName:@"KabelITCbyBT-Book" size:11];
    lblList.textColor= [UIColor whiteColor];
    lblList.text=[dict objectForKey:@"phone"];
    //    lblList.alpha=0.5;
    lblList.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:lblList];
    lblList.textColor=  [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    
    if([_searchBar.text isEqualToString:@""])
    {
        
        //        if ([arrySelectedValue containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        //
        //            banner1.hidden=NO;
        //        }else {
        //            banner1.hidden=YES;
        //        }
        
        for(int i=0; i<arrySelectedValue.count;i++)
        {
            
            if ([[[searchResults objectAtIndex:indexPath.row] valueForKey:@"phone"] isEqualToString:[[arrySelectedValue objectAtIndex:i] valueForKey:@"phone"]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
 
                
                break;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    }
    else
    {
        if(!(arrySelectedValue.count>0))
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        for(int i=0; i<arrySelectedValue.count;i++)
        {
            
            if ([[[searchResults objectAtIndex:indexPath.row] valueForKey:@"phone"] isEqualToString:[[arrySelectedValue objectAtIndex:i] valueForKey:@"phone"]])
            {
              
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                break;
              
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    // NSString *registeration=[dict objectForKey:@"registeration"];
    // if([registeration isEqualToString:@"1"]){

    
    // }
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(39, 59,self.view.frame.size.width-40 , 1)];
    sepView.backgroundColor=[UIColor whiteColor];
    sepView.alpha=0.3;
    [cell.contentView addSubview:sepView];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 40)];
    headerView.backgroundColor=[UIColor whiteColor];
    UIButton *btnSelectAll = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSelectAll setClipsToBounds:false];
    if(selectAll){
        [btnSelectAll setImage:[UIImage imageNamed:@"Checkbox_Tick"] forState:UIControlStateNormal];
    }else{
        [btnSelectAll setImage:[UIImage imageNamed:@"Checkbox_Without Tick"] forState:UIControlStateNormal];
    }
    
    [btnSelectAll setTitle:@"  SelectAll" forState:UIControlStateNormal];
    [btnSelectAll.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [btnSelectAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; // SET the colour for your wishes
    [btnSelectAll setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted]; // SET the colour for your wishes
    [btnSelectAll addTarget:self action:@selector(cmdSelectAll) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btnSelectAll];
    
    UILabel *lblTotal =[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_SIZE.width-100, 0, 90, 40)];
    lblTotal.text = [NSString stringWithFormat:@"Total %lu",arryContact.count];//@"Total 675";
    lblTotal.textAlignment = NSTextAlignmentRight;
    lblTotal.font = [lblTotal.font fontWithSize:12.0];
    [headerView addSubview:lblTotal];
    
    
    return headerView;
}

-(void)cmdSelectAll{
    
    [arrySelectedValue removeAllObjects];
    
    if(selectAll){
        selectAll=NO;
        
    }else{
        selectAll=YES;
        for (int i=0; i<arryContact.count; i++) {
            [arrySelectedValue addObject:[arryContact objectAtIndex:i]];
        }
        
    }
    [self.tblInvite reloadData];
    
    [self showPeople];
}
-(BOOL)firstimage:(UIImage *)image1 isEqualTo:(UIImage *)image2 {
    
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    return [data1 isEqualToData:data2];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([arrySelectedValue containsObject:[searchResults objectAtIndex:indexPath.row]])
    {
        [arrySelectedValue removeObject:[searchResults objectAtIndex:indexPath.row]];
    }
    else
    {
        [arrySelectedValue addObject:[searchResults objectAtIndex:indexPath.row]];
    }
    [self.tblInvite reloadData];
    
    [self showPeople];
    
}
-(void)showPeople{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    float xAxis=0;
    for (int i=0; i<arrySelectedValue.count; i++)
    {
        NSMutableDictionary *dataDict=[[arrySelectedValue objectAtIndex:i] mutableCopy] ;
        //        [dataDict setObject:@"0" forKey:@"is_host"];
        UILabel *lblName=[[UILabel alloc]initWithFrame:CGRectMake(xAxis, 3, [self getLabelHeight:[dataDict objectForKey:@"name"]], 40)];
        lblName.numberOfLines=2;
        lblName.lineBreakMode=NSLineBreakByWordWrapping;
        lblName.font = [UIFont boldSystemFontOfSize:14];
        lblName.textColor= [UIColor whiteColor];
        lblName.backgroundColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];;
        lblName.layer.cornerRadius=8;
        lblName.clipsToBounds=YES;
        lblName.text=[dataDict objectForKey:@"name"];
        lblName.textAlignment = NSTextAlignmentCenter;
        [_scrollView addSubview:lblName];
        xAxis=xAxis+[self getLabelHeight:[dataDict objectForKey:@"name"]]+5;
    }
    
    _scrollView.contentSize = CGSizeMake( xAxis, 40);
    if(xAxis>320){
        CGPoint bottomOffset = CGPointMake( self.scrollView.contentSize.width - self.scrollView.bounds.size.width,0);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
    
    //    CGPoint bottomOffset = CGPointMake(0, xAxis);
    //    [self.scrollView setContentOffset:bottomOffset animated:YES];
    
    //[dict setObject:UserName forKey:@"name"];
}

-(NSArray *)contactArry{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *dict= [defaults objectForKey:@"StoreContactData"];
    NSArray *dictData=dict;
    
    NSSortDescriptor *hopProfileName =
    [[NSSortDescriptor alloc] initWithKey:@"name"
                                ascending:YES];
    
    NSArray *descriptorsname = [NSArray arrayWithObjects:hopProfileName, nil];
    NSArray *arry = [dictData sortedArrayUsingDescriptors:descriptorsname];
    
    
    //    NSSortDescriptor *hopProfileDescriptor =
    //    [[NSSortDescriptor alloc] initWithKey:@"registeration"
    //                                ascending:NO];
    
    //    NSArray *descriptors = [NSArray arrayWithObjects:hopProfileDescriptor, nil];
    //    arry = [arry sortedArrayUsingDescriptors:descriptors];
    return arry;
}


#pragma mark searchbar
-(void)searchBar:(UISearchBar*)searchbar textDidChange:(NSString*)text
{
    if ([text length] == 0)
    {
        searchResults=[arryContact mutableCopy];
        arryRowValue=nil;
        arryRowValue=[[NSMutableArray alloc]init];
        for (int i=0; i<searchResults.count; i++) {
            [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
        }
        [self.tblInvite reloadData];
        [_searchBar performSelector:@selector(resignFirstResponder)
                         withObject:nil
                         afterDelay:0];
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
    [arryRowValue removeAllObjects];
    arryRowValue=nil;
    [searchResults removeAllObjects];
    searchResults=nil;
    searchResults=[[NSMutableArray alloc]init];
    arryRowValue=[[NSMutableArray alloc]init];
    for (int i=0; i<arryContact.count; i++) {
        NSDictionary *Dict=[arryContact objectAtIndex:i];
        NSString *strName=[Dict objectForKey:@"name"];
        
        NSRange r=[strName rangeOfString:text options:NSCaseInsensitiveSearch];
        
        if(r.location != NSNotFound)
        {
            [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
            [searchResults addObject:Dict];
        }
        
    }
    
    [self.tblInvite  reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1{
    
    searchResults=[arryContact mutableCopy];
    arryRowValue=nil;
    arryRowValue=[[NSMutableArray alloc]init];
    for (int i=0; i<searchResults.count; i++) {
        [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tblInvite reloadData];
    
}

-(NSMutableArray *)arryMember{
    
    NSMutableArray * mutableArr = [[NSMutableArray alloc]init];
    
    
    for (int i=0; i<arrySelectedValue.count; i++)
    {
        NSMutableDictionary *dataDict=[[arrySelectedValue objectAtIndex:i] mutableCopy] ;
        //        [dataDict setObject:@"0" forKey:@"is_host"];
        
        [mutableArr addObject:dataDict];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //   NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *UserName=[prefs stringForKey:@"UserName"];
    //   NSString *profilePic=[prefs stringForKey:@"profilePic"];
    NSString *phone=[prefs stringForKey:@"phone"];
    //  NSString *status=[prefs stringForKey:@"status"];
    
    //    NSString *login=[prefs stringForKey:@"quicklogin"];
    //    NSString *full_name=[prefs stringForKey:@"quickfull_name"];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    //  [dict setObject:profilePic forKey:@"image"];
    [dict setObject:UserName forKey:@"name"];
    [dict setObject:phone forKey:@"phone"];
    //    [dict setObject:@"1" forKey:@"registeration"];
    //    [dict setObject:status forKey:@"status"];
    //    [dict setObject:USERID forKey:@"userid"];
    //    [dict setObject:@"0" forKey:@"is_host"];
    
    //    [dict setObject:login forKey:@"login"];
    //    [dict setObject:full_name forKey:@"full_name"];
    [mutableArr addObject:dict];
    return mutableArr;
    
}



#pragma mark ----------contactFetch----------

-(void)checkPermission{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //   dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        //calling function for geting list of contact
        [self askPermissionContact:@"0"];
        
    }else{
        
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"\"KittyBee\" needs access to our contact." message:@"KittyBee requires access to your contacts to show contact list for making kitty group or start chat. Enable the access to contact in Privacy Setting" delegate:self cancelButtonTitle:@"Maybe Later" otherButtonTitles: @"Setting",nil];
        Alert.tag=2001;
        [Alert show];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2001){
        
        if(buttonIndex==0){
            
        }else if(buttonIndex==1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        
        return;
    }
}

-(void)askPermissionContact:(NSString *)background{
    
    
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //   dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        // [self getContactsWithAddressBook:addressBook];
        [self getAllContacts:addressBook background:background];
    }
    
    if (accessGranted) {
        // [self getContactsWithAddressBook:addressBook];
        [self getAllContacts:addressBook background:background];
    }else{
        
        UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"\"KittyBee\" needs access to our contact." message:@"KittyBee requires access to your contacts to show contact list for making kitty group or start chat. Enable the access to contact in Privacy Setting" delegate:self cancelButtonTitle:@"Maybe Later" otherButtonTitles: @"Setting",nil];
        Alert.tag=2001;
        [Alert show];
    }
}

- (void)getAllContacts:(ABAddressBookRef)addressBook background:(NSString *)backGround{
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        //For Email ids
        //        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        //        if(ABMultiValueGetCount(eMail) > 0) {
        //            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        //
        //        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                NSMutableDictionary *dictNumber=[[NSMutableDictionary alloc]init];
                [dictNumber setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
                [dictNumber setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                
                
                NSString *strName=[dictNumber objectForKey:@"name"];
                strName=[strName stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                NSString *StrPhone=[dictNumber objectForKey:@"phone"];
                //StrPhone=[StrPhone stringByReplacingOccurrencesOfString:@"+91" withString:@""];
                StrPhone=[self getNum:StrPhone];
                
//                if ([StrPhone hasPrefix:@"0"] && [StrPhone length] > 1) {
//                    StrPhone = [StrPhone substringFromIndex:1];
//                }
                if ([strName hasPrefix:@" "] && [strName length] > 1) {
                    strName = [strName substringFromIndex:1];
                }
                
                [dictNumber setObject:strName forKey:@"name"];
                [dictNumber setObject:StrPhone forKey:@"phone"];
                [contactList addObject:dictNumber];
                // [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                NSMutableDictionary *dictNumber=[[NSMutableDictionary alloc]init];
                [dictNumber setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
                [dictNumber setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                
                
                NSString *strName=[dictNumber objectForKey:@"name"];
                strName=[strName stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                NSString *StrPhone=[dictNumber objectForKey:@"phone"];
                StrPhone=[StrPhone stringByReplacingOccurrencesOfString:@"+91" withString:@""];
                StrPhone=[self getNum:StrPhone];
                
                if ([StrPhone hasPrefix:@"0"] && [StrPhone length] > 1) {
                    StrPhone = [StrPhone substringFromIndex:1];
                }
                if ([strName hasPrefix:@" "] && [strName length] > 1) {
                    strName = [strName substringFromIndex:1];
                }
                
                [dictNumber setObject:strName forKey:@"name"];
                [dictNumber setObject:StrPhone forKey:@"phone"];
                [contactList addObject:dictNumber];
                
                //                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                
            }else
            {
                
                NSMutableDictionary *dictNumber=[[NSMutableDictionary alloc]init];
                [dictNumber setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
                [dictNumber setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"phone"];
                
                
                NSString *strName=[dictNumber objectForKey:@"name"];
                strName=[strName stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                NSString *StrPhone=[dictNumber objectForKey:@"phone"];
                StrPhone=[StrPhone stringByReplacingOccurrencesOfString:@"+91" withString:@""];
                StrPhone=[self getNum:StrPhone];
                
                if ([StrPhone hasPrefix:@"0"] && [StrPhone length] > 1) {
                    StrPhone = [StrPhone substringFromIndex:1];
                }
                if ([strName hasPrefix:@" "] && [strName length] > 1) {
                    strName = [strName substringFromIndex:1];
                }
                
                [dictNumber setObject:strName forKey:@"name"];
                [dictNumber setObject:StrPhone forKey:@"phone"];
                [contactList addObject:dictNumber];
                
                // [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"Phone"];
                
            }
            
        }
        // [contactList addObject:dOfPerson];
        
    }
    NSLog(@"Contacts = %@",contactList);
    NSArray *dict= contactList;
    NSArray *dictData=dict;
    
    NSSortDescriptor *hopProfileName =
    [[NSSortDescriptor alloc] initWithKey:@"name"
                                ascending:YES];
    
    NSArray *descriptorsname = [NSArray arrayWithObjects:hopProfileName, nil];
    NSArray *arry = [dictData sortedArrayUsingDescriptors:descriptorsname];
    AllContact = arry;
    arryContact = AllContact;
    searchResults=[arryContact mutableCopy];
    arryRowValue=[[NSMutableArray alloc]init];
    arrySelectedValue=[[NSMutableArray alloc]init];
    
    for (int i=0; i<searchResults.count; i++) {
        [arryRowValue addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self.tblInvite reloadData];
    
}
-(NSString *)getNum:(NSString *)number{
    NSMutableString *result = [NSMutableString stringWithCapacity:number.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:number];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
    
    while ([scanner isAtEnd] == NO)
    {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
        {
            [result appendString:buffer];
        }
        else
        {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return result;
}
#pragma dynamic height of textFeild
- (CGFloat)getLabelHeight:(NSString *)strIng
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX, 40);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [strIng boundingRectWithSize:constraint
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}
                                              context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.width;
}
@end

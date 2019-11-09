//
//  ShareViewController.m
//  iBlah-BlahEX
//
//  Created by webHex on 17/08/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "ShareViewController.h"
//#import "AppDelegate.h"
#import "AsyncImageView.h"
#define BASEURl "http://iblah-blah.com/iblah/"
#define SCREEN_SIZE [[UIScreen mainScreen] bounds].size

@interface ShareViewController (){
    NSArray *arryChatList;
}

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

//- (void)didSelectPost {
//
//    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments ) {
//
//        if([itemProvider hasItemConformingToTypeIdentifier:@"public.jpeg"]) {
//            NSLog(@"itemprovider = %@", itemProvider);
//
//            [itemProvider loadItemForTypeIdentifier:@"public.jpeg" options:nil completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
//
//                NSData *imgData;
//                if([(NSObject*)item isKindOfClass:[NSURL class]]) {
//                    imgData = [NSData dataWithContentsOfURL:(NSURL*)item];
//                }
//                if([(NSObject*)item isKindOfClass:[UIImage class]]) {
//                    imgData = UIImagePNGRepresentation((UIImage*)item);
//                }
//
//                NSDictionary *dict = @{
//                                       @"imgData" : imgData,
//                                       @"name" : self.contentText
//                                       };
//                NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.share.extension1"];
//                [defaults setObject:dict forKey:@"img"];
//                [defaults synchronize];
//            }];
//        }
//    }
//
//}


- (void)viewDidLoad
{
    [super viewDidLoad];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //CHATLIST
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];

    arryChatList =[myDefaults objectForKey:@"CHATLIST"];// [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"CHATLIST"]];
    [_tblChat reloadData];
   //
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

- (IBAction)cmdCancle:(id)sender {
    [self.extensionContext cancelRequestWithError:nil];
}


#pragma mark ------------- Table View Delegate Methods ------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arryChatList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80;
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
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    }
    NSDictionary *dict=[arryChatList objectAtIndex:indexPath.row];
    
    AsyncImageView *banner=[[AsyncImageView alloc]initWithFrame:CGRectMake(20, 15,50,50)];
    banner.activityIndicatorStyle=UIActivityIndicatorViewStyleGray;
    NSString *strUrl=[NSString stringWithFormat:@"%sthumb/%@",BASEURl,[dict objectForKey:@"image"]];
    banner.imageURL=[NSURL URLWithString:strUrl];
    banner.clipsToBounds=YES;
    banner.layer.cornerRadius=25;
    [banner setContentMode:UIViewContentModeScaleAspectFill];
    [cell.contentView addSubview:banner];
    [banner setUserInteractionEnabled:YES];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(75, 15,self.view.frame.size.width-190,50)];
    [name setFont:[UIFont boldSystemFontOfSize:16]];
    name.textAlignment=NSTextAlignmentLeft;
    name.numberOfLines=2;
    name.lineBreakMode=NSLineBreakByWordWrapping;
    name.textColor=[UIColor blackColor];
    name.text=[dict objectForKey:@"name"];
    [cell.contentView addSubview:name];
    
    UIView *sepView=[[UIView alloc]initWithFrame:CGRectMake(20, 79, SCREEN_SIZE.width-40, 1)];
    sepView.backgroundColor=[UIColor blackColor];
    [cell.contentView addSubview:sepView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  __block  NSDictionary *dict=[arryChatList objectAtIndex:indexPath.row];
    __block NSString *strMsg=@"";
    __block int loopCount = 0;
    __block int responceCount=0;
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments ) {
        loopCount++;
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.jpeg"]) {
            NSLog(@"itemprovider = %@", itemProvider);
            
            [itemProvider loadItemForTypeIdentifier:@"public.jpeg" options:nil completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                
                NSData *imgData;
                if([(NSObject*)item isKindOfClass:[NSURL class]]) {
                    imgData = [NSData dataWithContentsOfURL:(NSURL*)item];
                }
                if([(NSObject*)item isKindOfClass:[UIImage class]]) {
                    imgData = UIImagePNGRepresentation((UIImage*)item);
                }
                NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
                NSMutableArray *tempArry =[[myDefaults objectForKey:@"ShareMSG"] mutableCopy];
                if(tempArry){
                    NSMutableDictionary *dictToForward=[[NSMutableDictionary alloc]init];
                    dictToForward=[dict mutableCopy];
                    [dictToForward setValue:imgData forKey:@"imgData"];
                    [tempArry addObject:dictToForward];
                }else{
                    tempArry=[[NSMutableArray alloc]init];
                    NSMutableDictionary *dictToForward=[[NSMutableDictionary alloc]init];
                    dictToForward=[dict mutableCopy];
                    [dictToForward setValue:imgData forKey:@"imgData"];
                    [tempArry addObject:dictToForward];
                    
                    
                }
                
                NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
                [defaults setObject:tempArry forKey:@"ShareMSG"];
                [defaults synchronize];
                responceCount++;
                if(loopCount==responceCount){
                    [self saveData:strMsg dict:dict];
                }
            }];
        }
       
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.plain-text"]){
            //__block
            [itemProvider loadItemForTypeIdentifier:@"public.plain-text" options:nil completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                 NSLog(@"DEF");
             //   NSString *str=(NSString*)item;
                strMsg=[NSString stringWithFormat:@"%@ %@",strMsg,(NSString *)item];
                NSLog(@"Hello %@",strMsg);
                responceCount++;
                if(loopCount==responceCount){
                    [self saveData:strMsg dict:dict];
                }
             }];
        }
    }
    
    
   //
}

-(void)saveData:(NSString *)strMsg dict:(NSDictionary *)dict {
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
    NSMutableArray *tempArry =[[myDefaults objectForKey:@"ShareMSG"] mutableCopy];

    if(strMsg.length>0){
        if(tempArry){
            NSMutableDictionary *dictToForward=[[NSMutableDictionary alloc]init];
            dictToForward=[dict mutableCopy];
            [dictToForward setValue:strMsg forKey:@"TextMsg"];
            [tempArry addObject:dictToForward];
        }else{
            tempArry=[[NSMutableArray alloc]init];
            NSMutableDictionary *dictToForward=[[NSMutableDictionary alloc]init];
            dictToForward=[dict mutableCopy];
            [dictToForward setValue:strMsg forKey:@"TextMsg"];
            [tempArry addObject:dictToForward];
        }
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.tag.ChatList"];
        [defaults setObject:tempArry forKey:@"ShareMSG"];
        [defaults synchronize];
    }
    [self.extensionContext cancelRequestWithError:nil];
}
@end

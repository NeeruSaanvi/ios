//
//  AlertView.m
//  MyVideoTech
//
//  Created by OSX on 14/01/16.
//  Copyright (c) 2016 OremTech. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView
+ (void)showAlertWithMessage:(NSString *)message view:(id)view
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [view presentViewController:alertController animated:YES completion:nil];
    
    [self performSelector:@selector(dismiss:) withObject:alertController afterDelay:2.0];
}
+(void)dismiss:(UIAlertController *)alert
{
    [alert dismissViewControllerAnimated:YES completion:nil];
}
@end

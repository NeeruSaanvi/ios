//
//  AlertView.h
//  MyVideoTech
//
//  Created by OSX on 14/01/16.
//  Copyright (c) 2016 OremTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface AlertView : NSObject
+(void)showAlertWithMessage:(NSString *)message view:(id)view;
+(void)dismiss:(UIAlertController *)alert;
@end

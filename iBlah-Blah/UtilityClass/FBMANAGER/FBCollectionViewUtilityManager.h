//
//  FBCollectionViewUtilityManager.h
//  FBCollectionViewExample
//
//  Created by Ruthwick S Rai on 13/10/16.
//  Copyright © 2016 Ruthwick S Rai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBCollectionViewUtilityManager : UIViewController
+(UIColor*)colorWithHexString:(NSString*)hex;
+(NSString *)neutraliseString:(NSString *)string;
+(BOOL)stringIsNull:(NSString *)stringCheck;
+(NSString*)getPostDurationWithDateFormate:(double)longDate;
+(NSString*)getPostDurationWhenPostedWithLongDate:(double)longDate;
+(BOOL) validateUrl:(NSString *)candidate;
@end

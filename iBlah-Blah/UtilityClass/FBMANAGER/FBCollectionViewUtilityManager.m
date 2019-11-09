//
//  FBCollectionViewUtilityManager.m
//  FBCollectionViewExample
//
//  Created by Ruthwick S Rai on 13/10/16.
//  Copyright © 2016 Ruthwick S Rai. All rights reserved.
//

#import "FBCollectionViewUtilityManager.h"
#define SCREEN_WIDTH       [UIScreen mainScreen].bounds.size.width
#define DATE_FORMAT_COMMENT         @"MMM dd, hh:mm a"
#define USERDESCRIPTION_FONT_NAME        @"Helvetica Neue"
#define USERDESCRIPTION_FONT_SIZE        15.0f

@interface FBCollectionViewUtilityManager ()

@end

@implementation FBCollectionViewUtilityManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
+(NSString*)getPostDurationWithDateFormate:(double)longDate {
    NSString *durationOfPost = @"";
    
    double unixTimeStamp = longDate/1000;
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:_interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *strDaySuffix = @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger dayOfMonth = [calendar component:NSCalendarUnitDay fromDate:postDate];
    switch (dayOfMonth) {
        case 1:
        case 21:
        case 31: strDaySuffix =  @"st";
            break;
        case 2:
        case 22: strDaySuffix = @"nd";
            break;
        case 3:
        case 23: strDaySuffix = @"rd";
            break;
        default: strDaySuffix = @"th";
            break;
    }
    [formatter setDateFormat:[NSString stringWithFormat:@"LLL d, HH:mm"]];
    durationOfPost = [formatter stringFromDate:postDate];
    NSArray *arrTemp = [durationOfPost componentsSeparatedByString:@","];
    durationOfPost = [NSString stringWithFormat:@"%@%@,%@",[arrTemp objectAtIndex:0],strDaySuffix,[arrTemp objectAtIndex:1]];
    return durationOfPost;
}
+(NSString*)getPostDurationWhenPostedWithLongDate:(double)longDate {
    NSString *durationOfPost = @"";
    NSDate  *currentDate = [NSDate date];
    //convert into seconds
    double unixTimeStamp = longDate/1000;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:_interval];
    postDate = [formatter dateFromString:[formatter stringFromDate:postDate]];
    
    NSDate *todayDate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
    if([postDate isEqualToDate:todayDate]){
        double unixTimeStamp = longDate/1000;
        NSTimeInterval _interval=unixTimeStamp;
        NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:_interval];
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond
                                                            fromDate:postDate
                                                              toDate:currentDate
                                                             options:0];
        //Identify timing of post
        NSInteger hours = [components hour];
        NSInteger days = [components day];
        NSInteger minutes = [components minute];
        NSInteger seconds = [components second];
        NSLog(@"seconds  %lu and minute  %lu",(long)seconds,(long)minutes);
        if(hours >= 1) {
            if(hours == 1)
                durationOfPost = @"1 hour ago";
            else
                durationOfPost = [NSString stringWithFormat:@"%ld hours ago",(long)hours];
            return durationOfPost;
        }
        else if (hours == 0) {
            
            if(minutes >= 1)
                durationOfPost = [NSString stringWithFormat:@"%ld minutes ago",(long)minutes];
            else if (seconds <= 30)
                durationOfPost = @"few seconds ago";
            else if (seconds < 60 && seconds > 30)
                durationOfPost = [NSString stringWithFormat:@"%ld seconds ago",(long)seconds];
            else  durationOfPost = @"1 minute ago";
            return durationOfPost;
        }
        else if(days >= 1)
        {
            if(days == 1)
                durationOfPost = @"1d";
            else {
                if(days > 8 && days < 30) {
                    days = days/8;
                    if(days > 1)
                        durationOfPost = [NSString stringWithFormat:@"%ld weeks ago",(long)days];
                    else
                        durationOfPost = [NSString stringWithFormat:@"1 week ago"];
                }
                else if (days > 30) {
                    days = days/30;
                    if(days > 1)
                        durationOfPost = [NSString stringWithFormat:@"%ld months ago",(long)days];
                    else
                        durationOfPost = [NSString stringWithFormat:@"1 month ago"];
                }
            }
            return durationOfPost;
        }
    }else{
        [formatter setDateFormat:@"LLL d"];
        durationOfPost = [formatter stringFromDate:postDate];
        return durationOfPost;
    }
    
    return durationOfPost;
    
}
-(NSString*)dateFromStringWithDate:(double)timestamp {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:DATE_FORMAT_COMMENT];
    NSDate *postDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *dateStr = [df stringFromDate:postDate];
    return dateStr;
}
+(BOOL)stringIsNull:(NSString *)stringCheck{
    BOOL check;
    if (stringCheck == (id)[NSNull null] || stringCheck == nil|| [self neutraliseString:stringCheck].length == 0 ) check = YES;
    else
        check = NO;
    return check;
}

+(NSString *)neutraliseString:(NSString *)string{
    string = [NSString stringWithFormat:@"%@",string];
    if([string isEqualToString:@"(null)"]||[string isEqualToString:@"<null>"]){
        string = @"";
    }
    return string;
}

+(BOOL) validateUrl:(NSString *)candidate {
    candidate = [self neutraliseString:candidate];
    
    NSString *regex = @"(?i)(http|https)(:\\/\\/)([^ .]+)(\\.)([^ \n]+)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:candidate];
}


@end

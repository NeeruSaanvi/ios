//
//  NSDate+Utils.m
//  NearPromo
//
//  Created by Piyush Agarwal on 8/3/17.
//  Copyright © 2017 Piyush Agarwal. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

-(NSDate *) toLocalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate *) toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}
@end

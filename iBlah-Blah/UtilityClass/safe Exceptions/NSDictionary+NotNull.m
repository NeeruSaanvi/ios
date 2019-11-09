//
//  NSDictionary+NotNull.m
//  FeetApart
//
//  Created by Punith B M on 22/08/16.
//  Copyright © 2016 Feetapart Wellness Pvt Ltd.,. All rights reserved.
//

#import "NSDictionary+NotNull.h"

@implementation NSDictionary(NotNull)
- (id)objectOrNilForKey:(id)aKey
{
    id object = [self objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

@end

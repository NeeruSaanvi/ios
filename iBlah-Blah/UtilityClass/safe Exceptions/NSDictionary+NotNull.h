//
//  NSDictionary+NotNull.h
//  FeetApart
//
//  Created by Punith B M on 22/08/16.
//  Copyright © 2016 Feetapart Wellness Pvt Ltd.,. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NotNull)
- (id)objectOrNilForKey:(id)aKey;
@end

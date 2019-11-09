//
//  CountryListDataSource.h
//  KittyBee
//
//  Created by Arun on 28/09/17.
//  Copyright © 2017 KittyBee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCountryName        @"name"
#define kCountryCallingCode @"dial_code"
#define kCountryCode        @"code"

@interface CountryListDataSource : NSObject

- (NSArray *)countries;
@end

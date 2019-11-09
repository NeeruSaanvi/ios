//
//  OCTBaseCollectionViewLayout_v2.h
//  OCTCustomCollectionViewLayout
//
//  Created by dmitry.brovkin on 4/3/17.
//  Copyright © 2017 dmitry.brovkin. All rights reserved.
//

#import "OCTBaseCollectionViewLayout.h"

@interface OCTGalleryLayout_v2 : OCTBaseCollectionViewLayout

@property (retain, nonatomic) NSArray *imgArray;
@property ( nonatomic) NSInteger kNumberOfSideItems;
@property ( nonatomic) float height;
@end

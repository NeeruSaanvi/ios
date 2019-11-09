//
//  OCTBaseCollectionViewLayout_v2.m
//  OCTCustomCollectionViewLayout
//
//  Created by dmitry.brovkin on 4/3/17.
//  Copyright © 2017 dmitry.brovkin. All rights reserved.
//

#import "OCTGalleryLayout_v2.h"

CGFloat kSideItemWidthCoef = 0.33;
CGFloat kSideItemHeightAspect = 0.33;
//static const NSInteger kNumberOfSideItems = 3;

@implementation OCTGalleryLayout_v2
{
    CGSize _mainItemSize;
    CGSize _sideItemSize;
    NSArray<NSNumber *> *_columnsXoffset;
}

#pragma mark Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
//        self.totalColumns = 2;
    }
    
    return self;
}

-(instancetype)init
{
    self = [super init];
//    self = [super initWithCoder:aDecoder];

    if (self) {
//        self.totalColumns = 2;
    }

    return self;
}

#pragma mark Override Abstract methods

- (NSInteger)columnIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger totalItemsInRow = self.kNumberOfSideItems + 1;
    NSInteger columnIndex = indexPath.item % totalItemsInRow;
    NSInteger columnIndexLimit = self.totalColumns - 1;
    
    return columnIndex > columnIndexLimit  ? columnIndexLimit : columnIndex;
}

- (CGRect)calculateItemFrameAtIndexPath:(NSIndexPath *)indexPath columnIndex:(NSInteger)columnIndex columnYoffset:(CGFloat)columnYoffset {
    CGSize size = columnIndex == 0 ? _mainItemSize : _sideItemSize;
    return CGRectMake(_columnsXoffset[columnIndex].floatValue, columnYoffset, size.width, size.height);
}

- (void)calculateItemsSize {
    CGFloat contentWidthWithoutIndents = self.collectionView.bounds.size.width - self.contentInsets.left - self.contentInsets.right;
    CGFloat resolvedContentWidth = contentWidthWithoutIndents - self.interItemsSpacing;

    // We need to calculate side item size first, in order to calculate main item height


    if(self.imgArray.count == 2)
    {
        kSideItemWidthCoef = .5;
        kSideItemHeightAspect = 1;
//        sideItemWidth = resolvedContentWidth/2;
//        sideItemHeight = resolvedContentWidth;
    }
    else if(self.imgArray.count == 3)
    {
        kSideItemWidthCoef = .5;
        kSideItemHeightAspect = .5;
//        sideItemWidth = resolvedContentWidth * .40;
//        sideItemHeight = resolvedContentWidth/2;
    }else
    {
        kSideItemWidthCoef = .33;
        kSideItemHeightAspect = .33;
    }



    CGFloat sideItemWidth = resolvedContentWidth * kSideItemWidthCoef;
    CGFloat sideItemHeight = self.height * kSideItemHeightAspect ;


    if(self.totalColumns == 1)
    {
        sideItemWidth = 0;
    }

    _sideItemSize = CGSizeMake(sideItemWidth, sideItemHeight);

    // Now we can calculate main item height
    CGFloat mainItemWidth = resolvedContentWidth - sideItemWidth;

    CGFloat mainItemHeight = self.height;

    if(self.imgArray.count > 4)
    {
        mainItemHeight = mainItemHeight/2 - 4;
    }

    _mainItemSize = CGSizeMake(mainItemWidth, mainItemHeight);
    
    // Calculating offsets by X for each column
    _columnsXoffset = @[@(0), @(_mainItemSize.width + self.interItemsSpacing)];
}

- (NSString *)description {
    return @"Layout v2";
}

@end

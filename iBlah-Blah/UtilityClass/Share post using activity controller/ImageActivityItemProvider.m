//
//  ImageActivityItemProvider.m
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 24/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "ImageActivityItemProvider.h"

@interface ImageActivityItemProvider ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger shouldShowIndex;

@end

@implementation ImageActivityItemProvider

- (instancetype)initWithImage:(UIImage*)image index:(NSInteger)index shouldShowIndex:(NSInteger)shouldShowIndex
{
    // make sure the placeholder is nil instead of the image
    self = [super initWithPlaceholderItem:nil];
    if (self)
    {
        self.image = image;
        self.index = index;
        self.shouldShowIndex = shouldShowIndex;
    }
    return self;
}

- (id)item
{
    if (
        [self.activityType isEqualToString:UIActivityTypeMail] ||
        self.index == self.shouldShowIndex
        )
    {
        return self.image;
    }
    return self.placeholderItem;
}
@end

//
//  ImageActivityItemProvider.h
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 24/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageActivityItemProvider : UIActivityItemProvider
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, readonly) NSInteger index;
@property (nonatomic, readonly) NSInteger shouldShowIndex;

- (instancetype)initWithImage:(UIImage*)image index:(NSInteger)index shouldShowIndex:(NSInteger)shouldShowIndex;

@end

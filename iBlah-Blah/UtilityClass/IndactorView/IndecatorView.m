//
//  IndecatorView.m
//  you-teach
//
//  Created by AthenaSoft on 28/09/15.
//  Copyright (c) 2015 AthenaSoft. All rights reserved.
//

#import "IndecatorView.h"
#import "DGActivityIndicatorView.h"

@implementation IndecatorView{
}

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    
        UIVisualEffectView *visualEffectView;
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.alpha=0.4;
        visualEffectView.frame = self.bounds;
        [self addSubview:visualEffectView];
        
        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)0 tintColor:[UIColor colorWithRed:31/255.0 green:152/225.0 blue:207/255.0 alpha:1.0]];//31,152,207
        CGFloat width = self.bounds.size.width / 6.0f;
        CGFloat height = self.bounds.size.height / 6.0f;
        
        activityIndicatorView.frame = CGRectMake(SCREEN_SIZE.width/2-width/2, SCREEN_SIZE.height/2-height/2, width, height);
        [self addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
    }
    return self;
}

-(void)willRemoveSubview:(UIView *)subview{
    
}



@end

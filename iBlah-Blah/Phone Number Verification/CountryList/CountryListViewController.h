//
//  CountryListViewController.h
//  KittyBee
//
//  Created by Arun on 28/09/17.
//  Copyright © 2017 KittyBee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryListViewDelegate <NSObject>
- (void)didSelectCountry:(NSDictionary *)country;
@end

@interface CountryListViewController : UIViewController

@property (nonatomic, assign) id<CountryListViewDelegate>delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil delegate:(id)delegate;
@end

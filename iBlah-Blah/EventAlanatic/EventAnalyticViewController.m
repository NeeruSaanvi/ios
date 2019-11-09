//
//  EventAnalyticViewController.m
//  iBlah-Blah
//
//  Created by webHex on 28/06/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "EventAnalyticViewController.h"
#import "UIColor+HexColor.h"
#import "VBPieChart.h"


@interface EventAnalyticViewController ()
@property (nonatomic, retain) VBPieChart *chart;

@property (nonatomic, retain) NSArray *chartValues;

@property (nonatomic) double progress;
@end

@implementation EventAnalyticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setNeedsLayout];
    [self chartInit];
    self.title=@"Analytic Report";
    // Do any additional setup after loading the view from its nib.
    [_chart setChartValues:_chartValues animation:YES];
//    [_chart setHoleRadiusPrecent:0.5];
//    [_chart setChartValues:_chartValues animation:YES options:VBPieChartAnimationFanAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) chartInit {
    _progress = 0;
    
    if (!_chart) {
        _chart = [[VBPieChart alloc] init];
        [self.view addSubview:_chart];
    }
    [_chart setFrame:CGRectMake((SCREEN_SIZE.width/2)-150, 50, 300, 300)];
    
        [_chart.layer setShadowOffset:CGSizeMake(2, 2)];
       [_chart.layer setShadowRadius:3];
        [_chart.layer setShadowColor:[UIColor blackColor].CGColor];
        [_chart.layer setShadowOpacity:0.7];
    _chart.startAngle = M_PI+M_PI_2;
    
    [_chart setHoleRadiusPrecent:0.5];
    
       [_chart setLabelsPosition:VBLabelsPositionOnChart];
    
        [_chart setChartValues:@[
                             @{@"name":@"MayBe", @"value":@50, @"color":[UIColor redColor]},
                             @{@"name":@"Not Attending", @"value":@20, @"color":[UIColor blueColor]},
                             @{@"name":@"Attending", @"value":@40, @"color":[UIColor purpleColor]},
                             ]
                     animation:YES
                      duration:0.5
                       options:VBPieChartAnimationDefault];
    
    
    
 //   UIColor *colorWithImagePattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern.jpg"]];
 //   UIColor *colorWithImagePattern2 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern2.png"]];
    
    self.chartValues = @[
                         @{@"name":@"MayBe", @"value":@50, @"color":[UIColor yellowColor]},
                         @{@"name":@"Not Attending", @"value":@40, @"color":[UIColor redColor]},
                         @{@"name":@"Attending", @"value":@20, @"color":[UIColor greenColor]},

                         ];
    
}

@end

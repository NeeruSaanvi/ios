//
//  WebViewViewController.m
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 03/12/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "WebViewViewController.h"
#import <WebKit/WebKit.h>
@interface WebViewViewController ()<WKUIDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webview;
@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];

}

-(IBAction)btnCrossClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

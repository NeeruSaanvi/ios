//
//  UIActivityViewControllerWithoutWhatsApp.m
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 26/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "UIActivityViewControllerWithoutWhatsApp.h"

@interface UIActivityViewControllerWithoutWhatsApp ()
- (BOOL)_shouldExcludeActivityType:(UIActivity*)activity;
@end

@implementation UIActivityViewControllerWithoutWhatsApp
- (BOOL)_shouldExcludeActivityType:(UIActivity *)activity
{
    if ([[activity activityType] isEqualToString:@"net.whatsapp.WhatsApp.ShareExtension"]) {
        return YES;
    }

    return YES;
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

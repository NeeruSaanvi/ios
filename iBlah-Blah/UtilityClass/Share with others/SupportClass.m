//
//  SupportClass.m
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 26/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "SupportClass.h"
#import "ImageActivityItemProvider.h"
#import "SVProgressHUD.h"

@implementation SupportClass

+(void)shareWithOtherAppRefrenceClass:(id)refrence withImagesArray:(NSArray *)arraImages withTitle:(NSString *)strTitle withLat:(NSString *)lat withLong:(NSString *)lng
{

    [SVProgressHUD showWithStatus:@"Please wait"];
    dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);

    // send initialization of UIActivityViewController in background
    dispatch_async(queue, ^{
        //UIActivityItemProvider *message = [[UIActivityItemProvider alloc] initWithPlaceholderItem:strTitle];

        NSMutableArray *Items = [[NSMutableArray alloc]init];


        //    int index = 0;
        for(NSString *strTemp in arraImages)
        {
            if(![strTemp isEqualToString:@""])
            {
                NSString *strImageUrl = [NSString stringWithFormat:@"%simages/%@",BASEURl,strTemp ];
                NSData *imgShare = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImageUrl]];

                UIImage *img = [UIImage imageWithData:imgShare];

                //        ImageActivityItemProvider *itemProvider = [[ImageActivityItemProvider alloc] initWithImage:img index:index shouldShowIndex:index];

                [Items addObject:img];
            }

            //        index ++;
        }


        //    if(arraImages.count > 0){


        //        [Items addObject:@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8"];
        //        [Items addObject:@"Via iBlah-Blah"];

        //        Items  = [NSArray arrayWithObjects:
        //                  strTitle,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
        //                  @"Via iBlah-Blah", nil];


        //    }else
        if(arraImages.count <= 0 && ![lat isEqualToString:@""] && ![lng isEqualToString:@""]){

            NSString *strUrl=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@,%@&zoom=12&size=600x300&maptype=normal&markers=%@,%@",lat,lng,lat,lat];
            Items  = [NSMutableArray arrayWithObjects:
                      strTitle,strUrl,@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8",
                      @"Via iBlah-Blah", nil];
        }
        else
        {
            [Items addObject:strTitle];
            [Items addObject:@"Download to see more. https://itunes.apple.com/in/app/iblah-blah-for-ipad/id1192641817?mt=8"];
            [Items addObject:@"Via iBlah-Blah"];

        }




        UIActivityViewController *activityView =
        [[UIActivityViewController alloc]
         initWithActivityItems:Items applicationActivities:nil];

        activityView.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop];

        if (IDIOM == IPAD)
        {
            NSLog(@"iPad");
            activityView.popoverPresentationController.sourceView = refrence;
            //        activityViewController.popoverPresentationController.sourceRect = self.frame;
            [refrence presentViewController:activityView
                                   animated:YES
                                 completion:nil];
        }
        else
        {
            NSLog(@"iPhone");
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [refrence presentViewController:activityView
                                       animated:YES
                                     completion:nil];
            });
        }
    });
}


+(UIStoryboard *)getStoryBorad{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

+(UINavigationController *)getNavigationController{
    return [[SupportClass getStoryBorad] instantiateViewControllerWithIdentifier:@"navigation"];
}

@end

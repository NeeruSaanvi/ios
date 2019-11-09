//
//  SupportClass.h
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 26/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportClass : NSObject
+(void)shareWithOtherAppRefrenceClass:(id)refrence withImagesArray:(NSArray *)arraImages withTitle:(NSString *)strTitle withLat:(NSString *)lat withLong:(NSString *)lng;
+(UIStoryboard *)getStoryBorad;
+(UINavigationController *)getNavigationController;
@end

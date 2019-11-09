//
//  ShowLocationViewController.h
//  iBlah-Blah
//
//  Created by webHex on 17/06/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
@interface ShowLocationViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property(strong,nonatomic) NSDictionary *dict;
@end

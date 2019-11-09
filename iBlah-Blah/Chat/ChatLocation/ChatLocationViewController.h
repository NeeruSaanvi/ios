//
//  ChatLocationViewController.h
//  iBlah-Blah
//
//  Created by webHex on 15/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ChatLocationViewController :BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
    CLLocationCoordinate2D coordinates;
    MKMapView *mapView;
}

@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
-(IBAction)SetMap:(id)sender;

- (IBAction)send:(id)sender;
@end

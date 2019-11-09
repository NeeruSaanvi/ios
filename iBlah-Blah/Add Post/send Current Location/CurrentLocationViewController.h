//
//  CurrentLocationViewController.h
//  iBlah-Blah
//
//  Created by Arun on 28/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface CurrentLocationViewController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
    CLLocationCoordinate2D coordinates;
    MKMapView *mapView;
}
@property (weak, nonatomic) IBOutlet UIView *viewMap;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
-(IBAction)SetMap:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgview;
- (IBAction)send:(id)sender;
@property (strong, nonatomic) NSString *strFromHome;
@property (strong, nonatomic)NSDictionary *dictFromPage;
@end

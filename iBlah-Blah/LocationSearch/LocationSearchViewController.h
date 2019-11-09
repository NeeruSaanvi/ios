//
//  LocationSearchViewController.h
//  iBlah-Blah
//
//  Created by webHex on 04/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface LocationSearchViewController : BaseViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *searchText;
- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAddLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

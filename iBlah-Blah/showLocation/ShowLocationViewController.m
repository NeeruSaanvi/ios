//
//  ShowLocationViewController.m
//  iBlah-Blah
//
//  Created by webHex on 17/06/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "ShowLocationViewController.h"

@interface ShowLocationViewController (){
    CLGeocoder *geoCoder;
    CLPlacemark *placeMark;
    CLLocationCoordinate2D coordinates;
    NSString *lat;
    NSString *lng;
    NSString *address;
}
@property (strong, nonatomic) NSMutableArray *matchingItems;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ShowLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *strLon=[NSString stringWithFormat:@"%@",[_dict objectForKey:@"lon"]];
    NSString *strLot=[NSString stringWithFormat:@"%@",[_dict objectForKey:@"lat"]];
    CLLocationCoordinate2D center;
    center.latitude = [strLot doubleValue];
    center.longitude = [strLon doubleValue];
    
    //set up zoom level
    MKCoordinateSpan zoom;
    zoom.latitudeDelta = .1f; //the zoom level in degrees
    zoom.longitudeDelta = .1f;//the zoom level in degrees
    
    //the region the map will be showing
    MKCoordinateRegion myRegion;
    myRegion.center = center;
    myRegion.span = zoom;
    
    //programmatically create a map that fits the screen
    CGRect screen = [[UIScreen mainScreen] bounds];
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:screen ];
    
    //set the map location/region
    [mapView setRegion:myRegion animated:YES];
    
    mapView.mapType = MKMapTypeStandard;//standard map(not satellite)
    
    MapPin *pin = [[MapPin alloc] init];
    pin.title = [_dict objectForKey:@"title"];
    pin.subtitle = [_dict objectForKey:@"discription"];
    [mapView addAnnotation:pin];
    pin.coordinate = center;
    
    [self.view addSubview:mapView];//add map to the view
  //  self.title=@"Add City";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  LocationSearchViewController.m
//  iBlah-Blah
//
//  Created by webHex on 04/05/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "LocationSearchViewController.h"

@interface LocationSearchViewController (){
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

@implementation LocationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _btnAddLocation.layer.cornerRadius=4;
    _btnAddLocation.layer.borderWidth=1;
    _btnAddLocation.layer.borderColor=[UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0].CGColor;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    
    _locationManager.delegate = self;
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_locationManager startUpdatingLocation];
    
    CLLocation *location1 = [_locationManager location];
    coordinates = [location1 coordinate];
    geoCoder = [[CLGeocoder alloc]init];
    [self getLocation];
    self.title=@"Add City";
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)textFieldReturn:(id)sender {
    [sender resignFirstResponder];
    [_mapView removeAnnotations:[_mapView annotations]];
    [self performSearch];
}
- (void) performSearch {
    MKLocalSearchRequest *request =
    [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = _searchText.text;
    request.region = _mapView.region;
    
    _matchingItems = [[NSMutableArray alloc] init];
    
    MKLocalSearch *search =
    [[MKLocalSearch alloc]initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse
                                         *response, NSError *error) {
        if (response.mapItems.count == 0)
        [AlertView showAlertWithMessage:@"No Matches" view:self];
        else
            for (MKMapItem *item in response.mapItems)
            {
                [_matchingItems addObject:item];
                MKPointAnnotation *annotation =
                [[MKPointAnnotation alloc]init];
                annotation.coordinate = item.placemark.coordinate;
                annotation.title = item.name;
                
                [_mapView addAnnotation:annotation];
                
                if ([item.placemark.subThoroughfare length] != 0)
                    address = item.placemark.subThoroughfare;
                
                if ([item.placemark.thoroughfare length] != 0)
                {
                    // strAdd -> store value of current location
                    if ([address length] != 0)
                        address = [NSString stringWithFormat:@"%@, %@",address,[item.placemark thoroughfare]];
                    else
                    {
                        // strAdd -> store only this value,which is not null
                        address = item.placemark.thoroughfare;
                    }
                }
                if ([item.placemark.postalCode length] != 0)
                {
                    if ([address length] != 0)
                        address = [NSString stringWithFormat:@"%@, %@",address,[item.placemark postalCode]];
                    else
                        address = item.placemark.postalCode;
                }
                
                if ([item.placemark.locality length] != 0)
                {
                    if ([address length] != 0)
                        address = [NSString stringWithFormat:@"%@, %@",address,[item.placemark locality]];
                    else
                        address = item.placemark.locality;
                }
                
                if ([item.placemark.administrativeArea length] != 0)
                {
                    if ([address length] != 0)
                        address = [NSString stringWithFormat:@"%@, %@",address,[item.placemark administrativeArea]];
                    else
                        address = item.placemark.administrativeArea;
                }
                
                if ([item.placemark.country length] != 0)
                {
                    if ([address length] != 0)
                        address = [NSString stringWithFormat:@"%@, %@",address,[item.placemark country]];
                    else
                        address = item.placemark.country;
                }
                CLLocation *location = item.placemark.location;
                CLLocationCoordinate2D coordinate = location.coordinate;
                lat=[NSString stringWithFormat:@"%f", coordinate.latitude];
                lng= [NSString stringWithFormat:@"%f", coordinate.longitude];
                
                MKMapRect zoomRect = MKMapRectNull;
                for (id <MKAnnotation> annotation in _mapView.annotations) {
                 //   NSLog(@"%@",annotation);
                    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                    if (MKMapRectIsNull(zoomRect)) {
                        zoomRect = pointRect;
                    } else {
                        zoomRect = MKMapRectUnion(zoomRect, pointRect);
                    }
                }
                [_mapView setVisibleMapRect:zoomRect animated:YES];
            }
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:lat forKey:@"lat"];
        [dict setValue:lng forKey:@"lng"];
        [dict setValue:address forKey:@"address"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"AddLocationEvent"
         object:self userInfo:dict];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}
- (IBAction)search:(id)sender {
    [self.view endEditing:YES];
    [_mapView removeAnnotations:[_mapView annotations]];
    [self performSearch];
}
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.1;
    mapRegion.span.longitudeDelta = 0.1;
    
    [mapView setRegion:mapRegion animated: YES];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //  NSLog(@"didFailWithError: %@", error);
    [AlertView showAlertWithMessage:@"Please enable location services for phone setting." view:self];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Location: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
   // lon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
  //  lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            
            placeMark = [placemarks lastObject];
            
           // addrss = [NSString stringWithFormat:@"At %@,%@,%@",placeMark.subLocality,placeMark.locality,placeMark.country];
            
        } else {
            [AlertView showAlertWithMessage:error.description view:self];
            NSLog(@"%@", error.debugDescription);
            
        }
        
    } ];
    // Stop Location Manager
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingLocation];
    _locationManager=nil;
    
    
}

- (void)getLocation {
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeStandard;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [_locationManager startUpdatingLocation];
    
    CLLocation *location = [_locationManager location];
    coordinates = [location coordinate];
}
@end

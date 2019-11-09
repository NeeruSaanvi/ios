//
//  CurrentLocationViewController.m
//  iBlah-Blah
//
//  Created by Arun on 28/03/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "AddPostViewController.h"
@interface CurrentLocationViewController (){
    CLGeocoder *geoCoder;
    CLPlacemark *placeMark;
    NSString *lon;
    NSString *lat;
    NSString *addrss;
    BOOL shareLoctionButtonClick;
}

@end

@implementation CurrentLocationViewController
@synthesize mapView;
@synthesize locationManager;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    lon=@"";
    lat=@"";
    addrss=@"";
    shareLoctionButtonClick=NO;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
      mapView.mapType = MKMapTypeStandard;
    mapView.showsUserLocation = YES;
    
    locationManager.delegate = self;
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];

    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [locationManager startUpdatingLocation];
    
    CLLocation *location1 = [locationManager location];
    coordinates = [location1 coordinate];
    geoCoder = [[CLGeocoder alloc]init];
    
    self.title=@"Share Location";
    
    [self getLocation];
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
    [AlertView showAlertWithMessage:error.description view:self];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Location: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
   lon = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
   lat = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            
            placeMark = [placemarks lastObject];
            
           addrss = [NSString stringWithFormat:@"At %@,%@,%@",placeMark.subLocality,placeMark.locality,placeMark.country];
            
        } else {
             [AlertView showAlertWithMessage:error.description view:self];
            NSLog(@"%@", error.debugDescription);
            
        }
        
    } ];
        // Stop Location Manager
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    locationManager=nil;
    if(shareLoctionButtonClick){
        if(lat.length>0 && lon.length>0 && addrss.length>0){
            NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
            [dict setValue:lat forKey:@"lat"];
            [dict setValue:lon forKey:@"lon"];
            [dict setValue:addrss forKey:@"address"];
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SendLocation"
             object:self userInfo:dict];
            
            if([_strFromHome isEqualToString:@"1"]){
                AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
                R2VC.dictLocation=dict;
                [self.navigationController pushViewController:R2VC animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
       
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}
-(IBAction)SetMap:(id)sender{
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

- (void)getLocation {
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeStandard;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    coordinates = [location coordinate];
}

- (IBAction)send:(id)sender {
    if(lat.length>0 && lon.length>0 && addrss.length>0){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setValue:lat forKey:@"lat"];
         [dict setValue:lon forKey:@"lon"];
        [dict setValue:addrss forKey:@"address"];
        
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SendLocation"
         object:self userInfo:dict];
        if([_strFromHome isEqualToString:@"1"]){
            AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
            R2VC.dictLocation=dict;
            [self.navigationController pushViewController:R2VC animated:YES];
        }else if ([_strFromHome isEqualToString:@"2"]){
            AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
            R2VC.dictLocation=dict;
            R2VC.fromPage=@"EVENT";
            R2VC.dictFromPage=_dictFromPage;
            [self.navigationController pushViewController:R2VC animated:YES];
        }else if ([_strFromHome isEqualToString:@"3"]){
            AddPostViewController *R2VC = [[AddPostViewController alloc]initWithNibName:@"AddPostViewController" bundle:nil];
            R2VC.dictLocation=dict;
            R2VC.fromPage=@"GROUP";
            R2VC.dictFromPage=_dictFromPage;
            [self.navigationController pushViewController:R2VC animated:YES];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
    }else{
      [locationManager startUpdatingLocation];
      [locationManager startUpdatingLocation];
    shareLoctionButtonClick=YES;
    }
}

@end

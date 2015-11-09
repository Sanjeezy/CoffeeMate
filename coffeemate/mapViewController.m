//
//  mapViewController.m
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 11/2/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//

#import "mapViewController.h"
#import "cafe.h"
#import "Location.h"
#import <RestKit/RestKit.h> 
#import "MasterViewController.h"


@interface mapViewController () <CLLocationManagerDelegate>

@property (nonatomic,strong)NSArray *cafes;

@property (nonatomic,strong)NSString *userLatitude;

@property (nonatomic,strong)NSString *userLongitude;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)resfreshMap:(id)sender;
- (IBAction)addAnnotations:(id)sender;

//-(void)addAnnotations;


@end

@implementation mapViewController
@synthesize mapView;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
     self.mapView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //[self.locationManager startUpdatingLocation];
    
    [self.locationManager startUpdatingLocation];
    
    [self configureRestKit]; //prepares RESTkit objects for use
    
    [self loadShopInfo]; //calls API and receives response
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
    float latitude = loc.coordinate.latitude;
    float longitude = loc.coordinate.longitude;
    NSLog(@"%.8f",latitude);
    NSLog(@"%.8f",longitude);
    
    self.userLatitude = [NSString stringWithFormat:@"%.8f",latitude];
    
    self.userLongitude = [NSString stringWithFormat:@"%.8f",longitude];
    
    NSLog(@"%@",self.userLatitude);
    NSLog(@"%@",self.userLongitude);
    
    //[self configureRestKit];
    
    //[self loadShopInfo];
    
    [self.locationManager stopUpdatingLocation];
    
    //[self loadShopInfo];
    
}




//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    
//    int i;
//    CLLocationCoordinate2D venueCoordinate;
//    
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 3500, 3500);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
//    
//    // Add an annotation
//    for(i=0;i<30;i++){
//        
//        cafe *cafe = _cafes[i];
//        
//        venueCoordinate.latitude = cafe.location.lat.doubleValue;
//        venueCoordinate.longitude = cafe.location.lng.doubleValue;
//    
//    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
//        point.coordinate = venueCoordinate;
//        point.title = [NSString stringWithFormat:@"%@",cafe.name];
//    point.subtitle = [NSString stringWithFormat:@"%@",cafe.location.address];
//    
//    [self.mapView addAnnotation:point];
//    }
//    
//    
//}
//





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated {

}




#pragma mark - Navigation

 //In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    //Get the new view controller using [segue destinationViewController].
//     //Pass the selected object to the new view controller.
//}



-(void)configureRestKit{
    
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];   //this is the base URL for FourSquare's API
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit - used to interact with RESTful services
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    
    
    // setup object mappings - maps a JSON attribute to an attribute in our data model, in this case the name of a shop
    
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[cafe class]];
    
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // define location object mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromArray:@[@"address", @"city", @"country", @"crossStreet", @"postalCode", @"state", @"distance", @"lat", @"lng"]];
    
    // define relationship mapping
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
}

-(void)loadShopInfo{
    
    
    NSString *userLat;
    NSString *userLon;
    
    
    
    userLat = [NSString stringWithFormat:@"%@", self.userLatitude];
    userLon = [NSString stringWithFormat:@"%@", self.userLongitude];
    
    
    NSString  *coordinates = [NSString stringWithFormat:@"%@,%@",userLat,userLon];

    
    //NSString *coordinates = @"37.33,-122.03"; //@coordinates
    NSString *clientID = @"B3SPMMQCLHA3TGKTRYG2GHVPYJNLIMVKWOHIGMNBVTPKBIIW";
    NSString *clientSecret = @"12PH51ZJTDJCV25OBZ4TYDAK2R5M0J1DH2PXL0NYY02OSNUK";
    
    //declaring the parameters that will be sent in the request
    
    NSDictionary *queryParams = @{@"ll" : coordinates,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"categoryId" : @"4bf58dd8d48988d1e0931735",
                                  @"v" : @"20140118"};
    
    
    //restkit method creates a request, sends it, and receives the response from FourSquare
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
     
     //method is fetching objects by  of a HTTP request
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _cafes = mappingResult.array;
                                                  
                                              }
     
     //If failed to retreive objects, will output an error client-side
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error: no coffee shops could be found nearby: %@", error);
                                              }];
    
}

- (IBAction)resfreshMap:(id)sender{
    
    [self configureRestKit];
    
    [self loadShopInfo];
    
    CLLocationCoordinate2D userCoordinate;
  
    userCoordinate.latitude = self.locationManager.location.coordinate.latitude;
    userCoordinate.longitude = self.locationManager.location.coordinate.longitude;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userCoordinate, 3500, 3500);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
        [mapView reloadInputViews];

}

- (IBAction)addAnnotations:(id)sender {
    int i;
    
    CLLocationCoordinate2D venueCoordinate;
    
    for(i=0;i<30;i++){
        
        cafe *cafe = _cafes[i];
        
        venueCoordinate.latitude = cafe.location.lat.doubleValue;
        venueCoordinate.longitude = cafe.location.lng.doubleValue;
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = venueCoordinate;
        point.title = [NSString stringWithFormat:@"%@",cafe.name];
        point.subtitle = [NSString stringWithFormat:@"%@",cafe.location.address];
        
        [self.mapView addAnnotation:point];
        
        [mapView reloadInputViews];
        
        
    }
}


@end

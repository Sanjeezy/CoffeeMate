//
//  MasterViewController.m
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 10/31/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import <RestKit/RestKit.h> //importing RESTKit framework
#import "cafe.h"
#import "Location.h"


//These constants are given through aunthentication from Foursquare's site

#define kclientID @"B3SPMMQCLHA3TGKTRYG2GHVPYJNLIMVKWOHIGMNBVTPKBIIW"
#define kclientSecret @"12PH51ZJTDJCV25OBZ4TYDAK2R5M0J1DH2PXL0NYY02OSNUK"


@interface MasterViewController () <CLLocationManagerDelegate>

//@property (nonatomic,strong)NSArray *cafes;

@property (nonatomic,retain) CLLocationManager *locationManager;


@end

@implementation MasterViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
        [self.locationManager requestAlwaysAuthorization];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    //[self.locationManager startUpdatingLocation];
    
    [self.locationManager startUpdatingLocation];
    
    //[self.locationManager stopUpdatingLocation];
    
    NSLog(@"finished running main");
    
    [self configureRestKit];
    
    //[self loadShopInfo];
    

    
    
    
//  [self configureRestKit]; //prepares RESTkit objects for use
//  
//   [self loadShopInfo]; //calls API and receives response
 
    
    
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



//- (void)getCurrentLocation{
//    NSLog(@"hi sanjayyyyyyy");
//    _locationManager.delegate = self;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    
//    [self.locationManager startUpdatingLocation];
//    
////    NSLog(@"didUpdateToLocation: %@", newLocation);
////    CLLocation *currentLocation = newLocation;
////    
////    if (currentLocation != nil) {
////        self.userLongitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
////        self.userLatitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
////        
////        self.userCoordinates = [NSString stringWithFormat:@"%@,%@",self.userLatitude,self.userLongitude];

        
//        NSLog(@"THESE ARE THE COORDINATES SANJAY:   %@",self.userCoordinates);
//        
//        [self.locationManager stopUpdatingLocation];
//    
//}

//#pragma mark - CLLocationManagerDelegate

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"didFailWithError: %@", error);
////    UIAlertView *errorAlert = [[UIAlertView alloc]
////                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
////    [errorAlert show];
//    
//    NSLog(@"ERROR: COULD NOT GET USER'S LOCATION-------");
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    NSLog(@"didUpdateToLocation: %@", newLocation);
//    CLLocation *currentLocation = newLocation;
//    
//    if (currentLocation != nil) {
//        self.userLongitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
//       self.userLatitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
//        
//        self.userCoordinates = [NSString stringWithFormat:@"%@,%@",self.userLatitude,self.userLongitude];
//        
//        
//        NSLog(@"THESE ARE THE COORDINATES SANJAY:   %@",self.userCoordinates);
//        
//        [self.locationManager stopUpdatingLocation];
//        
//       
//    }
//}





//
///The following 2 methods were based off of the RESTKit tutorial from www.raywenderlich.com
//



/*The purpose of this method is to initialize variables that will be used for object mapping the returned values
from the API call */

-(void)configureRestKit{
    
    // initialize AFNetworking HTTPClient
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    
    [self.locationManager startUpdatingLocation];

    
    
    //this is the base URL for FourSquare's API
  NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];      AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
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
    
    //[self.locationManager startUpdatingLocation];
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    
//    [self.locationManager requestAlwaysAuthorization];
//    
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    
//    
//    [self.locationManager startUpdatingLocation];

    NSString *userLat;
    NSString *userLon;
    
    userLat = [NSString stringWithFormat:@"%@", self.userLatitude];
    userLon = [NSString stringWithFormat:@"%@", self.userLongitude];
    
    
    NSString  *coordinates = [NSString stringWithFormat:@"%@,%@",userLat,userLon];
    
    NSLog(@"COORDINATES PASSED INTO RESTKIT: %@,%@",self.userLatitude,self.userLongitude);
    
 

    
    //NSString *coordinates = @"37.787359,-122.408227"; //@coordinates
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
                                                  [self.tableView reloadData];
                                              }
     
                                            //If failed to retreive objects, will output an error client-side
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"Error: no coffee shops could be found nearby: %@", error);
                                              }];
    }
    
    
    




- (void)viewWillAppear:(BOOL)animated {
   // self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
   
    
    //[self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}









#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = self.objects[indexPath.row];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cafes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    NSMutableArray *arr;
//    
//    int i;
//    
//    for(i=0;i<30;i++){
//        
//        arr[i]=_cafes[i];
//    }
//    
    
    
    cafe *cafe = _cafes[indexPath.row];
    cell.textLabel.text = cafe.name;
    
    double distanceInMeters = cafe.location.distance.floatValue;
    
    double distanceInMiles = distanceInMeters*0.000621371;
    
    if(distanceInMiles < 1){
        
        double distanceInFeet = distanceInMeters*3.28084;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f feet",distanceInFeet];
        
    }
    else{
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f miles ", distanceInMiles];
    
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

- (IBAction)refreshCells:(id)sender {
    
    [self configureRestKit];
    [self loadShopInfo];
    
}
@end

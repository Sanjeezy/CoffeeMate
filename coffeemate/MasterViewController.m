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

@property (nonatomic,retain) CLLocationManager *locationManager;

@property (nonatomic,strong)NSString *userLatitude;

@property (nonatomic,strong)NSString *userLongitude;

@property (nonatomic,strong)NSString *userCoordinates;

//array holds data taken fro API call, is passed to individual cafe objects

@property (nonatomic,strong)NSArray *cafes;


@end

@implementation MasterViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
        [self.locationManager requestAlwaysAuthorization]; //requesting location usage authorization from user
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager startUpdatingLocation]; //began tracking user pos/coordinates
    
    //[self.locationManager stopUpdatingLocation];
    
    NSLog(@"finished running main");

    
    //technically these methods should be in viewdidLoad, but theres an issue where they are running before the user's location has been taken, which affects the API call and returns null data
    
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
    
    //had to convert user coordinates to string format in order to pass into API request
    
    self.userLatitude = [NSString stringWithFormat:@"%.8f",latitude];
    
    self.userLongitude = [NSString stringWithFormat:@"%.8f",longitude];
    
    NSLog(@"%@",self.userLatitude);
    NSLog(@"%@",self.userLongitude);
    
    
    [self.locationManager stopUpdatingLocation];
    
    
   }





//
///The following 2 methods were based off of the RESTKit tutorial from www.raywenderlich.com
//



/*The purpose of this method is to initialize variables that will be used for object mapping the returned values
from the API call */

-(void)configureRestKit{
    
    // initialize AFNetworking HTTPClient

    
    
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

    NSString *userLat;
    NSString *userLon;
    
    userLat = [NSString stringWithFormat:@"%@", self.userLatitude];
    userLon = [NSString stringWithFormat:@"%@", self.userLongitude];
    
    
    NSString  *coordinates = [NSString stringWithFormat:@"%@,%@",userLat,userLon];
    
    //if this logs as null or 0.00000, we know there was an issue getting the user's location coordinates
    NSLog(@"COORDINATES PASSED INTO RESTKIT: %@,%@",self.userLatitude,self.userLongitude);
    
 

     // If shops are not being displayed we can try using hardcoded location values to debug
    //Hardcoded values in order to test the api request NSString *coordinates = @"37.787359,-122.408227";
    
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
                                            //storing return within the _cafes array
     
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
    [super viewWillAppear:animated];
   

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View

//
///
////  I wanted to create a detail view that would occur when a cafe was selected from the tableview, but unfortuantely the foursquare API didn't seem to provide values for the

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //api call generates 30 venues, these are passed into rows for tableview
    return _cafes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //Improvement could be made to app here: I wanted to sort the table view by distance closes to user, but I wasn't sure how to access only the distance property of the _Cafes array and set that as the sorting descriptor
    
//    NSMutableArray *arr;
//    
//    int i;
//    
//    for(i=0;i<30;i++){
//        
//        arr[i]=_cafes[i];
//    }
    
    
    //individual cafe object take properties from each index in _cafes array
    
    cafe *cafe = _cafes[indexPath.row];
    cell.textLabel.text = cafe.name;
    
    double distanceInMeters = cafe.location.distance.floatValue;
    
//venue distances are returned in meters by default, so I converted them to miles, because who uses metric system
    double distanceInMiles = distanceInMeters*0.000621371;
    
    
    //table view would hold distances that were "0 miles" so I converted them to feet
    
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



//Technically these should be called automatically within the main, but I gave the user the option of manually populating the table view, because i was running into an issue where these methods would be called before the location manager had a chance to gather the users location, which would result in no coordinates being passed to the API request and ultimately no data being returned to tableview. I believe this is an issue with the threading of the RESTkit but I wasn't sure how to fix it.

- (IBAction)refreshCells:(id)sender {
    
    [self configureRestKit]; //prepares RESTkit objects for use
    [self loadShopInfo];     //calls API and receives response
    
}
@end

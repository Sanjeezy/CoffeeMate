//
//  MasterViewController.h
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 10/31/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@class DetailViewController;

@interface MasterViewController : UITableViewController //<CLLocationManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic,strong)NSString *userLatitude;

@property (nonatomic,strong)NSString *userLongitude;

@property (nonatomic,strong)NSString *userCoordinates;

@property (nonatomic,strong)NSArray *cafes;




@end


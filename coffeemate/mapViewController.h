//
//  mapViewController.h
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 11/2/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface mapViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong)IBOutlet MKMapView *mapView; //linking mapView to code


@end

//
//  Location.h
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 11/1/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//



//
///
//// The location object is a data model that holds the specific properties of each Cafe's general location
///
//




#import <Foundation/Foundation.h>

@interface Location : NSObject


@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *crossStreet;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lng;

@end

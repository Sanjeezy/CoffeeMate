//
//  cafe.h
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 10/31/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//


//
//// The Cafe object will hold the properties of each shop/restaurant as returned by the API call.
//


#import <Foundation/Foundation.h>

@class Location;

@interface cafe : NSObject

@property (nonatomic,strong) NSString *name;

@property (nonatomic, strong) Location *location;

@end

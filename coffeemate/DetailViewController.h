//
//  DetailViewController.h
//  coffeemate
//
//  Created by Sanjay Tamizharasu on 10/31/15.
//  Copyright © 2015 SanjayTamizharasu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopName;
@property (weak, nonatomic) IBOutlet UILabel *shopAddress;

@end


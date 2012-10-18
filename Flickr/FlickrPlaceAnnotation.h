//
//  FlickrPlaceAnnotation.h
//  Flickr
//
//  Created by Linge Dai on 10/14/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>
+ (FlickrPlaceAnnotation *)annotationForPlace:(Place *)place;

@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *provinceAndCountry;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@end

//
//  FlickrPlaceAnnotation.h
//  Flickr
//
//  Created by Heaven  Chen on 10/14/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface FlickrPlaceAnnotation : NSObject <MKAnnotation>
+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place;

@property (nonatomic, strong) NSDictionary *place;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *provinceAndCountry;

@end

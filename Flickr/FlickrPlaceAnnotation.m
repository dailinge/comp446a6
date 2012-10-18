//
//  FlickrPlaceAnnotation.m
//  Flickr
//
//  Created by Linge Dai on 10/14/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation
@synthesize city = _city;
@synthesize provinceAndCountry = _provinceAndCountry;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

+ (FlickrPlaceAnnotation *)annotationForPlace:(Place *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    
    annotation.city = place.city;
    annotation.provinceAndCountry = place.content;
    annotation.latitude = place.latitude;
    annotation.longitude = place.longitude;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.city;
}

- (NSString *)subtitle
{
    return self.provinceAndCountry;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

@end

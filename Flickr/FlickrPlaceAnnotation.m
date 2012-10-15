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
@synthesize place = _place;
@synthesize city = _city;
@synthesize provinceAndCountry = _provinceAndCountry;

+ (FlickrPlaceAnnotation *)annotationForPlace:(NSDictionary *)place
{
    FlickrPlaceAnnotation *annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    
    annotation.city = [FlickrFetcher namePlace:place];
    annotation.provinceAndCountry = [FlickrFetcher descriptionPlace:place];
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
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end

//
//  FlickrPhotoAnnotation.h
//  Flickr
//
//  Created by Linge Dai on 10/14/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo;
@property (nonatomic, strong) NSDictionary *photo;
@end

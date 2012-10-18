//
//  Place+Flickr.m
//  Flickr
//
//  Created by Heaven  Chen on 10/17/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "Place+Flickr.h"
#import "FlickrFetcher.h"

@implementation Place (Flickr)
+ (Place *)placeWithPlaceInfo:(NSDictionary *)placeInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"place_id = %@", [placeInfo objectForKey:FLICKR_PLACE_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"country" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
    } else if ([matches count] == 0) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.place_id = [placeInfo objectForKey:FLICKR_PLACE_ID];
        place.latitude = [placeInfo objectForKey:FLICKR_LATITUDE];
        place.longitude = [placeInfo objectForKey:FLICKR_LONGITUDE];
        place.content = [FlickrFetcher descriptionPlace:placeInfo];
        place.country = [FlickrFetcher countryNamePlace:placeInfo];
        place.city = [FlickrFetcher namePlace:placeInfo];

    } else {
        place = [matches lastObject];
    }
       
    return place;
}
@end

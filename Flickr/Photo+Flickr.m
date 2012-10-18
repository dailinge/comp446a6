//
//  Photo+Flickr.m
//  Flickr
//
//  Created by Heaven  Chen on 10/17/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)
+ (Photo *)PhotoWithPhotoInfo:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [photoInfo objectForKey:FLICKR_PLACE_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        
    } else if ([matches count] == 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = [photoInfo objectForKey:FLICKR_PHOTO_ID];
        photo.latitude = [photoInfo objectForKey:FLICKR_LATITUDE];
        photo.longitude = [photoInfo objectForKey:FLICKR_LONGITUDE];
        
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}
@end

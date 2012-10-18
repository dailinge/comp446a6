//
//  Place+Flickr.h
//  Flickr
//
//  Created by Heaven  Chen on 10/17/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "Place.h"

@interface Place (Flickr)
+ (Place *)placeWithPlaceInfo:(NSDictionary *)placeInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;

@end

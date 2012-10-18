//
//  Place.h
//  Flickr
//
//  Created by Heaven  Chen on 10/17/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * place_url;
@property (nonatomic, retain) NSString * place_id;
@property (nonatomic, retain) NSString * city;

@end

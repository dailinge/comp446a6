//
//  FlickrModel.m
//  Flickr
//
//  Created by Linge Dai on 10/3/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "FlickrModel.h"
#import "FlickrFetcher.h"

@interface FlickrModel()

@property (nonatomic, strong) NSArray *sectionNames;
@property (nonatomic, strong) NSArray *flickrInfo;

@end
@implementation FlickrModel
@synthesize sectionNames = _sectionNames;
@synthesize flickrInfo = _flickrInfo;


-(void)initFlickrData
{
    //NSLog(@"%@", [FlickrFetcher topPlaces]);
    self.flickrInfo = [FlickrFetcher topPlaces];
    
}

- (id)init
{
    if (self = [super init])
    {
        //fetch the dictionary of the top places information
        //construct a dictionary that maps
        [self initFlickrData];
        
    
    }
    return self;
}


- (NSInteger)numberOfRow {
    return [self.flickrInfo count];
}

- (NSDictionary *)getPlace:(NSInteger)index 
{
    return [self.flickrInfo objectAtIndex:index];
}



@end

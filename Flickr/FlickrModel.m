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
@property (nonatomic, strong) NSDictionary *countryDict;

@end
@implementation FlickrModel
@synthesize sectionNames = _sectionNames;
@synthesize flickrInfo = _flickrInfo;
@synthesize countryDict = _countryDict;


- (void)initFlickrData
{
    //NSLog(@"%@", [FlickrFetcher topPlaces]);
    self.flickrInfo = [FlickrFetcher topPlaces];
    [self initCountryDict];
}

- (void)initCountryDict
{
    NSArray *places = self.flickrInfo;
    NSDictionary *newCountryDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [places count]; i++) {
        NSDictionary *curPlace = [places objectAtIndex:i];
        NSString *curCountryName = [FlickrFetcher countryNamePlace:curPlace];
        
        NSMutableArray *countryCities = [[newCountryDict objectForKey:curCountryName] mutableCopy];
        if (countryCities == nil) {
            countryCities = [[NSMutableArray alloc] init];
        }
        [countryCities insertObject:curPlace atIndex:[countryCities count]];
        [newCountryDict setValue:[countryCities copy] forKey:curCountryName];
    }
    
    self.sectionNames = [newCountryDict allKeys];
    self.sectionNames = [self.sectionNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.countryDict = newCountryDict;
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


- (NSInteger)numberOfRow:(NSInteger)section {
    return [[self.countryDict objectForKey:[self.sectionNames objectAtIndex:section]] count];
}

- (NSInteger)numberOfSection {
    return [self.sectionNames count];
}

- (NSDictionary *)getPlace:(NSInteger)index sectionNumber:(NSInteger)sectionIndex
{
    return [[self.countryDict objectForKey:[self.sectionNames objectAtIndex:sectionIndex]] objectAtIndex:index];
}

- (NSString *)getSectionName:(NSInteger)index 
{
    return [self.sectionNames objectAtIndex:index];
}



@end

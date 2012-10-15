//
//  FlickrModel.h
//  Flickr
//
//  Created by Linge Dai on 10/3/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrModel : NSObject

- (NSInteger)numberOfRow:(NSInteger)section;
- (NSInteger)numberOfSection;
- (NSDictionary *)getPlace:(NSInteger)index sectionNumber:(NSInteger)sectionIndex;
- (NSString *)getSectionName:(NSInteger)index;
- (NSArray *)getPlaces;
- (id)initWithEmptyData;

@end

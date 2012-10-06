//
//  FlickrModel.h
//  Flickr
//
//  Created by Linge Dai on 10/3/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrModel : NSObject

- (NSInteger)numberOfRow;
- (NSDictionary *)getPlace:(NSInteger)index;

@end

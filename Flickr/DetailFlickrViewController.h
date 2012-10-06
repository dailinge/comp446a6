//
//  DetailFlickrViewController.h
//  Flickr
//
//  Created by Linge Dai on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailFlickrViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photoList;

@end

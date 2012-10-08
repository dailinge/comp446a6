//
//  PhotoFlickrViewController.h
//  Flickr
//
//  Created by Linge Dai on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>

#define degreesToRadians(x) (M_PI * x / 180.0)
@interface PhotoFlickrViewController : UIViewController
@property (nonatomic, strong) NSDictionary *photo;
@end

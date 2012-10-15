//
//  DetailFlickrViewController.h
//  Flickr
//
//  Created by Linge Dai on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailFlickrViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photoList;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITableView *tableViewStub;
@property (nonatomic, strong) NSDictionary *annotations;
@property (nonatomic, strong) NSString *viewMode;

@end

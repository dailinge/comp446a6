//
//  FlickrTableViewController.h
//  Flickr
//
//  Created by Linge Dai on 10/2/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreDataTableViewController.h"

@interface FlickrTableViewController : CoreDataTableViewController
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITableView *tableViewStub;
@property (nonatomic, strong) NSDictionary *annotations;
@property (nonatomic, strong) NSString *viewMode;
@property (nonatomic, strong) UIManagedDocument *placeDatabase;
@end

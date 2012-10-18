//
//  FlickrTableViewController.m
//  Flickr
//
//  Created by Linge Dai on 10/2/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "FlickrTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrModel.h"
#import "DetailFlickrViewController.h"
#import "FlickrPlaceAnnotation.h"
#import "Place.h"
#import "Place+Flickr.h"


@interface FlickrTableViewController () <MKMapViewDelegate>

@property (nonatomic, strong) FlickrModel *flickrModel;
@end

@implementation FlickrTableViewController

@synthesize flickrModel = _flickrModel;
@synthesize mapView = _mapView;
@synthesize tableViewStub = _tableViewStub;
@synthesize annotations = _annotations;
@synthesize viewMode = _viewMode;
@synthesize placeDatabase = _placeDatabase;

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"country" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.placeDatabase.managedObjectContext sectionNameKeyPath:@"country" cacheName:nil];
}

- (void)fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr fetch", NULL);
    
    dispatch_async(fetchQ, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        [document.managedObjectContext performBlock:^{
            for (NSDictionary *place in places) {
                // start creating objects in document's context
                
                [Place placeWithPlaceInfo:place inManagedObjectContext:document.managedObjectContext];
            }
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    });
    dispatch_release(fetchQ);
}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.placeDatabase.fileURL path]]) {
        [self.placeDatabase saveToURL:self.placeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            [self fetchFlickrDataIntoDocument:self.placeDatabase];
            
        }];
    } else if (self.placeDatabase.documentState == UIDocumentStateClosed) {
        [self.placeDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            
        }];
    } else if (self.placeDatabase.documentState == UIDocumentStateNormal) {
        [self setupFetchedResultsController];
    }
}

- (void)setPlaceDatabase:(UIManagedDocument *)placeDatabase
{
    if (_placeDatabase != placeDatabase) {
        _placeDatabase = placeDatabase;
        [self useDocument];
    }
}


- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil]]; // TODO i18n
        [segmentedControl setFrame:CGRectMake(32, 4, 256, 40)];
        segmentedControl.selectedSegmentIndex = 0;
        [segmentedControl addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
        [_mapView addSubview:segmentedControl];
    }
    return _mapView;
}

- (NSString *)viewMode
{
    if (!_viewMode) {
        _viewMode = @"List";
    }
    return _viewMode;
}

- (IBAction)toggleView:(UIBarButtonItem *)sender
{
    self.viewMode = sender.title;
    if ([sender.title isEqualToString:@"List"]) {
        self.tableViewStub.hidden = NO;
        self.view = self.tableViewStub;
        sender.title = @"Map";
        self.mapView.hidden = YES;
    } else if ([sender.title isEqualToString:@"Map"]) {
        self.mapView.hidden = NO;
        self.view = self.mapView;
        sender.title = @"List";
        self.tableViewStub.hidden = YES;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([self.viewMode isEqualToString:@"Map"]) {
        self.navigationItem.leftBarButtonItem.title = @"List";
    } else if ([self.viewMode isEqualToString:@"List"]) {
        self.navigationItem.leftBarButtonItem.title = @"Map";
    }
    
    if (!self.tableViewStub && [self.view isKindOfClass:[UITableView class]]) {
		self.tableViewStub = (UITableView *)self.view;
	}
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	
    self.tableViewStub.frame = self.view.bounds;
	[self.view addSubview:self.tableViewStub];
	
	self.mapView.frame = self.view.bounds;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
	[self.view addSubview:self.mapView];
	
	self.mapView.hidden = YES;
    self.mapView.delegate = self;
    self.tableView = self.tableViewStub;

}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Most Viewed";
    
    if (!self.placeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Place Database"];
        self.placeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(180, 180));
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FlickrCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = place.city;
    cell.detailTextLabel.text = place.content;
    FlickrPlaceAnnotation *annotation = [FlickrPlaceAnnotation annotationForPlace:place];
    [self.mapView addAnnotation:annotation];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [self performSegueWithIdentifier:@"PhotoDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PhotoDetail"]) {
        NSDictionary *place;
        if ([sender isKindOfClass:[UITableViewController class]]) {
            NSIndexPath *cellPath = [self.tableViewStub indexPathForSelectedRow];
            place = [self.flickrModel getPlace:cellPath.row sectionNumber:cellPath.section];
        } else if ([sender isKindOfClass:[MKAnnotationView class]]) {
            FlickrPlaceAnnotation *annotation = (FlickrPlaceAnnotation *) ((MKAnnotationView *) sender).annotation;
        }
      
        [segue.destinationViewController setPlace:place];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"FlickrTVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"FlickrTVC"];
        aView.canShowCallout = YES;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    aView.annotation = annotation;
    return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"PhotoDetail" sender:view];
}

- (IBAction)changeMapType:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            self.mapView.mapType = MKMapTypeStandard;
            break;
    }
}


@end

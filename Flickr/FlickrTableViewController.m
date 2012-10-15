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

@interface FlickrTableViewController () <MKMapViewDelegate>

@property (nonatomic, strong) FlickrModel *flickrModel;
@end

@implementation FlickrTableViewController

@synthesize flickrModel = _flickrModel;
@synthesize mapView = _mapView;
@synthesize tableViewStub = _tableViewStub;
@synthesize annotations = _annotations;
@synthesize viewMode = _viewMode;


- (FlickrModel *)flickrModel {
    if (!_flickrModel) _flickrModel = [[FlickrModel alloc] initWithEmptyData];
    return _flickrModel;
}

- (void)setFlickrModel:(FlickrModel *)flickrModel {
    if (_flickrModel != flickrModel) {
        _flickrModel = flickrModel;
        if (self.tableViewStub.window) [self.tableViewStub reloadData];
        NSArray *places = [flickrModel getPlaces];
        NSMutableDictionary *annotations = [NSMutableDictionary dictionaryWithCapacity:[places count]];
        for (NSDictionary *place in places) {
            FlickrPlaceAnnotation *annotation = [FlickrPlaceAnnotation annotationForPlace:place];
            [self.mapView addAnnotation:annotation];
            [annotations setValue:annotation forKey:[FlickrFetcher namePlace:place]];
        }
        self.annotations = annotations;
    }
}

- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Standard", @"Satellite", @"Hybrid", nil]]; // TODO i18n
        [segmentedControl setFrame:CGRectMake(32, 4, 256, 32)];
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

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr download queue1", NULL);
    dispatch_async(downloadQueue, ^{
        FlickrModel *flickrModel = [[FlickrModel alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
            self.flickrModel = flickrModel;
        });
    });
    dispatch_release(downloadQueue);
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

}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Most Viewed";
    [self refresh:self.navigationItem.rightBarButtonItem];
   
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return [self.flickrModel numberOfSection];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.flickrModel numberOfRow:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.flickrModel getSectionName:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FlickrCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *place = [self.flickrModel getPlace:indexPath.row sectionNumber:indexPath.section];
    cell.textLabel.text = [FlickrFetcher namePlace:place];
    cell.detailTextLabel.text = [FlickrFetcher descriptionPlace:place];
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
            place = annotation.place;
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


@end

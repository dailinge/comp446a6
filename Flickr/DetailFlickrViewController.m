//
//  DetailFlickrViewController.m
//  Flickr
//
//  Created by Linge Dai on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "DetailFlickrViewController.h"
#import "PhotoFlickrViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"

@interface DetailFlickrViewController () <MKMapViewDelegate>

@end

@implementation DetailFlickrViewController
@synthesize place = _place;
@synthesize photoList = _photoList;
@synthesize mapView = _mapView;
@synthesize tableViewStub = _tableViewStub;
@synthesize annotations = _annotations;
@synthesize viewMode = _viewMode;

- (void)reloadPhotoList:(NSDictionary *)place 
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    UIView *rightBarView = self.navigationItem.rightBarButtonItem.customView;
    self.navigationItem.rightBarButtonItem.customView = spinner;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr download queue2", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photoList = [FlickrFetcher photosInPlace:place maxResults:50];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoList = photoList;
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[place objectForKey:FLICKR_LATITUDE] doubleValue];
            coordinate.longitude = [[place objectForKey:FLICKR_LONGITUDE] doubleValue];
            self.mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.5, 0.5));
            self.navigationItem.rightBarButtonItem.customView = rightBarView;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)setPlace:(NSDictionary *)place
{
    if (place != _place) {
        _place = place;
        [self reloadPhotoList:place];
        self.title = [FlickrFetcher namePlace:place];
    }
}

- (void)setPhotoList:(NSArray *)photoList {
    if (photoList != _photoList) {
        _photoList = photoList;
        if (self.tableViewStub.window) [self.tableViewStub reloadData];
        NSMutableDictionary *annotations = [NSMutableDictionary dictionaryWithCapacity:[photoList count]];
        for (NSDictionary *photo in photoList) {
            FlickrPhotoAnnotation *annotation = [FlickrPhotoAnnotation annotationForPhoto:photo];
            [self.mapView addAnnotation:annotation];
            [annotations setValue:annotation forKey:[photo valueForKey:FLICKR_PHOTO_ID]];
        }
        self.annotations = annotations;
    }
}

- (NSArray *)photoList
{
    if (!_photoList) {
        _photoList = [[NSArray alloc] init];
    }
    return _photoList;
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
        self.navigationItem.rightBarButtonItem.title = @"List";
    } else if ([self.viewMode isEqualToString:@"List"]) {
        self.navigationItem.rightBarButtonItem.title = @"Map";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *photo = [self.photoList objectAtIndex:indexPath.row];
    cell.textLabel.text = [FlickrFetcher namePhoto:photo];
    
    cell.detailTextLabel.text = [FlickrFetcher descriptionPhoto:photo];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr detail thumbnail downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell.textLabel.text isEqualToString:[FlickrFetcher namePhoto:photo]] && [cell.detailTextLabel.text isEqualToString:[FlickrFetcher descriptionPhoto:photo]]) {
                UIImage *image = data ? [UIImage imageWithData:data] : nil;
                cell.imageView.image = image;
                cell.imageView.hidden = NO;
                [cell setNeedsLayout];
            }
        });
    });
    dispatch_release(downloadQueue);
    return cell;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableViewStub reloadData];
}

#pragma mark - Table view delegate

- (PhotoFlickrViewController *)splitViewPhotoFlickrViewController
{
    id nvc = [self.splitViewController.viewControllers lastObject];
    if (![nvc isKindOfClass:[UINavigationController class]]) {
        return nil;
    }
    NSArray *viewControllers = [(UINavigationController *)nvc viewControllers];
    id pfvc = [viewControllers objectAtIndex:0];
    if (![pfvc isKindOfClass:[PhotoFlickrViewController class]]) {
        return nil;
    }
    return pfvc;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if ([self splitViewPhotoFlickrViewController]) {
        NSDictionary *photo = [self.photoList objectAtIndex:indexPath.row];
        [self updateFavorite:photo];
        [[self splitViewPhotoFlickrViewController] setPhoto:photo];
    } else {
        [self performSegueWithIdentifier:@"PhotoImage" sender:self];
    }
    
}


- (void)updateFavorite:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [[defaults objectForKey:FLICKR_RECENT] mutableCopy];
    
    if (recentPhotos == nil)
    {
        recentPhotos = [NSMutableArray array];
    }
    
    NSString *photoId = [photo objectForKey:FLICKR_PHOTO_ID];
    NSMutableArray *newRecents = [NSMutableArray array];
    
    for (int index = 0; ((index < 20) && (index < [recentPhotos count])); index++) {
        NSDictionary *currentPhoto = [recentPhotos objectAtIndex:index];
        NSString *currentPhotoId = [currentPhoto objectForKey:FLICKR_PHOTO_ID];
        
        if (![currentPhotoId isEqualToString:photoId]) {
            [newRecents insertObject:currentPhoto atIndex:[newRecents count]];
        }
        
    }
    [newRecents insertObject:photo atIndex:0];
    if ([newRecents count] > 20) {
        NSRange range = NSMakeRange(0, 20);
        newRecents = [NSMutableArray arrayWithArray:[newRecents subarrayWithRange:range]];
    }
    
    [defaults setObject:[newRecents copy] forKey:FLICKR_RECENT];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PhotoImage"]) {
        NSDictionary *photo;
        if ([sender isKindOfClass:[UITableViewController class]]) {
            NSIndexPath *cellPath = [self.tableViewStub indexPathForSelectedRow];
            photo = [self.photoList objectAtIndex:cellPath.row];
        } else if ([sender isKindOfClass:[MKAnnotationView class]]) {
            FlickrPhotoAnnotation *annotation = (FlickrPhotoAnnotation *) ((MKAnnotationView *) sender).annotation;
            photo = annotation.photo;
        }
        
        [self updateFavorite:photo];
        [segue.destinationViewController setPhoto:photo];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"FlickrDVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"FlickrDVC"];
        aView.canShowCallout = YES;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    FlickrPhotoAnnotation *annotation = (FlickrPhotoAnnotation *) aView.annotation;
    dispatch_queue_t downloadQueue = dispatch_queue_create("detail flickr map downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:annotation.photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = data ? [UIImage imageWithData:data] : nil;
            ((UIImageView *) aView.leftCalloutAccessoryView).image = image;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([self splitViewPhotoFlickrViewController]) {
        FlickrPhotoAnnotation *annotation = (FlickrPhotoAnnotation *) view.annotation;
        NSDictionary *photo = annotation.photo;
        [self updateFavorite:photo];
        [[self splitViewPhotoFlickrViewController] setPhoto:photo];
    } else {
        [self performSegueWithIdentifier:@"PhotoImage" sender:view];
    }
    
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

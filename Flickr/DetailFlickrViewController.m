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

@interface DetailFlickrViewController ()

@end

@implementation DetailFlickrViewController
@synthesize place = _place;
@synthesize photoList = _photoList;

- (void)reloadPhotoList:(NSDictionary *)place 
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] 
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr download queue2", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photoList = [FlickrFetcher photosInPlace:place maxResults:50];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoList = photoList;
            self.navigationItem.rightBarButtonItem = nil;
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
        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (NSArray *)photoList
{
    if (!_photoList) {
        _photoList = [[NSArray alloc] init];
    }
    return _photoList;
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
    
    return cell;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (PhotoFlickrViewController *)splitViewPhotoFlickrViewController
{
    id pfvc = [self.splitViewController.viewControllers lastObject];
    if (![pfvc isKindOfClass:[PhotoFlickrViewController class]]) {
        pfvc = nil;
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
        NSIndexPath *cellPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *photo = [self.photoList objectAtIndex:cellPath.row];
        [self updateFavorite:photo];
        [segue.destinationViewController setPhoto:photo];
    }
}

@end

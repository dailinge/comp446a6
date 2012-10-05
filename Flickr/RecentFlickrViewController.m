//
//  RecentFlickrViewController.m
//  Flickr
//
//  Created by Heaven  Chen on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "RecentFlickrViewController.h"
#import "FlickrFetcher.h"
#import "PhotoFlickrViewController.h"

@interface RecentFlickrViewController ()

@end

@implementation RecentFlickrViewController

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

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = @"Recents";
    [self.tableView reloadData];
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

- (NSArray *)getRecents
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recentPhotos = [defaults objectForKey:FLICKR_RECENT];
    
    if (recentPhotos == nil) {
        recentPhotos = [NSArray array];
    }
    return recentPhotos;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [[self getRecents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary *photo = [[self getRecents] objectAtIndex:indexPath.row];
    cell.textLabel.text = [FlickrFetcher namePhoto:photo];
    
    cell.detailTextLabel.text = [FlickrFetcher descriptionPhoto:photo];   
    
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
    [self performSegueWithIdentifier:@"RecentPhoto" sender:self];
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
    if ([segue.identifier isEqualToString:@"RecentPhoto"]) {
        NSIndexPath *cellPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *photo = [[self getRecents] objectAtIndex:cellPath.row];
        [self updateFavorite:photo];
        [segue.destinationViewController setPhoto:photo];
    }
}

@end

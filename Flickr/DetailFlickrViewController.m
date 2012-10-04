//
//  DetailFlickrViewController.m
//  Flickr
//
//  Created by Heaven  Chen on 10/4/12.
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

- (void)setPlace:(NSDictionary *)place
{
    if (place != _place) {
        _place = place;
        NSString *content = [_place valueForKeyPath:@"_content"];
        NSArray *contentSegments = [content componentsSeparatedByString:@","];
        NSString *cityName = [contentSegments objectAtIndex:0];
        self.title = cityName;
    }
}

- (void)setPhotoList:(NSArray *)photoList {
    if (photoList != _photoList) {
        //NSLog(@"%@", photoList);
        _photoList = photoList;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self performSegueWithIdentifier:@"PhotoImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PhotoImage"]) {
        NSIndexPath *cellPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *photo = [self.photoList objectAtIndex:cellPath.row];
        [segue.destinationViewController setPhoto:photo];
    }
}

@end

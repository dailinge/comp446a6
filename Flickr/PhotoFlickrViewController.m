//
//  PhotoFlickrViewController.m
//  Flickr
//
//  Created by Linge Dai on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "PhotoFlickrViewController.h"
#import "FlickrFetcher.h"

@interface PhotoFlickrViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;

@end

@implementation PhotoFlickrViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolBar = _toolBar;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;


- (void)loadImage {
    NSURL *imageUrl = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
    NSData *photoData = [NSData dataWithContentsOfURL:imageUrl];
    self.imageView.image = [UIImage imageWithData:photoData];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.imageView.image.size};
    
    self.scrollView.contentSize = self.imageView.image.size;
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect scrollViewBounds = self.scrollView.bounds;
    CGFloat scaleWidth = scrollViewBounds.size.width / self.imageView.image.size.width;
    CGFloat scaleHeight = scrollViewBounds.size.height / self.imageView.image.size.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    [self.scrollView zoomToRect:self.imageView.frame animated:YES];
    
}


- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
        if (self.splitViewController == nil) {
            self.title = [FlickrFetcher namePhoto:photo];
        } else {
            self.scrollView.zoomScale = 1.0f;
            [self loadImage];
            CGRect scrollViewBounds = self.scrollView.bounds;
            CGFloat scaleWidth = scrollViewBounds.size.width / self.imageView.image.size.width;
            CGFloat scaleHeight = scrollViewBounds.size.height / self.imageView.image.size.height;
            CGFloat minScale = MIN(scaleWidth, scaleHeight);
            if (minScale > 1.0f) {
                self.scrollView.minimumZoomScale = 1.0f;
                self.scrollView.maximumZoomScale = 2.0f;
            } else {
                self.scrollView.minimumZoomScale = minScale;
                self.scrollView.maximumZoomScale = 1.0f;
            }
            [self.scrollView zoomToRect:self.imageView.frame animated:YES];
        }
        
    }
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.splitViewController.delegate = self;
    [self loadImage];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    self.scrollView.contentSize = self.imageView.image.size;
    CGRect scrollViewBounds = self.scrollView.bounds;
    CGFloat scaleWidth = 0;
    CGFloat scaleHeight = 0;
    if (UIDeviceOrientationIsPortrait(fromInterfaceOrientation)) {
        scaleWidth = scrollViewBounds.size.width / self.imageView.image.size.width;
        scaleHeight = scrollViewBounds.size.height / self.imageView.image.size.height;
    } else {
        scaleWidth = scrollViewBounds.size.width / self.imageView.image.size.width;
        scaleHeight = scrollViewBounds.size.height / self.imageView.image.size.height;
    }
   
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = 1.0f;
    [self.scrollView zoomToRect:self.imageView.frame animated:YES];
    //self.scrollView.zoomScale = minScale;

}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Top Places";
    // tell the detail view to put the button up
    
    self.splitViewBarButtonItem = barButtonItem;
}


-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //tell the detail view to take the button away
    self.splitViewBarButtonItem = nil;
    
}




@end

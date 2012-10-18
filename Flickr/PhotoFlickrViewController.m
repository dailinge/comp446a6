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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation PhotoFlickrViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize toolBar = _toolBar;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize spinner = _spinner;

- (void)loadImage {
    [self.spinner startAnimating];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr download queue3", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *imageUrl = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
        NSData *photoData = [NSData dataWithContentsOfURL:imageUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.imageView.image = [UIImage imageWithData:photoData];
            [self.spinner stopAnimating];
            self.scrollView.contentSize = self.imageView.image.size;
            self.scrollView.zoomScale = 1.0f;
            
            
        });
    });
    dispatch_release(downloadQueue);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
        if (self.splitViewController == nil) {
            self.title = [FlickrFetcher namePhoto:photo];
        } else {
            self.imageView.image = nil;
            self.title = [FlickrFetcher namePhoto:photo];
            [self loadImage];
        }
        
    }
        
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.splitViewController.delegate = self;
    self.scrollView.delegate = self;
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

/*- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
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

}*/

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        self.navigationItem.leftBarButtonItem = splitViewBarButtonItem;
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

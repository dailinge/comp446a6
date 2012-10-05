//
//  PhotoFlickrViewController.m
//  Flickr
//
//  Created by Heaven  Chen on 10/4/12.
//  Copyright (c) 2012 Rice. All rights reserved.
//

#import "PhotoFlickrViewController.h"
#import "FlickrFetcher.h"

@interface PhotoFlickrViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PhotoFlickrViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize photo = _photo;


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
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
}


- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
        self.title = [FlickrFetcher namePhoto:photo];
        
    }
        
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadImage];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}




@end

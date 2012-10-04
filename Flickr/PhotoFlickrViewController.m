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
    NSURL *imageUrl = [FlickrFetcher urlForPhoto:self.photo format:2];
    NSData *photoData = [NSData dataWithContentsOfURL:imageUrl];
    self.imageView.image = [UIImage imageWithData:photoData];
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.imageView.image.size;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2;
    
    [self.view setNeedsDisplay];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                      withView:(UIView *)view
                       atScale:(float)scale
{
}


@end

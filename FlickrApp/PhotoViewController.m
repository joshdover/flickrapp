//
//  FlickrAppPhotoViewController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"

@interface PhotoViewController () <UIScrollViewDelegate>

@end

@implementation PhotoViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setup
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("download queue", NULL);
    dispatch_async(downloadQueue, ^{
        if (self.photo == nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([[defaults objectForKey:@"Recent Photos"] count] > 0) {
                self.photo = [[defaults objectForKey:@"Recent Photos"] objectAtIndex:0];
                self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
            }
        }
        UIImage *newImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = newImage;
            self.scrollView.contentSize = self.imageView.image.size;
            self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
            float horZoomScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
            float verZoomScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
            [self.scrollView setZoomScale:MAX(horZoomScale, verZoomScale) animated:NO];
            self.scrollView.minimumZoomScale = MAX(horZoomScale, verZoomScale);
            self.navigationItem.rightBarButtonItem = nil;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)updatePhoto:(NSDictionary *)newPhoto withTitle:(NSString *)title
{
    self.photo = newPhoto;
    self.title = title;
    
    [self setup];
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    self.scrollView.delegate = self;
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Browser";
    // [self setupSplitViewControllerButton:barButtonItem];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

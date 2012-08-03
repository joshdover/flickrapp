//
//  PhotoMapViewController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/27/12.
//
//

#import "PhotoMapViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoAnnotation.h"
#import "PhotoViewController.h"

@interface PhotoMapViewController () <MKMapViewDelegate>

@end

@implementation PhotoMapViewController

#pragma mark - Synchronize Model and View

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)mapTypeChanged:(UISegmentedControl *)sender
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
            break;
    }
}

- (void)updatePlace
{
    // set the title
    self.title = [self.place objectForKey:FLICKR_PLACE_NAME];
    
    // setup the center of the map
    if (self.place != nil) {
        CLLocationCoordinate2D centerCoordinate;
        centerCoordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
        centerCoordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
        [self.mapView setRegion:MKCoordinateRegionMake(centerCoordinate, MKCoordinateSpanMake(.2, .2))];
    }
}

- (void)setPlace:(NSDictionary *)place
{
    _place = place;
    [self updatePlace];
}

# pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
//    dispatch_queue_t getAnnotationPhoto = dispatch_queue_create("download annotation", NULL);
//    dispatch_async(getAnnotationPhoto, ^{
//        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
//        });
//    });
    
    UIImage *image = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
    [(UIImageView *)view.leftCalloutAccessoryView setImage:image];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self.delegate displayDetailInformationForAnnotation:view.annotation];
}

# pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self updatePlace];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)mapTypeSelector:(id)sender {
}
@end

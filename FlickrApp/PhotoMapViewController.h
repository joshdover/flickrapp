//
//  PhotoMapViewController.h
//  FlickrApp
//
//  Created by Joshua Dover on 7/27/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PhotoMapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(PhotoMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
- (void)displayDetailInformationForAnnotation:(id <MKAnnotation>)annotation;
@end

@interface PhotoMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSDictionary *place;
@property (strong, nonatomic) NSArray *annotations; // of <MKAnnotation>
@property (weak, nonatomic) id <MapViewControllerDelegate> delegate;
@end

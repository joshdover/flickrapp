//
//  FlickrPhotoAnnotation.h
//  FlickrApp
//
//  Created by Joshua Dover on 7/28/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

+ (FlickrPhotoAnnotation *)annotationForPhoto:(NSDictionary *)photo;

@property (strong, nonatomic) NSDictionary *photo;

@end

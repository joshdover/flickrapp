//
//  PhotoCacher.h
//  FlickrApp
//
//  Created by Joshua Dover on 8/2/12.
//
//

#import <Foundation/Foundation.h>
#import "FlickrFetcher.h"

@interface PhotoCacher : NSObject

+ (NSData *)getPhoto:(NSDictionary *)photo withFormat:(FlickrPhotoFormat)format;

@end

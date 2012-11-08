//
//  PhotoCacher.m
//  FlickrApp
//
//  Created by Joshua Dover on 8/2/12.
//
//

#import "PhotoCacher.h"
#import "FlickrFetcher.h"

@implementation PhotoCacher

#pragma mark - Cache management

+ (NSURL *)cacheDirectoryForFormat:(FlickrPhotoFormat)format
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray *appSupportDir = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0) {
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:@"FlickrCache"];
        dirPath = [dirPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%u", format]];
        [fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dirPath;
}

+ (NSURL *)URLForPhoto:(NSDictionary *)photo withFormat:(FlickrPhotoFormat)format
{
    return [[self cacheDirectoryForFormat:format] URLByAppendingPathComponent:[[[photo objectForKey:FLICKR_PHOTO_ID] stringByAppendingFormat:@"_%u", format] stringByAppendingString:@".jpg"]];
}

+ (NSData *)savePhotoToCache:(NSDictionary *)photo withFormat:(FlickrPhotoFormat)format
{
    NSURL *photoURL = [self URLForPhoto:photo withFormat:format];
    
    NSData *newPhoto = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:photo format:format]];
    [newPhoto writeToURL:photoURL atomically:NO];

    [self cleanupCacheForFormat:format];
    
    return newPhoto;
}

+ (int)folderSizeForFormat:(FlickrPhotoFormat)format
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *filesEnumerator = [manager enumeratorAtPath:[[self cacheDirectoryForFormat:format] path]];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [manager attributesOfItemAtPath:[[[self cacheDirectoryForFormat:format] path] stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}

+ (void)deleteOldestPhotoForFormat:(FlickrPhotoFormat)format
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *filesEnumerator = [manager enumeratorAtPath:[[self cacheDirectoryForFormat:format] path]];
    NSString *currentFileName;
    NSString *oldestFileName;
    NSDate *currentDate;
    NSDate *oldestDate;
    
    while (currentFileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [manager attributesOfItemAtPath:[[[self cacheDirectoryForFormat:format] path] stringByAppendingPathComponent:currentFileName] error:nil];
        currentDate = [fileDictionary objectForKey:NSFileCreationDate];
        if ([[currentDate earlierDate:oldestDate] isEqualToDate:currentDate]) {
            oldestDate = currentDate;
            oldestFileName = currentFileName;
        }
    }
    
//    NSLog(@"Removing: %@", oldestFileName);
    [manager removeItemAtPath:[[[self cacheDirectoryForFormat:format] path] stringByAppendingPathComponent:oldestFileName] error:nil];
}

+ (void)cleanupCacheForFormat:(FlickrPhotoFormat)format
{
    int folderSize = [self folderSizeForFormat:format];
    while (folderSize > 10485760) {
        [self deleteOldestPhotoForFormat:format];
        folderSize = [self folderSizeForFormat:format];
    }
    
//    NSLog(@"File Size: %i", folderSize);
}

+ (NSData *)getPhoto:(NSDictionary *)photo withFormat:(FlickrPhotoFormat)format
{
    NSURL *photoURL = [self URLForPhoto:photo withFormat:format];
    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    if (photoData != nil) {
        return photoData;
    } else {
        return [self savePhotoToCache:photo withFormat:format];
    }
}

@end

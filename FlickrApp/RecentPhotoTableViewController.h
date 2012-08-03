//
//  FlickrAppRecentPhotoTableViewController.h
//  FlickrApp
//
//  Created by Joshua Dover on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentPhotoTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *recentPhotos;

- (void)reloadRecentPhotos;

@end

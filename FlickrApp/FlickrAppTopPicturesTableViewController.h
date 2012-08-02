//
//  FlickrAppTopPicturesTableViewController.h
//  FlickrApp
//
//  Created by Joshua Dover on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrAppTopPicturesTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photos;

@end

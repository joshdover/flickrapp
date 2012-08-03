//
//  FlickrAppTabBarController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrAppTabBarController.h"
#import "RecentPhotoTableViewController.h"

@implementation FlickrAppTabBarController

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    self.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 1) {
        if (![(RecentPhotoTableViewController*)[(UINavigationController*)viewController topViewController] isKindOfClass:[RecentPhotoTableViewController class]]) {
            [(UINavigationController*)viewController popToRootViewControllerAnimated:NO];
        }
        [(RecentPhotoTableViewController*)[(UINavigationController*)viewController topViewController] reloadRecentPhotos];
    }
}

@end

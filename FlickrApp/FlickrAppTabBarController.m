//
//  FlickrAppTabBarController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrAppTabBarController.h"
#import "FlickrAppRecentPhotoTableViewController.h"

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
        if (![(FlickrAppRecentPhotoTableViewController*)[(UINavigationController*)viewController topViewController] isKindOfClass:[FlickrAppRecentPhotoTableViewController class]]) {
            [(UINavigationController*)viewController popToRootViewControllerAnimated:NO];
        }
        [(FlickrAppRecentPhotoTableViewController*)[(UINavigationController*)viewController topViewController] reloadRecentPhotos];
    }
}

@end

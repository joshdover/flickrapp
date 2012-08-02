//
//  FlickrAppPhotoViewController.h
//  FlickrApp
//
//  Created by Joshua Dover on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewControllerButtonItemPresenter.h"

@interface FlickrAppPhotoViewController : UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSDictionary *photo;

- (void)updatePhoto:(NSDictionary *)photo withTitle:(NSString *)title;

@end

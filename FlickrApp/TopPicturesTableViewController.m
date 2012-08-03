//
//  FlickrAppTopPicturesTableViewController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TopPicturesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "PhotoMapViewController.h"

#define MAX_PHOTOS 50

@interface TopPicturesTableViewController () <MapViewControllerDelegate>

@end

@implementation TopPicturesTableViewController

@synthesize place = _place;
@synthesize photos = _photos;

- (void)loadData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    UIBarButtonItem *mapButton = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    NSArray *nameParts = [[self.place objectForKey:@"_content"] componentsSeparatedByString:@", "];
    self.title = [nameParts objectAtIndex:0];
    
    dispatch_queue_t getPhotoData = dispatch_queue_create("get photo data", NULL);
    dispatch_async(getPhotoData, ^{
        self.photos = [FlickrFetcher photosInPlace:self.place maxResults:MAX_PHOTOS];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.navigationItem.rightBarButtonItem = mapButton;
        });
    });
    dispatch_release(getPhotoData);
}

- (void)setPlace:(NSDictionary *)place
{
    _place = place;
    [self loadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSString *)titleForPhoto:(NSDictionary *)photo
{
    NSString *result = @"";
    
    NSString *title = [photo objectForKey:@"title"];
    NSString *description = [[photo objectForKey:@"description"] objectForKey:@"_content"];
    
    if (![title isEqualToString:@""]) {
        result = title;
    } else if (![description isEqualToString:@""]) {
        result = description;
    } else {
        result = @"(blank)";
    }
    
    return result;
}

- (NSString *)descriptionForPhoto:(NSDictionary *)photo
{
    return [photo objectForKey:FLICKR_PHOTO_OWNER];
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(PhotoMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    [self savePhotoToRecents:fpa.photo];
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (void)displayDetailInformationForAnnotation:(id<MKAnnotation>)annotation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
        [(PhotoViewController *)[(UINavigationController *)[self.splitViewController.viewControllers lastObject] topViewController] updatePhoto:fpa.photo withTitle:[self titleForPhoto:fpa.photo]];
    } else {
        [self performSegueWithIdentifier:@"Show Photo from Map" sender:annotation];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo"]) {                       
        [segue.destinationViewController setPhoto:[self.photos objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        [segue.destinationViewController setTitle:[self titleForPhoto:[self.photos objectAtIndex:[self.tableView indexPathForSelectedRow].row]]]; 
    } else if ([segue.identifier isEqualToString:@"Show Map"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setPlace:self.place];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    } else if ([segue.identifier isEqualToString:@"Show Photo from Map"]) {
        FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)sender;
        [segue.destinationViewController setPhoto:fpa.photo];
        [segue.destinationViewController setTitle:[self titleForPhoto:fpa.photo]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX_PHOTOS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    cell.textLabel.text = [self titleForPhoto:[self.photos objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [self descriptionForPhoto:[self.photos objectAtIndex:indexPath.row]];
    
    // cell.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:[self.photos objectAtIndex:indexPath.row] format:FlickrPhotoFormatSquare]]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)savePhotoToRecents:(NSDictionary *)photo
{
    dispatch_queue_t saveToDefaults = dispatch_queue_create("save to recents", NULL);
    dispatch_async(saveToDefaults, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *recentPhotos = [[defaults objectForKey:@"Recent Photos"] mutableCopy];
        NSDictionary *newRecentPhoto = photo;
        
        if (![recentPhotos containsObject:newRecentPhoto]) {
            [recentPhotos insertObject:newRecentPhoto atIndex:0];
            if ([[NSNumber numberWithInt:[recentPhotos count]] intValue] > 25) {
                [recentPhotos removeLastObject];
            }
            [defaults setObject:[recentPhotos copy] forKey:@"Recent Photos"];
            [defaults synchronize];
        }
    });
    dispatch_release(saveToDefaults);
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    [self savePhotoToRecents:[self.photos objectAtIndex:indexPath.row]];

    [(PhotoViewController *)[(UINavigationController *)[self.splitViewController.viewControllers objectAtIndex:1] topViewController] updatePhoto:[self.photos objectAtIndex:[self.tableView indexPathForSelectedRow].row] withTitle:[self titleForPhoto:[self.photos objectAtIndex:[self.tableView indexPathForSelectedRow].row]]];
}

@end

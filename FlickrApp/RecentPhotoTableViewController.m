//
//  FlickrAppRecentPhotoTableViewController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecentPhotoTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "PhotoMapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "PhotoCacher.h"

@interface RecentPhotoTableViewController () <MapViewControllerDelegate>

@end

@implementation RecentPhotoTableViewController

@synthesize recentPhotos = _recentPhotos;

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
    [self reloadRecentPhotos];
    
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
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.recentPhotos count]];
    for (NSDictionary *photo in self.recentPhotos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Recent Photo"]) {
        [segue.destinationViewController setPhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        [segue.destinationViewController setTitle:[self titleForPhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row]]]; 
    } else if ([segue.identifier isEqualToString:@"Show Map from Recents"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    } else if ([segue.identifier isEqualToString:@"Show Recent Photo from Map"]) {
        FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)sender;
        [segue.destinationViewController setPhoto:fpa.photo];
        [segue.destinationViewController setTitle:[self titleForPhoto:fpa.photo]];
    }
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(PhotoMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
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
        [self performSegueWithIdentifier:@"Show Recent Photo from Map" sender:annotation];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Show Recent Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *photoForCell = [self.recentPhotos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [self titleForPhoto:photoForCell];
    cell.detailTextLabel.text = [self descriptionForPhoto:photoForCell];
    
    dispatch_queue_t downloadThumbnail = dispatch_queue_create("get photo data", NULL);
    dispatch_async(downloadThumbnail, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = nil;
        });
        NSData *thumbnail = nil;
        if (photoForCell != nil) {
            thumbnail = [PhotoCacher getPhoto:photoForCell withFormat:FlickrPhotoFormatSquare];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:thumbnail];
                [cell setNeedsLayout];
            });
        }
    });
    dispatch_release(downloadThumbnail);
    
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

- (void)reloadRecentPhotos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.recentPhotos = [defaults objectForKey:@"Recent Photos"];
    [self.tableView reloadData];
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
    
    
    [(PhotoViewController *)[(UINavigationController *)[self.splitViewController.viewControllers objectAtIndex:1] topViewController] updatePhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row] withTitle:[self titleForPhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row]]];
}

@end

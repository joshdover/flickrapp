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

@interface RecentPhotoTableViewController ()

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
        result = @"Unknown";
    }
    
    return result;
}

- (NSString *)descriptionForPhoto:(NSDictionary *)photo
{    
    return [photo objectForKey:FLICKR_PHOTO_OWNER];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Recent Photo"]) {                       
        [segue.destinationViewController setPhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        [segue.destinationViewController setTitle:[self titleForPhoto:[self.recentPhotos objectAtIndex:[self.tableView indexPathForSelectedRow].row]]]; 
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
    
    cell.textLabel.text = [self titleForPhoto:[self.recentPhotos objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [self descriptionForPhoto:[self.recentPhotos objectAtIndex:indexPath.row]];
    
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

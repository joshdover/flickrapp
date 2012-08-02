//
//  FlickrAppTopPlacesViewController.m
//  FlickrApp
//
//  Created by Joshua Dover on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrAppTopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "FlickrAppTopPicturesTableViewController.h"

@interface FlickrAppTopPlacesViewController ()

@end

@implementation FlickrAppTopPlacesViewController

@synthesize places = _places;

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

- (NSArray *)places
{
    if (!_places) {
        [self refresh:self];
    }
    return _places;
}

- (IBAction)refresh:(id)sender
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadPlaces = dispatch_queue_create("download place", NULL);
    dispatch_async(downloadPlaces, ^{
        _places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = nil;
            [self.tableView reloadData];
        });
    });
    dispatch_release(downloadPlaces);
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recentPhotos = [defaults objectForKey:@"Recent Photos"];
    if (!recentPhotos) {
        recentPhotos = [[NSArray alloc] init];
        [defaults setObject:recentPhotos forKey:@"Recent Photos"];
        [defaults synchronize];
    }

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Place Photos"]) {
        
        dispatch_queue_t loadPhotosForPlace = dispatch_queue_create("load photos for place", NULL);
        dispatch_async(loadPhotosForPlace, ^{
            NSDictionary *place = [self.places objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            dispatch_async(dispatch_get_main_queue(), ^{
                [segue.destinationViewController setPlace:place];
            });
        });
        dispatch_release(loadPhotosForPlace);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Top Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... (get descriptions for cell)
    NSArray *nameParts = [[[self.places objectAtIndex:indexPath.row] objectForKey:@"_content"] componentsSeparatedByString:@", "];
    
    
    cell.textLabel.text = [nameParts objectAtIndex:0];
    if ([nameParts count] == 3) {
        cell.detailTextLabel.text = [[nameParts objectAtIndex:1] stringByAppendingFormat:@", %@", [nameParts objectAtIndex:2]];
    } else {
        cell.detailTextLabel.text = [nameParts objectAtIndex:1];
    }
    
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
    
}

@end

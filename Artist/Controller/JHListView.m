//
//  JHListView.m
//  Artist
//
//  Created by Sean Grusd on 1/20/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import "JHListView.h"
#import "PFService.h"
#import "JHDetailView.h"

@interface JHListView ()

@end

@implementation JHListView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Artists";
}

- (void)dealloc {
    
    [super dealloc];
    [artistList release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [artistList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Default Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSDictionary * dict = [artistList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"name"]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"System" size:12];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * dict = [artistList objectAtIndex:indexPath.row];
    NSString * artistID = [dict objectForKey:@"id"];
    NSString * artistName = [dict objectForKey:@"name"];
    
    [[PFService sharedManeger] getDetailArtist:artistID withCompletationHandler:^(NSData *response, NSError *error) {
        
        if(response)
        {
            id dict = [response objectFromJSONData];
            if([[dict objectForKey:@"response"] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary * resDict = [dict objectForKey:@"response"];
                NSLog(@"%@", resDict);
                
                JHDetailView * detailView = [[[JHDetailView alloc] initWithNibName:@"JHDetailView" bundle:nil] autorelease];

                detailView.artistName = artistName;
                detailView.artistDict = [resDict objectForKey:@"artist"];
                [self.navigationController pushViewController:detailView animated:YES];
            }
        }
        else
        {
            [PFService showAlertWithConnectionError];
        }
    }];
}

#pragma mark -
#pragma mark SearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText length] == 0) {
        
        [artistList release];
        artistList = nil;
        [listTableView reloadData];
    } else {
        
        [[PFService sharedManeger] getArtistList:searchText withCompletationHandler:^(NSData *response, NSError *error) {
            
            if(response)
            {
                id dict = [response objectFromJSONData];
                [artistList release];
                if([[dict objectForKey:@"response"] isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary * resDict = [dict objectForKey:@"response"];
                    artistList = [[resDict objectForKey:@"artists"] retain];
                    
                    [listTableView reloadData];
                    
                }
            }
            else
            {
                [PFService showAlertWithConnectionError];
            }
        }];
    }    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [listTableView reloadData];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

@end

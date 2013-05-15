//
//  GamePickerRecentViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerSearchViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "AsyncMediaImageView.h"

@implementation GamePickerSearchViewController

@synthesize theSearchBar;
@synthesize disableViewOverlay;

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GamePickerSearchViewController" bundle:nil delegate:d])
    {        
        currentPage = 0;
        currentlyFetchingNextPage = NO;
        allResultsFound = YES;
        searchText = @"";
        
        self.title = NSLocalizedString(@"SearchKey", @"");
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewSearchGameListReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"GamePickerSearchGamesKey", @"");
    
    [self.theSearchBar becomeFirstResponder];
}

- (void)requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        currentPage = 0;
        self.theSearchBar.text = searchText;
        if(![searchText isEqualToString:@""]) [self performSearch:searchText];
        [self showLoadingIndicator];
    }
}
    
- (void)refreshViewFromModel
{
    if(currentPage == 0) self.gameList = [AppModel sharedAppModel].searchGameList;
    else                 self.gameList = [self.gameList arrayByAddingObjectsFromArray:[AppModel sharedAppModel].searchGameList];
    
    currentlyFetchingNextPage = NO;
    currentPage++;
    if([AppModel sharedAppModel].searchGameList.count == 0) allResultsFound = YES;
    
	[gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(allResultsFound) return [super tableView:tableView numberOfRowsInSection:section];
    else                return [super tableView:tableView numberOfRowsInSection:section]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= [self.gameList count])
    {
        if(!currentlyFetchingNextPage && !allResultsFound) [self performSearch:searchText];
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FetchCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FetchCell"];
    
        if(!allResultsFound)                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchLoadingMoreKey", @"");
        else if([self.gameList count] == 0) cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoResults", @"");
        else                                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoMoreKey", @"");
        return cell;
    }
    else
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchText = searchBar.text;
	
    [self searchBar:searchBar activate:NO];
    currentPage = 0;
    [self performSearch:searchText];
}

- (void)performSearch:(NSString *)text
{
    if(searchText == nil || [searchText isEqualToString:@""]) return;
        
    [[AppServices sharedAppServices] fetchGameListBySearch:[text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] onPage:currentPage];
    currentlyFetchingNextPage = YES;
    allResultsFound = NO;
    
	[self showLoadingIndicator];
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL)active
{
    self.gameTable.allowsSelection = !active;
    self.gameTable.scrollEnabled   = !active;
    if (!active)
    {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    }
    else
    {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        NSIndexPath *selected = [self.gameTable indexPathForSelectedRow];
        if (selected) [self.gameTable deselectRowAtIndexPath:selected animated:NO];
    }
    [searchBar setShowsCancelButton:active animated:YES];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

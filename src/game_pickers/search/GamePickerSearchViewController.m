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
#import "GamePickerCell.h"

@interface GamePickerSearchViewController() <UISearchDisplayDelegate, UISearchBarDelegate>
{    
    UISearchBar *theSearchBar;
    UIView *disableViewOverlay;
    NSString *searchText;
    long currentPage;
    BOOL currentlyFetchingNextPage;
    BOOL allResultsFound;
}

@end

@implementation GamePickerSearchViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {        
        currentPage = 0;
        currentlyFetchingNextPage = NO;
        allResultsFound = YES;
        searchText = @"";
        
        self.title = NSLocalizedString(@"GamePickerSearchTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"search_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"search.png"]];    
        
  _ARIS_NOTIF_LISTEN_(@"MODEL_SEARCH_GAMES_AVAILABLE",self,@selector(searchGamesAvailable),nil);
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,30)];
    theSearchBar.delegate = self;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [gameTable addGestureRecognizer:gestureRecognizer];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [theSearchBar becomeFirstResponder];
}

- (void) searchGamesAvailable
{
    [self removeLoadingIndicator];
    games = _MODEL_GAMES_.searchGames;
	[gameTable reloadData];
}

- (void) refreshViewFromModel
{
    games = [_MODEL_GAMES_ pingSearchGames:theSearchBar.text];
	[gameTable reloadData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 30;
    else return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(allResultsFound) return [super tableView:tableView numberOfRowsInSection:section]+1;
    else                return [super tableView:tableView numberOfRowsInSection:section]+1;
    //else                return [super tableView:tableView numberOfRowsInSection:section]+2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
        
        [cell addSubview:theSearchBar];
    
        return cell;
    }
    else if(indexPath.row >= games.count+1)
    {
        if(!currentlyFetchingNextPage && !allResultsFound) [self attemptSearch:searchText];
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FetchCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FetchCell"];
    
        if(!allResultsFound)                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchLoadingMoreKey", @"");
        else if(games.count == 0) cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoResults", @"");
        else                                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoMoreKey", @"");
        return cell;
    }
    else
        return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0) {
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
    }
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self searchBar:searchBar activate:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchText = searchBar.text;
	
    [self searchBar:searchBar activate:NO];
    currentPage = 0;
    [self attemptSearch:searchText];
}

- (void) attemptSearch:(NSString *)text
{
    if(searchText == nil || [searchText isEqualToString:@""]) return;
        
    currentlyFetchingNextPage = YES;
    allResultsFound = NO;
    
    [self refreshViewFromModel];
}

- (void) searchBar:(UISearchBar *)searchBar activate:(BOOL)active
{
    gameTable.allowsSelection = !active;
    gameTable.scrollEnabled   = !active;
    if (!active)
    {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    }
    else
    {
        disableViewOverlay.alpha = 0;
        [self.view addSubview:disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        NSIndexPath *selected = [gameTable indexPathForSelectedRow];
        if (selected) [gameTable deselectRowAtIndexPath:selected animated:NO];
    }
    [searchBar setShowsCancelButton:active animated:YES];
}

- (void) hideKeyboard: (UIGestureRecognizer *) gesture
{
    [self searchBarCancelButtonClicked:theSearchBar];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);          
}

@end

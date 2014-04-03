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
#import "Player.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "UIColor+ARISColors.h"

@interface GamePickerSearchViewController() <UISearchDisplayDelegate, UISearchBarDelegate>
{    
    UISearchBar *theSearchBar;
    UIView *disableViewOverlay;
    NSString *searchText;
    int currentPage;
    BOOL currentlyFetchingNextPage;
    BOOL allResultsFound;
}

@property UIView *disableViewOverlay;
@property (nonatomic, strong) UISearchBar *theSearchBar;

@end

@implementation GamePickerSearchViewController

@synthesize theSearchBar;
@synthesize disableViewOverlay;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewSearchGameListReady" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,30)];
    self.theSearchBar.delegate = self;
    [self.theSearchBar becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [gameTable addGestureRecognizer:gestureRecognizer];
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].deviceLocation && [AppModel sharedAppModel].player)    
    {
        currentPage = 0;
        self.theSearchBar.text = searchText;
        [self attemptSearch:searchText];
    }
}
    
- (void) refreshViewFromModel
{
    if(currentPage == 0) self.gameList = [AppModel sharedAppModel].searchGameList;
    else                 self.gameList = [self.gameList arrayByAddingObjectsFromArray:[AppModel sharedAppModel].searchGameList];
    
    currentlyFetchingNextPage = NO;
    currentPage++;
    if([AppModel sharedAppModel].searchGameList.count == 0) allResultsFound = YES;
    
	[gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 40;
    else return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(allResultsFound) return [super tableView:tableView numberOfRowsInSection:section]+1;
    else                return [super tableView:tableView numberOfRowsInSection:section]+2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchCell"];
        
        [cell addSubview:self.theSearchBar];
    
        return cell;
    }
    else if(indexPath.row >= [self.gameList count]+1)
    {
        if(!currentlyFetchingNextPage && !allResultsFound) [self attemptSearch:searchText];
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FetchCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FetchCell"];
    
        if(!allResultsFound)                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchLoadingMoreKey", @"");
        else if([self.gameList count] == 0) cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoResults", @"");
        else                                cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoMoreKey", @"");
        return cell;
    }
    else
        return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
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
        
    [[AppServices sharedAppServices] fetchGameListBySearch:[text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] onPage:currentPage];
    currentlyFetchingNextPage = YES;
    allResultsFound = NO;
    
	[self showLoadingIndicator];
}

- (void) searchBar:(UISearchBar *)searchBar activate:(BOOL)active
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

- (void) hideKeyboard: (UIGestureRecognizer *) gesture
{
    [self searchBarCancelButtonClicked:theSearchBar];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

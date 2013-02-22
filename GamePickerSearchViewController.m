//
//  GamePickerRecentViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerSearchViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#include <QuartzCore/QuartzCore.h>

@implementation GamePickerSearchViewController

@synthesize gameTable;
@synthesize gameList;
@synthesize refreshButton,theSearchBar;
@synthesize disableViewOverlay,searchText;
@synthesize currentPage;
@synthesize currentlyFetchingNextPage;
@synthesize allResultsFound;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self)
    {
        self.title = NSLocalizedString(@"SearchKey", @"");
        self.navigationItem.title = NSLocalizedString(@"GamePickerSearchGamesKey", @"");
		self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];
        self.currentPage = 0;
        self.currentlyFetchingNextPage = NO;
        self.allResultsFound = YES;
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    [self.theSearchBar becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];
    [gameTable reloadData];

    [super viewDidAppear:animated];
}

#pragma mark custom methods, logic
-(void)showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator
{
	[[self navigationItem] setRightBarButtonItem:self.refreshButton];
}

-(void)refresh
{
    self.currentPage = 0;
    self.theSearchBar.text = self.searchText;
    [self performSearch:self.searchText];
}

- (void)refreshViewFromModel
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.currentPage == 0) self.gameList = [AppModel sharedAppModel].searchGameList;
    else self.gameList = [self.gameList arrayByAddingObjectsFromArray:[AppModel sharedAppModel].searchGameList];
    
    self.currentlyFetchingNextPage = NO;
    self.currentPage++;
    if([AppModel sharedAppModel].searchGameList.count == 0) self.allResultsFound = YES;
	[gameTable reloadData];
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.allResultsFound) return [self.gameList count];
    else return [self.gameList count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= [self.gameList count])
    {
        if(!self.currentlyFetchingNextPage && !self.allResultsFound) {
            [self performSearch:self.searchText];
        }
        static NSString *CellIdentifier = @"FetchCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        if(!self.allResultsFound) cell.textLabel.text = NSLocalizedString(@"GamePickerSearchLoadingMoreKey", @"");
        else cell.textLabel.text = NSLocalizedString(@"GamePickerSearchNoMoreKey", @"");
        return cell;
    }
    
	static NSString *CellIdentifier = @"Cell";
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		// Create a temporary UIViewController to instantiate the custom cell.
		UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"GamePickerCell" bundle:nil];
		// Grab a pointer to the custom cell.
		cell = (GamePickerCell *)temporaryController.view;
		// Release the temporary UIViewController.
        cell.starView.backgroundColor = [UIColor clearColor];
        
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"]
                           forState:kSCRatingViewHalfSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                           forState:kSCRatingViewHighlighted];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                           forState:kSCRatingViewHot];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]
                           forState:kSCRatingViewNonSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]
                           forState:kSCRatingViewSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]
                           forState:kSCRatingViewUserSelected];
    }
	Game *currentGame = [self.gameList objectAtIndex:indexPath.row];
    
	cell.titleLabel.text = currentGame.name;
	double dist = currentGame.distanceFromPlayer;
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"km", @"") ];
	cell.authorLabel.text = currentGame.authors;
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumber numberWithInt:currentGame.numReviews] stringValue], NSLocalizedString(@"GamePickerRecentReviewsKey", @"")];
    cell.starView.rating = currentGame.rating;
    
    //Set up the Icon
    //Create a new iconView for each cell instead of reusing the same one
    AsyncMediaImageView *iconView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    if(currentGame.iconMedia.image){
        iconView.image = [UIImage imageWithData: currentGame.iconMedia.image];
    }
    else {
        if(!currentGame.iconMedia) iconView.image = [UIImage imageNamed:@"Icon.png"];
        else{
            [iconView loadImageFromMedia:currentGame.iconMedia];
        }
    }
    
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;
    
    //clear out icon view
    if([cell.iconView.subviews count]>0)
        [[cell.iconView.subviews objectAtIndex:0] removeFromSuperview];
    
    
    [cell.iconView addSubview: iconView];
    
        return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];  
    else                        cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //do select game notification;
    Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsViewController.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsViewController animated:YES];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	Game *selectedGame;
	selectedGame = [self.gameList objectAtIndex:indexPath.row];
	
	GameDetailsViewController *gameDetailsViewController = [[GameDetailsViewController alloc]initWithNibName:@"GameDetails" bundle:nil];
	gameDetailsViewController.game = selectedGame;
	[self.navigationController pushViewController:gameDetailsViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

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
    self.searchText = searchBar.text;
	
    [self searchBar:searchBar activate:NO];
    self.currentPage = 0;
    [self performSearch:self.searchText];
}

- (void)performSearch:(NSString *)text
{
    if(self.searchText == nil || [self.searchText isEqualToString:@""]) return;
        
    [[AppServices sharedAppServices] fetchGameListBySearch: [text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] onPage: self.currentPage];
    self.currentlyFetchingNextPage = YES;
    self.allResultsFound = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"RecievedGameList"       object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewSearchGameListReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"         object:nil];
    
	[self showLoadingIndicator];
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL)active
{
    self.gameTable.allowsSelection = !active;
    self.gameTable.scrollEnabled = !active;
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

@end

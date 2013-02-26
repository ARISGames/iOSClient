//
//  GamePickerViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/26/13.
//
//

#import "GamePickerViewController.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISAppDelegate.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#include <QuartzCore/QuartzCore.h>
#include "AsyncMediaImageView.h"


@interface GamePickerViewController ()

@end

@implementation GamePickerViewController

@synthesize gameList;
@synthesize gameTable;
@synthesize refreshButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh)                name:@"PlayerMoved" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
  	[self.gameTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	//[self requestNewGameList];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.gameList count] == 0 && [AppModel sharedAppModel].playerLocation) return 1;
	return [self.gameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if([self.gameList count] == 0){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"GamePickerNoGamesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"GamePickerMakeOneGameKey", @"");
        return cell;
    }
    
    UITableViewCell *tempCell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (![tempCell respondsToSelector:@selector(starView)])
        tempCell = nil;
    GamePickerCell *cell = (GamePickerCell *)tempCell;
    if (cell == nil)
    {
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
	cell.distanceLabel.text = [NSString stringWithFormat:@"%1.1f %@",  dist/1000, NSLocalizedString(@"km", @"")];
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
    if([self.gameList count] == 0)
        return;
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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

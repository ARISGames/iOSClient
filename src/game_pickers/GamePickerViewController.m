//
//  GamePickerViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/26/13.
//
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "ARISMediaView.h"
#import "UIColor+ARISColors.h"

@interface GamePickerViewController () <ARISMediaViewDelegate>
{
}

@end

@implementation GamePickerViewController

@synthesize gameList;
@synthesize gameTable;
@synthesize refreshControl;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        
        gameList = [[NSArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFirstMoved)       name:@"PlayerMoved"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"  object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorRed];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.gameTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.gameTable.contentInset = UIEdgeInsetsMake(64,0,49,0);
    self.gameTable.delegate = self;
    self.gameTable.dataSource = self;
    [self.view addSubview:self.gameTable];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.gameTable addSubview:refreshControl];
    
  	[self.gameTable reloadData];
    if([AppModel sharedAppModel].player.location) [self playerFirstMoved];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self requestNewGameList];
}

- (void) playerFirstMoved
{
    //Only want auto-refresh on first established location
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PlayerMoved" object:nil];
    [self requestNewGameList];
}

- (void) clearList
{
    self.gameList = [[NSArray alloc] init];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) refreshView:(UIRefreshControl *)refresh
{
    [self requestNewGameList];
}

- (void) requestNewGameList
{
    
}

- (void) refreshViewFromModel
{
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.gameList count] == 0 && [AppModel sharedAppModel].player.location) return 1;
	return [self.gameList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.gameList count] == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.text = NSLocalizedString(@"GamePickerNoGamesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"GamePickerMakeOneGameKey", @"");
        return cell;
    }
    
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(![cell respondsToSelector:@selector(starView)]) cell = nil;
    
    if(cell == nil)
    {
		cell = (GamePickerCell *)[[UIViewController alloc] initWithNibName:@"GamePickerCell" bundle:nil].view;
        cell.starView.backgroundColor = [UIColor clearColor];
        
        
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"] forState:kSCRatingViewHighlighted];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewHot];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"] forState:kSCRatingViewNonSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]    forState:kSCRatingViewUserSelected];
    }
    
	Game *gameForCell = [self.gameList objectAtIndex:indexPath.row];
    
	cell.titleLabel.text      = gameForCell.name;
    [cell.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    
	cell.authorLabel.text     = gameForCell.authors;
    [cell.authorLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    
    cell.starView.rating      = gameForCell.rating;
    
    cell.distanceLabel.text   = [NSString stringWithFormat:@"%1.1f %@", gameForCell.distanceFromPlayer/1000, NSLocalizedString(@"km", @"")];
    [cell.distanceLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumber numberWithInt:gameForCell.numReviews] stringValue], NSLocalizedString(@"GamePickerReviewsKey", @"")];
    [cell.numReviewsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    
    ARISMediaView *iconView = [[ARISMediaView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;
    
    if(!gameForCell.iconMedia) [iconView refreshWithFrame:iconView.frame image:[UIImage imageNamed:@"icon.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
    else                       [iconView refreshWithFrame:iconView.frame media:gameForCell.iconMedia            mode:ARISMediaDisplayModeAspectFill delegate:self];
    
    if([cell.iconView.subviews count] > 0) [[cell.iconView.subviews objectAtIndex:0] removeFromSuperview];
    [cell.iconView addSubview: iconView];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.gameList count] == 0) return;
    [delegate gamePicked:[self.gameList objectAtIndex:indexPath.row]];
}

- (void) tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [delegate gamePicked:[self.gameList objectAtIndex:indexPath.row]];
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) showLoadingIndicator
{
	[self.refreshControl beginRefreshing];
}

- (void) removeLoadingIndicator
{
    [self.refreshControl endRefreshing];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
}

- (NSUInteger) supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

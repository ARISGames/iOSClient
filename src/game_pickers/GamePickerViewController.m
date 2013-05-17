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
#import "AsyncMediaImageView.h"

@interface GamePickerViewController ()

@end

@implementation GamePickerViewController

@synthesize gameList;
@synthesize gameTable;
@synthesize refreshButton;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        [self initialize];
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        delegate = d;
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    gameList = [[NSArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFirstMoved)       name:@"PlayerMoved"     object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearList)              name:@"LogoutRequested" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"  object:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(requestNewGameList)];
    self.navigationItem.leftBarButtonItem = self.refreshButton;
    
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"123-id-card-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(accountButtonTouched)];
	self.navigationItem.rightBarButtonItem = accountButton;
    
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

- (void)requestNewGameList
{
    
}

- (void)refreshViewFromModel
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.gameList count] == 0 && [AppModel sharedAppModel].player.location) return 1;
	return [self.gameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.gameList count] == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.text = NSLocalizedString(@"GamePickerNoGamesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"GamePickerMakeOneGameKey", @"");
        return cell;
    }
    
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (![cell respondsToSelector:@selector(starView)]) cell = nil;
    
    if (cell == nil)
    {
		cell = (GamePickerCell *)[[UIViewController alloc] initWithNibName:@"GamePickerCell" bundle:nil].view;
        cell.starView.backgroundColor = [UIColor clearColor];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-halfselected.png"] forState:kSCRatingViewHalfSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]  forState:kSCRatingViewHighlighted];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]          forState:kSCRatingViewHot];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-highlighted.png"]  forState:kSCRatingViewNonSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-selected.png"]     forState:kSCRatingViewSelected];
        [cell.starView setStarImage:[UIImage imageNamed:@"small-star-hot.png"]          forState:kSCRatingViewUserSelected];
    }
    
	Game *gameForCell = [self.gameList objectAtIndex:indexPath.row];
    
	cell.titleLabel.text      = gameForCell.name;
	cell.authorLabel.text     = gameForCell.authors;
    cell.starView.rating      = gameForCell.rating;
    cell.distanceLabel.text   = [NSString stringWithFormat:@"%1.1f %@", gameForCell.distanceFromPlayer/1000, NSLocalizedString(@"km", @"")];
	cell.numReviewsLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumber numberWithInt:gameForCell.numReviews] stringValue], NSLocalizedString(@"GamePickerRecentReviewsKey", @"")];
    
    AsyncMediaImageView *iconView = [[AsyncMediaImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;
    
    if(gameForCell.iconMedia.image) iconView.image = [UIImage imageWithData: gameForCell.iconMedia.image];
    else if(!gameForCell.iconMedia) iconView.image = [UIImage imageNamed:@"Icon.png"];
    else                            [iconView loadMedia:gameForCell.iconMedia];
    
    if([cell.iconView.subviews count] > 0) [[cell.iconView.subviews objectAtIndex:0] removeFromSuperview];
    [cell.iconView addSubview: iconView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];
    else                       cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.gameList count] == 0) return;

    [delegate gamePicked:[self.gameList objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [delegate gamePicked:[self.gameList objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void)showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[self navigationItem].leftBarButtonItem = barButton;
	[activityIndicator startAnimating];
}

- (void)removeLoadingIndicator
{
	[self navigationItem].leftBarButtonItem = self.refreshButton;
}

- (void) accountButtonTouched
{
    [delegate accountSettingsRequested];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

-(NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

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
#import "User.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "ARISMediaView.h"
#import "ARISTemplate.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFirstMoved)       name:@"UserMoved"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost"  object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorRed];
    
    self.gameTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain]; 
    self.gameTable.delegate = self;
    self.gameTable.dataSource = self; 
    [self.view addSubview:self.gameTable]; 
    
    self.refreshControl = [[UIRefreshControl alloc] init]; 
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    [self.gameTable reloadData];
    if([AppModel sharedAppModel].player.location) [self playerFirstMoved]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //These next four lines are required in precise order for this to work. apple. c'mon.
    self.gameTable.frame = self.view.bounds;
    self.gameTable.contentInset = UIEdgeInsetsMake(64,0,49,0);
    [self.gameTable setContentOffset:CGPointMake(0,-64)];
    [self.gameTable addSubview:refreshControl];  
    
    [self.gameTable reloadData]; 
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self requestNewGameList];
}

- (void) playerFirstMoved
{
    //Only want auto-refresh on first established location
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserMoved" object:nil];
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
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OffCell"];
        cell.textLabel.text = NSLocalizedString(@"GamePickerNoGamesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"GamePickerMakeOneGameKey", @"");
        return cell;
    }
    
    GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:@"GameCell"];
    if(cell == nil) cell = [[GamePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameCell"];
    
	[cell setGame:[self.gameList objectAtIndex:indexPath.row]];
    
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

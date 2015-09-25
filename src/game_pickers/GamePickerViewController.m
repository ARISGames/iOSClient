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
#import "Game.h"
#import "GamePickerCell.h"
#import "ARISMediaView.h"

@interface GamePickerViewController () <ARISMediaViewDelegate>
{
}

@end

@implementation GamePickerViewController

@synthesize gameTable;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
  }
  return self;
}

- (void) loadView
{
  [super loadView];

  self.view.backgroundColor = [UIColor ARISColorRed];

  gameTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  gameTable.delegate = self;
  gameTable.dataSource = self;
  [self.view addSubview:gameTable];

  refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  //These next four lines are required in precise order for this to work. apple. c'mon.
  gameTable.frame = self.view.bounds;
  gameTable.contentInset = UIEdgeInsetsMake(64,0,49,0);
  [gameTable setContentOffset:CGPointMake(0,-64)];
  [gameTable addSubview:refreshControl];

  [gameTable reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  /*APPLE STOP TRYING TO FIX THINGS*/
  gameTable.frame = self.view.bounds;
  gameTable.contentInset = UIEdgeInsetsMake(64,0,49,0);
  [gameTable setContentOffset:CGPointMake(0,-64)];

  [self refreshViewFromModel];
}

- (void) refreshView:(UIRefreshControl *)refresh
{
  [self refreshViewFromModel];
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
  if(games.count == 0 && _MODEL_PLAYER_.location) return 1;
  return games.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(games.count == 0)
  {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"OffCell"];
    cell.textLabel.text = NSLocalizedString(@"GamePickerNoGamesKey", @"");
    cell.detailTextLabel.text = NSLocalizedString(@"GamePickerMakeOneGameKey", @"");
    return cell;
  }

  GamePickerCell *cell = (GamePickerCell *)[tableView dequeueReusableCellWithIdentifier:@"GameCell"];
  if(cell == nil) cell = [[GamePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameCell"];

  [cell setGame:[games objectAtIndex:indexPath.row]];

  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(games.count == 0) return;
  [delegate gamePicked:games[indexPath.row] downloaded:NO];
}

- (void) tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
  if(games.count == 0) return;
  [delegate gamePicked:games[indexPath.row] downloaded:NO];
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60;
}

- (void) showLoadingIndicator
{
  [refreshControl beginRefreshing];
}

- (void) removeLoadingIndicator
{
  [refreshControl endRefreshing];
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
  if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    return UIInterfaceOrientationMaskAll;
  else
    return UIInterfaceOrientationMaskPortrait;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

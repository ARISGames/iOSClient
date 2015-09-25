//
//  GamePickerDownloadedViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerDownloadedViewController.h"
#import "AppModel.h"

@implementation GamePickerDownloadedViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
  if(self = [super initWithDelegate:d])
  {
    self.title = NSLocalizedString(@"GamePickerDownloadedTabKey", @"");

    [self.tabBarItem setImage:[[UIImage imageNamed:@"clock.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"clock_red.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    _ARIS_NOTIF_LISTEN_(@"MODEL_DOWNLOADED_GAMES_AVAILABLE",self,@selector(downloadedGamesAvailable),nil);
  }
  return self;
}

- (void) downloadedGamesAvailable
{
  [self removeLoadingIndicator];
  games = _MODEL_GAMES_.downloadedGames;
  [gameTable reloadData];
}

- (void) refreshViewFromModel
{
  games = _MODEL_GAMES_.pingDownloadedGames;
  [gameTable reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(games.count == 0) return;
  [delegate gamePicked:games[indexPath.row] downloaded:YES];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

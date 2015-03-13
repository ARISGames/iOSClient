//
//  GamePickerMineViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerMineViewController.h"
#import "AppModel.h"

@implementation GamePickerMineViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
  if(self = [super initWithDelegate:d])
  {
    self.title = NSLocalizedString(@"GamePickerMineTabKey", @"");

    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"clock_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"clock.png"]];
    _ARIS_NOTIF_LISTEN_(@"MODEL_MINE_GAMES_AVAILABLE",self,@selector(mineGamesAvailable),nil);
  }
  return self;
}

- (void) mineGamesAvailable
{
  [self removeLoadingIndicator];
  games = _MODEL_GAMES_.mineGames;
  [gameTable reloadData];
}

- (void) refreshViewFromModel
{
  games = _MODEL_GAMES_.pingMineGames;
  [gameTable reloadData];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

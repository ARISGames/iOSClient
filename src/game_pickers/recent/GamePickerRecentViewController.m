//
//  GamePickerRecentViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerRecentViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "User.h"
#import "Location.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "UIColor+ARISColors.h"

@implementation GamePickerRecentViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerRecentTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"clock_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"clock.png"]];   
  _ARIS_NOTIF_LISTEN_(@"NewRecentGameListReady",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if(_MODEL_.deviceLocation && _MODEL_PLAYER_)
    {
        //[_SERVICES_ fetchRecentGameListForPlayer];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	gameList = _MODEL_GAMES_.recentGames;
	[self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

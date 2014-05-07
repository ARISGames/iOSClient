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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewRecentGameListReady" object:nil];
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if(_MODEL_.deviceLocation && _MODEL_PLAYER_)
    {
        [[AppServices sharedAppServices] fetchRecentGameListForPlayer];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = _MODEL_.recentGameList;
	[self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

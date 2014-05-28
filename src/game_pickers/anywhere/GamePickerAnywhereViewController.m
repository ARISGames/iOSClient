//
//  GamePickerAnywhereViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerAnywhereViewController.h"
#import "AppModel.h"

@implementation GamePickerAnywhereViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerAnywhereTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"globe_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"globe.png"]];
        
  _ARIS_NOTIF_LISTEN_(@"MODEL_ANYWHERE_GAMES_AVAILABLE",self,@selector(anywhereGamesAvailable),nil);
    }
    return self;
}

- (void) anywhereGamesAvailable
{
    [self removeLoadingIndicator];
    [self refreshViewFromModel];
}
- (void) refreshViewFromModel
{
	gameList = _MODEL_GAMES_.anywhereGames;
    [gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);      
}

@end

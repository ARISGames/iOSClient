//
//  GamePickerNearbyViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerNearbyViewController.h"
#import "AppModel.h"

@implementation GamePickerNearbyViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"locationarrow_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"locationarrow.png"]]; 
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_NEARBY_GAMES_AVAILABLE",self,@selector(nearbyGamesAvailable),nil);
    }
    return self;
}

- (void) nearbyGamesAvailable
{
    [self removeLoadingIndicator]; 
    [self refreshViewFromModel];
}
- (void) refreshViewFromModel
{
	gameList = _MODEL_GAMES_.nearbyGames;
    [gameTable reloadData];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

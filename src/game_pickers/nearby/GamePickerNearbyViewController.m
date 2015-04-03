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
        [self.tabBarItem setImage:[[UIImage imageNamed:@"locationarrow.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"locationarrow_red.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        _ARIS_NOTIF_LISTEN_(@"MODEL_NEARBY_GAMES_AVAILABLE",self,@selector(nearbyGamesAvailable),nil);
    }
    return self;
}

- (void) nearbyGamesAvailable
{
    [self removeLoadingIndicator];
	games = _MODEL_GAMES_.nearbyGames;
    [gameTable reloadData];
}
- (void) refreshViewFromModel
{
	games = _MODEL_GAMES_.pingNearbyGames;
    [gameTable reloadData];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);       
}

@end

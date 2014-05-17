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
#import "AppServices.h"
#import "Game.h"
#import "User.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "UIColor+ARISColors.h"

@implementation GamePickerNearbyViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"locationarrow_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"locationarrow.png"]]; 
        
        _ARIS_NOTIF_LISTEN_(@"NewNearbyGameListReady",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if(_MODEL_.deviceLocation && _MODEL_PLAYER_)  
    {
        [_SERVICES_ fetchNearbyGameListWithDistanceFilter:1000];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = [_MODEL_.nearbyGameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

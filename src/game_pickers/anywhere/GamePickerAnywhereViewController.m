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
#import "AppServices.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "User.h"
#import "UIColor+ARISColors.h"

@implementation GamePickerAnywhereViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerAnywhereTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"globe_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"globe.png"]];
        
  _ARIS_NOTIF_LISTEN_(@"NewAnywhereGameListReady",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if(_MODEL_.deviceLocation && _MODEL_PLAYER_) 
    {
        [_SERVICES_ fetchAnywhereGameList];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = [_MODEL_.anywhereGameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

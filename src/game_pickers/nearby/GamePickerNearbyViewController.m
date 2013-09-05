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
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"

@implementation GamePickerNearbyViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"arrow_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"arrow_unselected"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNearbyGameListReady" object:nil];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self resizeSelf];
}

//This pickervc uniquely fails to size itself appropriately. Since it is first in the tabvc, it alone 'knows' it is
//in a navigationvc. because of this, it will automatically add the offset in the table behind the nav bar. however,
//since none of the other pickervc's are aware of this, they need to have their offsets manually set. in the case of
//this pickervc, it will do its automatic offset AND the adjusted offset. So, rather than add code to 'all vcs except
//the first one, I'm adding code to the first one to adjust for its multiple adjustments to JUST the first vc. -Phil
- (void) resizeSelf
{
    [self.gameTable setContentInset:UIEdgeInsetsMake(64,0,49,0)];
    self.gameTable.frame = self.view.bounds;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchNearbyGameListWithDistanceFilter:1000];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = [[AppModel sharedAppModel].nearbyGameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) removeLoadingIndicator
{
    [super removeLoadingIndicator];
    [self resizeSelf];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

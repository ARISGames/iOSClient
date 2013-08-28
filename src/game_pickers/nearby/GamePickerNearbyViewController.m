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
    if(self = [super initWithNibName:@"GamePickerNearbyViewController" bundle:nil delegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"arrow_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"arrow_unselected"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNearbyGameListReady" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat: @"%@", NSLocalizedString(@"GamePickerNearbyTitleKey", @"")];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
    } else {
        // Load resources for iOS 7 or later
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
    }
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

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

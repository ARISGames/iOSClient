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
#import "Player.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "UIImage+Resize.h"
#import "UIImage+Color.h"
#import "UIColor+ARISColors.h"

@implementation GamePickerNearbyViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"arrow_unselected.png" withColor:[UIColor ARISColorRed]] resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationHigh] withFinishedUnselectedImage:[[UIImage imageNamed:@"arrow_unselected.png" withColor:[UIColor ARISColorDarkGray]] resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationHigh]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNearbyGameListReady" object:nil];
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].deviceLocation && [AppModel sharedAppModel].player)  
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

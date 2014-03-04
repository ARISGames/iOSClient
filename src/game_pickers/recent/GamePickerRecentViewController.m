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
#import "Player.h"
#import "Location.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "UIImage+Resize.h"
#import "UIColor+ARISColors.h"
#import "UIImage+Color.h"

@implementation GamePickerRecentViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerRecentTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[[UIImage imageNamed:@"728-clock.png" withColor:[UIColor ARISColorRed]] resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationHigh] withFinishedUnselectedImage:[[UIImage imageNamed:@"728-clock.png" withColor:[UIColor ARISColorDarkGray]] resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationHigh]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewRecentGameListReady" object:nil];
    }
    return self;
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].deviceLocation && [AppModel sharedAppModel].player)
    {
        [[AppServices sharedAppServices] fetchRecentGameListForPlayer];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = [AppModel sharedAppModel].recentGameList;
	[self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

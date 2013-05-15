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
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "AsyncMediaImageView.h"

@implementation GamePickerRecentViewController

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GamePickerRecentViewController" bundle:nil delegate:d])
    {
        self.title = NSLocalizedString(@"GamePickerRecentTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"78-stopwatch"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewRecentGameListReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationItem.title = NSLocalizedString(@"GamePickeRecentPlayedKey", @"");
}

- (void)requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchRecentGameListForPlayer];
        [self showLoadingIndicator];
    }
}

- (void)refreshViewFromModel
{
    
	self.gameList = [AppModel sharedAppModel].recentGameList;
	[gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

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

@synthesize distanceControl;

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GamePickerNearbyViewController" bundle:nil delegate:d])
    {
        distanceFilter = 1000;
        
        self.title = NSLocalizedString(@"GamePickerNearbyTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"locationArrowTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"locationArrowTabBarSelected"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewNearbyGameListReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat: @"%@", NSLocalizedString(@"GamePickerNearbyTitleKey", @"")];
    
    self.distanceControl.enabled = YES;
    self.distanceControl.alpha   = 1;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
    } else {
        // Load resources for iOS 7 or later
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
}

- (void)requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchNearbyGameListWithDistanceFilter:distanceFilter];
        [self showLoadingIndicator];
    }
}

- (void)refreshViewFromModel
{
	self.gameList = [[AppModel sharedAppModel].nearbyGameList sortedArrayUsingSelector:@selector(compareCalculatedScore:)];
    [self.gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (IBAction)controlChanged:(id)sender
{    
    switch (self.distanceControl.selectedSegmentIndex)
    {
        case 0: distanceFilter = 100;   break;
        case 1: distanceFilter = 1000;  break;
        case 2: distanceFilter = 50000; break;
    }
    
    [self requestNewGameList];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

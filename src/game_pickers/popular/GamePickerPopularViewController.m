//
//  GamePickerPopularViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerPopularViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "GameDetailsViewController.h"
#import "GamePickerCell.h"
#import "AsyncMediaImageView.h"

@implementation GamePickerPopularViewController

@synthesize timeControl;

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"GamePickerPopularViewController" bundle:nil delegate:d])
    {
        time = 1;
        
        self.title = NSLocalizedString(@"GamePickerPopularTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"85-trophy"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewPopularGameListReady" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationItem.title = NSLocalizedString(@"GamePickerPopularPlayedKey", @"");
    
    self.timeControl.enabled = YES;
    self.timeControl.alpha = 1;
}

- (void)requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchPopularGameListForTime:time];
        [self showLoadingIndicator];
    }
}

- (void)refreshViewFromModel
{
	self.gameList = [AppModel sharedAppModel].popularGameList;
	[gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (IBAction)controlChanged:(id)sender
{
    time = self.timeControl.selectedSegmentIndex;
    [self requestNewGameList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GamePickerCell *cell = (GamePickerCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if([self.gameList count] > 0)
    {
        Game *gameForCell = [self.gameList objectAtIndex:indexPath.row];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%d Players",gameForCell.playerCount];
    }
    return cell;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

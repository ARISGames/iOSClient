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

@interface GamePickerPopularViewController()
{
    int time;
    UISegmentedControl *timeControl;
}
@property (nonatomic, strong) UISegmentedControl *timeControl;
@end
    
@implementation GamePickerPopularViewController

@synthesize timeControl;

- (id)initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        time = 1;
        
        self.title = NSLocalizedString(@"GamePickerPopularTabKey", @"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"star_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"star_unselected"]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel) name:@"NewPopularGameListReady" object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"GamePickerPopularTitleKey", @"");
    self.timeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Daily",@"Weekly",@"Monthly", nil]];
    self.timeControl.frame = CGRectMake(0, 0, self.view.bounds.size.width, 30);
    self.timeControl.selectedSegmentIndex = 1;
    [self.timeControl addTarget:self action:@selector(controlChanged) forControlEvents:UIControlEventValueChanged];
}

- (void) requestNewGameList
{
    [super requestNewGameList];
    
    if([AppModel sharedAppModel].player.location && [[AppModel sharedAppModel] player])
    {
        [[AppServices sharedAppServices] fetchPopularGameListForTime:time];
        [self showLoadingIndicator];
    }
}

- (void) refreshViewFromModel
{
	self.gameList = [AppModel sharedAppModel].popularGameList;
	[gameTable reloadData];
    
    [self removeLoadingIndicator];
}

- (void) controlChanged
{
    time = self.timeControl.selectedSegmentIndex;
    [self requestNewGameList];
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 30;
    else return 60;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section]+1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SegCell"];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegCell"];
        [cell addSubview:self.timeControl];
        return cell;
    }
    else if([self.gameList count] > 0)
    {
        GamePickerCell *cell = (GamePickerCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
        Game *gameForCell = [self.gameList objectAtIndex:(indexPath.row-1)];
        cell.distanceLabel.text = [NSString stringWithFormat:@"%d Players",gameForCell.playerCount];
        return cell;
    }
    else
        return (GamePickerCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

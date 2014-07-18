//
//  GamePickerPopularViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "GamePickerPopularViewController.h"
#import "GamePickerCell.h"
#import "AppModel.h"

@interface GamePickerPopularViewController()
{
    int time;
    UISegmentedControl *timeControl;
}
@end
    
@implementation GamePickerPopularViewController

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        time = 1;
        
        self.title = NSLocalizedString(@"GamePickerPopularTabKey", @"");
        
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"star_red.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"star.png"]];  

  _ARIS_NOTIF_LISTEN_(@"MODEL_POPULAR_GAMES_AVAILABLE",self,@selector(popularGamesAvailable),nil);
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    timeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"GamePickerDailyKey", @""),NSLocalizedString(@"GamePickerWeeklyKey", @""),NSLocalizedString(@"GamePickerMonthlyKey", @""), nil]];
    timeControl.frame = CGRectMake(5, 5, self.view.bounds.size.width-10, 30);
    timeControl.selectedSegmentIndex = time;
    timeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [timeControl addTarget:self action:@selector(controlChanged) forControlEvents:UIControlEventValueChanged];
}

- (void) popularGamesAvailable
{
    [self removeLoadingIndicator];
	games = _MODEL_GAMES_.popularGames;
	[gameTable reloadData];
}

- (void) refreshViewFromModel
{
	games = _MODEL_GAMES_.pingPopularGames;
	[gameTable reloadData];
}

- (void) controlChanged
{
    time = timeControl.selectedSegmentIndex;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) return 40;
    else return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
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
        if(!cell)        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegCell"];
        [cell addSubview:timeControl];
        return cell;
    }
    else if(games.count > 0)
    {
        GamePickerCell *cell = (GamePickerCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
        Game *gameForCell = [games objectAtIndex:(indexPath.row-1)];
        [cell setCustomLabelText:[NSString stringWithFormat:@"%d %@",gameForCell.player_count, NSLocalizedString(@"PlayersKey", @"")]];
        return cell;
    }
    else
        return (GamePickerCell *)[super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);        
}

@end

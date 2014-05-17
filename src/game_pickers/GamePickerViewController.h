//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/26/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Game;

@protocol GamePickerViewControllerDelegate
@end

@interface GamePickerViewController : ARISViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *gameTable;
    UIRefreshControl *refreshControl;
    
    NSArray *gameList;
    id<GamePickerViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UITableView *gameTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d;
- (void) clearList;
- (void) requestNewGameList;
- (void) showLoadingIndicator;
- (void) removeLoadingIndicator;

@end

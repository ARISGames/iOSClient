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
- (void) gamePicked:(Game *)g;
@end

@interface GamePickerViewController : ARISViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSArray *gameList;
	UITableView *gameTable;
    UIRefreshControl *refreshControl;
    
    id<GamePickerViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, copy)   NSArray *gameList;
@property (nonatomic, strong) UITableView *gameTable;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d;
- (void) clearList;
- (void) requestNewGameList;
- (void) refreshViewFromModel;
- (void) showLoadingIndicator;
- (void) removeLoadingIndicator;

@end

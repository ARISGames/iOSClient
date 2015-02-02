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
	UITableView *gameTable;
    UIRefreshControl *refreshControl;
    
    NSArray *games;
    id<GamePickerViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) UITableView *gameTable;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d;
- (void) refreshViewFromModel;
- (void) showLoadingIndicator;
- (void) removeLoadingIndicator;

@end

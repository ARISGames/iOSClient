//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/26/13.
//
//

#import <UIKit/UIKit.h>

@class Game;

@protocol GamePickerViewControllerDelegate
- (void) gamePicked:(Game *)g;
- (void) accountSettingsRequested;
@end

@interface GamePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSArray *gameList;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
    
    id<GamePickerViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, copy)   NSArray *gameList;
@property (nonatomic, strong) IBOutlet UITableView *gameTable;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;

- (id) initWithDelegate:(id<GamePickerViewControllerDelegate>)d;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<GamePickerViewControllerDelegate>)d;
- (void) requestNewGameList;
- (void) refreshViewFromModel;
- (void) showLoadingIndicator;
- (void) removeLoadingIndicator;
- (void) accountButtonTouched;

@end

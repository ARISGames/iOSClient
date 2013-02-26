//
//  GamePickerViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/26/13.
//
//

#import <UIKit/UIKit.h>

@interface GamePickerViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
	NSArray *gameList;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(void)refreshViewFromModel;

@property (nonatomic, copy)   NSArray *gameList;
@property (nonatomic, strong) IBOutlet UITableView *gameTable;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *refreshButton;

@end

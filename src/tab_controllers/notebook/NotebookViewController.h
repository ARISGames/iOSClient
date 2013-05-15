//
//  NotebookViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"
#import "Comment.h"

@protocol NotebookViewControllerDelegate <GamePlayTabBarViewControllerDelegate>

@end

@interface NotebookViewController : ARISGamePlayTabBarViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *noteList;
    NSMutableArray *gameNoteList;
    NSMutableArray *tagList;
    NSMutableArray *tagNoteList;
    NSMutableArray *tagGameNoteList;
    NSMutableArray *headerTitleList;
    NSMutableArray *headerTitleGameList;

    IBOutlet UISegmentedControl *filterControl,*sortControl;
	UITableView *noteTable;
    NSInteger count;
    BOOL textIconUsed, photoIconUsed, videoIconUsed, audioIconUsed;

    IBOutlet UIToolbar *toolBar, *filterToolBar, *sortToolBar;
 
    BOOL isGameList;
}

@property (nonatomic, strong) NSMutableArray *noteList;
@property (nonatomic, strong) NSMutableArray *gameNoteList;
@property (nonatomic, strong) NSMutableArray *tagList;
@property (nonatomic, strong) NSMutableArray *tagNoteList;
@property (nonatomic, strong) NSMutableArray *tagGameNoteList;
@property (nonatomic, strong) NSMutableArray *headerTitleList;
@property (nonatomic, strong) NSMutableArray *headerTitleGameList;

@property (nonatomic, strong) IBOutlet UITableView *noteTable;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIToolbar *filterToolBar;
@property (nonatomic, strong) IBOutlet UIToolbar *sortToolBar;

@property (nonatomic, assign) BOOL textIconUsed;
@property (nonatomic, assign) BOOL photoIconUsed;
@property (nonatomic, assign) BOOL audioIconUsed;
@property (nonatomic, assign) BOOL videoIconUsed;
@property (nonatomic, assign) BOOL isGameList;

@property (nonatomic, strong) IBOutlet UISegmentedControl *filterControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *sortControl;

- (id) initWithDelegate:(id<NotebookViewControllerDelegate>)d;
- (void) refresh;
- (void) showLoadingIndicator;
- (void) refreshViewFromModel;
- (void) displayMenu;
- (IBAction) filterButtonTouchAction:(id)sender;
- (IBAction) sortButtonTouchAction:(id)sender;
- (IBAction) barButtonTouchAction:(id)sender;

@end

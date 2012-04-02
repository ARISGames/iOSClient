//
//  NotebookViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Comment.h"


@interface NotebookViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
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

-(void)refresh;
-(void)showLoadingIndicator;
-(void)refreshViewFromModel;
@property (nonatomic) NSMutableArray *noteList;
@property (nonatomic) NSMutableArray *gameNoteList;
@property (nonatomic) NSMutableArray *tagList;
@property (nonatomic) NSMutableArray *tagNoteList;
@property (nonatomic) NSMutableArray *tagGameNoteList;
@property (nonatomic) NSMutableArray *headerTitleList;
@property (nonatomic) NSMutableArray *headerTitleGameList;




@property (nonatomic) IBOutlet UITableView *noteTable;

@property(nonatomic)IBOutlet UIToolbar *toolBar;
@property(nonatomic)IBOutlet UIToolbar *filterToolBar;
@property(nonatomic)IBOutlet UIToolbar *sortToolBar;


@property(readwrite,assign)BOOL textIconUsed;
@property(readwrite,assign)BOOL photoIconUsed;
@property(readwrite,assign)BOOL audioIconUsed;
@property(readwrite,assign)BOOL videoIconUsed;
@property(readwrite,assign)BOOL isGameList;


@property(nonatomic)IBOutlet UISegmentedControl *filterControl;
@property(nonatomic)IBOutlet UISegmentedControl *sortControl;

-(void)displayMenu;
-(IBAction)filterButtonTouchAction:(id)sender;
-(IBAction)sortButtonTouchAction:(id)sender;
-(IBAction)barButtonTouchAction:(id)sender;

@end

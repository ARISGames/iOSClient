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



    IBOutlet UIView *menuView;
    IBOutlet UIButton *mineButton,*sharedButton,*popularButton,*tagButton,*dateButton,*abcButton;
    IBOutlet UISegmentedControl *noteControl;
	UITableView *noteTable;
    NSInteger count;
    BOOL textIconUsed, photoIconUsed, videoIconUsed, audioIconUsed;
    IBOutlet UILabel *mineLbl,*sharedLbl,*popularLbl,*tagLbl;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *photoButton,*textButton,*audioButton;
    BOOL isGameList;
}

-(void)refresh;
-(void)showLoadingIndicator;
-(IBAction)controlChanged:(id)sender;
- (void)refreshViewFromModel;
-(void)addNote;
@property (nonatomic, retain) NSMutableArray *noteList;
@property (nonatomic, retain) NSMutableArray *gameNoteList;
@property (nonatomic, retain) NSMutableArray *tagList;
@property (nonatomic, retain) NSMutableArray *tagNoteList;
@property (nonatomic, retain) NSMutableArray *tagGameNoteList;
@property (nonatomic, retain) NSMutableArray *headerTitleList;
@property (nonatomic, retain) NSMutableArray *headerTitleGameList;




@property (nonatomic, retain) IBOutlet UITableView *noteTable;
@property(nonatomic, retain)IBOutlet UIButton *mineButton;
@property(nonatomic, retain)IBOutlet UIButton *sharedButton;
@property(nonatomic, retain)IBOutlet UIButton *popularButton;
@property(nonatomic, retain)IBOutlet UIButton *tagButton;
@property(nonatomic, retain)IBOutlet UIButton *dateButton;
@property(nonatomic, retain)IBOutlet UIButton *abcButton;
@property(nonatomic,retain)UIToolbar *toolBar;
@property(nonatomic,retain)UIBarButtonItem *photoButton;
@property(nonatomic,retain)UIBarButtonItem *textButton;
@property(nonatomic,retain)UIBarButtonItem *audioButton;

@property(nonatomic, retain)IBOutlet UIView *menuView;
@property(nonatomic,retain)IBOutlet UILabel *mineLbl;
@property(nonatomic,retain)IBOutlet UILabel *sharedLbl;
@property(nonatomic,retain)IBOutlet UILabel *popularLbl;
@property(nonatomic,retain)IBOutlet UILabel *tagLbl;
@property(nonatomic,retain)IBOutlet UILabel *dateLbl;
@property(nonatomic,retain)IBOutlet UILabel *abcLbl;

@property(readwrite,assign)BOOL textIconUsed;
@property(readwrite,assign)BOOL photoIconUsed;
@property(readwrite,assign)BOOL audioIconUsed;
@property(readwrite,assign)BOOL videoIconUsed;
@property(readwrite,assign)BOOL isGameList;


@property(nonatomic,retain)IBOutlet UISegmentedControl *noteControl;
-(void)displayMenu;
-(IBAction)filterButtonTouchAction:(id)sender;
-(IBAction)sortButtonTouchAction:(id)sender;
-(IBAction)barButtonTouchAction:(id)sender;

@end

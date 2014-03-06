//
//  NotebookViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookViewController.h"
#import "NoteViewController.h"
#import "NoteEditorViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppModel.h"
#import "Game.h"
#import "NoteCell.h"
#import "ARISTemplate.h"

const int VIEW_MODE_MINE = 0;
const int VIEW_MODE_ALL  = 1;

@interface NotebookViewController() <UITableViewDataSource, UITableViewDelegate, NoteCellDelegate, GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate>
{
    UITableView *table;
    
    UIView *navTitleView;
    UILabel *navTitleLabel;
    UIButton *dropdownButton; 
    UIButton *myNotesButton;
    UIButton *allNotesButton; 
    
    UIView *filterSelector;
    
    int viewMode;
    int loadingMore;
    
    NSMutableDictionary *contentLoadedFlagMap;
}

@end

@implementation NotebookViewController

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, NotebookViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        viewMode = 1;
        loadingMore = 1;
        self.tabID = @"NOTE"; 
        self.tabIconName = @"notebook";
        self.title = NSLocalizedString(@"NotebookTitleKey",@""); 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoteListAvailable) name:@"NewNoteListAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataAvailable:)   name:@"NoteDataAvailable"    object:nil];   
        contentLoadedFlagMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    navTitleView = [[UIView alloc] init];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.text = @"Notebook";
    navTitleLabel.textAlignment = NSTextAlignmentCenter; 
    
    dropdownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dropdownButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [dropdownButton addTarget:self action:@selector(dropDownButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [navTitleView addSubview:navTitleLabel];
    [navTitleView addSubview:dropdownButton]; 
    self.navigationItem.titleView = navTitleView;  
    
    filterSelector = [[UIView alloc] init];
    filterSelector.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    
    [filterSelector.layer setCornerRadius:15.0f];
    [filterSelector.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [filterSelector.layer setBorderWidth:1.0f];
    [filterSelector.layer setShadowColor:[UIColor blackColor].CGColor];
    [filterSelector.layer setShadowOpacity:0.8];
    [filterSelector.layer setShadowRadius:1.5];
    [filterSelector.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
       
    allNotesButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [allNotesButton setTitle:@"All" forState:UIControlStateNormal]; 
    [allNotesButton setTitleColor:[ARISTemplate ARISColorHighlightedText] forState:UIControlStateNormal]; 
    [allNotesButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    allNotesButton.titleLabel.textAlignment = NSTextAlignmentLeft;  
    [allNotesButton addTarget:self action:@selector(allNotesButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    myNotesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myNotesButton setTitle:@"Mine" forState:UIControlStateNormal];
    [myNotesButton setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal]; 
    [myNotesButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    myNotesButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [myNotesButton addTarget:self action:@selector(myNotesButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    [filterSelector addSubview:myNotesButton];
    [filterSelector addSubview:allNotesButton];
    
    table = [[UITableView alloc] initWithFrame:self.view.frame];
    table.delegate   = self;
    table.dataSource = self;
    [self.view addSubview:table];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    navTitleView.frame   = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
    navTitleLabel.frame  = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height); 
    dropdownButton.frame = CGRectMake(navTitleView.frame.size.width-30, 5,  30, 30); 
    filterSelector.frame = CGRectMake(navTitleView.frame.origin.x+20, 64, navTitleView.frame.size.width-40, 30);
    allNotesButton.frame = CGRectMake(0, 0, filterSelector.frame.size.width/2, 30); 
    myNotesButton.frame  = CGRectMake(filterSelector.frame.size.width/2, 0, filterSelector.frame.size.width/2, 30); 
       
    table.frame = self.view.frame;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIButton *plus = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [plus setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [plus addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside]; 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:plus]; 
    
    [table reloadData];
}

- (void) newNoteListAvailable
{
    [table reloadData]; 
}

- (void) noteDataAvailable:(NSNotification *)n
{
    Note *note = [n.userInfo objectForKey:@"note"];
    [contentLoadedFlagMap setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",note.noteId]];
    [table reloadData];  
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int) tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section
{
    if     (viewMode == VIEW_MODE_MINE) return [[[AppModel sharedAppModel].currentGame.notesModel playerNotes] count] + (1-[AppModel sharedAppModel].currentGame.notesModel.listComplete);
    else if(viewMode == VIEW_MODE_ALL)  return [[[AppModel sharedAppModel].currentGame.notesModel listNotes]   count] + (1-[AppModel sharedAppModel].currentGame.notesModel.listComplete);
    return 0;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *noteList;
    if     (viewMode == VIEW_MODE_MINE) noteList = [[AppModel sharedAppModel].currentGame.notesModel playerNotes];
    else if(viewMode == VIEW_MODE_ALL)  noteList = [[AppModel sharedAppModel].currentGame.notesModel listNotes]; 
    
    if(![AppModel sharedAppModel].currentGame.notesModel.listComplete && indexPath.row >= [noteList count])
    {
        [[AppModel sharedAppModel].currentGame.notesModel getNextNotes]; 
        UITableViewCell *cell;
        if(!(cell = [table dequeueReusableCellWithIdentifier:@"loadingCell"])) 
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingCell"];
        return cell;
    }
    
    NoteCell *cell;
    if(!(cell = (NoteCell *)[table dequeueReusableCellWithIdentifier:[NoteCell cellIdentifier]]))
        cell = [[NoteCell alloc] initWithDelegate:self]; 
    Note *n = [noteList objectAtIndex:indexPath.row];
    NSString *loaded = [contentLoadedFlagMap objectForKey:[NSString stringWithFormat:@"%d", n.noteId]];
    if(!loaded) [[AppModel sharedAppModel].currentGame.notesModel getDetailsForNote:n];   
    [cell populateWithNote:n loading:!loaded editable:(viewMode == VIEW_MODE_MINE)]; 

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *noteList;
    if     (viewMode == VIEW_MODE_MINE) noteList = [[AppModel sharedAppModel].currentGame.notesModel playerNotes];
    else if(viewMode == VIEW_MODE_ALL)  noteList = [[AppModel sharedAppModel].currentGame.notesModel listNotes];  
    
    NoteViewController *nvc = [[NoteViewController alloc] initWithNote:[noteList objectAtIndex:indexPath.row] delegate:self];
    [self.navigationController pushViewController:nvc animated:YES];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [self.navigationController popToViewController:self animated:YES];    
}

- (void) addNote
{
    NoteEditorViewController *nevc = [[NoteEditorViewController alloc] initWithNote:nil delegate:self];
    [self.navigationController pushViewController:nevc animated:YES]; 
}

- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n
{
    [[AppModel sharedAppModel].currentGame.notesModel clearData];   
    [[AppModel sharedAppModel].currentGame.notesModel getNextNotes];    
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) dropDownButtonTouched
{
    if(filterSelector.superview) [filterSelector removeFromSuperview];
    else                         [self.view addSubview:filterSelector];
}

- (void) allNotesButtonTouched
{
    viewMode = VIEW_MODE_ALL; 
    [allNotesButton setTitleColor:[ARISTemplate ARISColorHighlightedText] forState:UIControlStateNormal];
    [myNotesButton setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal]; 
    [table reloadData]; 
}

- (void) myNotesButtonTouched
{
    viewMode = VIEW_MODE_MINE;
    [allNotesButton setTitleColor:[ARISTemplate ARISColorText] forState:UIControlStateNormal];
    [myNotesButton setTitleColor:[ARISTemplate ARISColorHighlightedText] forState:UIControlStateNormal];  
    [table reloadData];
}

- (void) editRequestedForNote:(Note *)n
{
    NoteEditorViewController *nevc = [[NoteEditorViewController alloc] initWithNote:n delegate:self];
    [self.navigationController pushViewController:nevc animated:YES];  
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

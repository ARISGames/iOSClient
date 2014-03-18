//
//  NotebookNotesViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookNotesViewController.h"
#import "NoteViewController.h"
#import "NoteEditorViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Color.h"

#import "AppModel.h"
#import "Game.h"
#import "NoteCell.h"
#import "ARISTemplate.h"

const int VIEW_MODE_MINE = 0;
const int VIEW_MODE_ALL  = 1;

@interface NotebookNotesViewController() <UITableViewDataSource, UITableViewDelegate, NoteCellDelegate, GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate>
{
    UITableView *table;
    
    int viewMode;
    int loadingMore;
    
    NSMutableDictionary *contentLoadedFlagMap;
    
    id <NotebookNotesViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NotebookNotesViewController

- (id) initWithDelegate:(id<NotebookNotesViewControllerDelegate>)d
{
    if(self = [super init])
    {
        viewMode = 1;
        loadingMore = 1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoteListAvailable) name:@"NewNoteListAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataAvailable:)   name:@"NoteDataAvailable"    object:nil];   
        contentLoadedFlagMap = [[NSMutableDictionary alloc] init];
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    table = [[UITableView alloc] initWithFrame:self.view.frame];
    table.contentInset = UIEdgeInsetsMake(64,0,49,0);
    [table setContentOffset:CGPointMake(0,-64)];  
    table.delegate   = self;
    table.dataSource = self;
    
    [self.view addSubview:table];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    table.frame = self.view.frame;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    backButton.accessibilityLabel = @"Back Button";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];  
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

- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n
{
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) setModeAll
{
    viewMode = VIEW_MODE_ALL; 
    [table reloadData]; 
}

- (void) setModeMine
{
    viewMode = VIEW_MODE_MINE;
    [table reloadData];
}

- (void) editRequestedForNote:(Note *)n
{
    NoteEditorViewController *nevc = [[NoteEditorViewController alloc] initWithNote:n delegate:self];
    [self.navigationController pushViewController:nevc animated:YES];  
}

- (void) backButtonTouched
{
    [delegate notesViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

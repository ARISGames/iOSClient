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

#import "AppModel.h"
#import "Game.h"
#import "NoteCell.h"

const int VIEW_MODE_MINE = 0;
const int VIEW_MODE_ALL  = 1;

@interface NotebookViewController() <UITableViewDataSource, UITableViewDelegate, NoteCellDelegate, GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate>
{
    UITableView *table;
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
        self.tabIconName = @"";
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
    
    table = [[UITableView alloc] initWithFrame:self.view.frame];
    table.delegate   = self;
    table.dataSource = self;
    [self.view addSubview:table];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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
    [cell populateWithNote:n]; 
    if(![contentLoadedFlagMap objectForKey:[NSString stringWithFormat:@"%d", n.noteId]])
        [[AppModel sharedAppModel].currentGame.notesModel getDetailsForNote:n];  

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
    
}

- (void) addNote
{
    NoteEditorViewController *nevc = [[NoteEditorViewController alloc] initWithNote:nil delegate:self];
    [self.navigationController pushViewController:nevc animated:YES]; 
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  NotebookViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookViewController.h"

#import "AppModel.h"
#import "AppServices.h"
#import "NoteCell.h"

const int VIEW_MODE_MINE = 0;
const int VIEW_MODE_ALL  = 1;

@interface NotebookViewController() <UITableViewDataSource, UITableViewDelegate, NoteCellDelegate>
{
    UITableView *table;
    int viewMode;
}

@end

@implementation NotebookViewController

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, NotebookViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        viewMode = 1;
        self.tabID = @"NOTE"; 
        self.tabIconName = @"";
        self.title = NSLocalizedString(@"NotebookTitleKey",@""); 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoteListAvailable) name:@"NewNoteListReady" object:nil];
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
    [[AppServices sharedAppServices] fetchGameNoteList];
}

- (void) newNoteListAvailable
{
    [table reloadData]; 
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int) tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section
{
    if     (viewMode == VIEW_MODE_MINE) return [[[AppModel sharedAppModel] playerNoteList] count];
    else if(viewMode == VIEW_MODE_ALL)  return [[[AppModel sharedAppModel] gameNoteList]   count]; 
    return 0;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *noteList;
    if     (viewMode == VIEW_MODE_MINE) noteList = [[[AppModel sharedAppModel] playerNoteList] allValues];
    else if(viewMode == VIEW_MODE_ALL)  noteList = [[[AppModel sharedAppModel] gameNoteList]   allValues];  
    
    NoteCell *cell;
    if(!(cell = (NoteCell *)[table dequeueReusableCellWithIdentifier:[NoteCell cellIdentifier]]))
        cell = [[NoteCell alloc] initWithDelegate:self]; 
    [cell populateWithNote:[noteList objectAtIndex:indexPath.row]]; 
    
    return cell;
}

@end

//
//  NotebookViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotebookViewController.h"
#import "StateControllerProtocol.h"
#import "NoteEditorViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NoteCell.h"
#import "Note.h"
#import "Comment.h"
#import "UIColor+ARISColors.h"

#define NOTE_SCOPE_PLAYER 0
#define NOTE_SCOPE_GAME 1

#define NOTE_SORT_NONE 0
#define NOTE_SORT_ABC  1
#define NOTE_SORT_POP  2
#define NOTE_SORT_TAG  3

@interface NotebookViewController()  <UITableViewDelegate, UITableViewDataSource, NoteEditorViewControllerDelegate>
{
    NSMutableArray *playerNoteList;
    NSMutableArray *gameNoteList;
    NSMutableArray *tagPlayerNoteListList;
    NSMutableArray *tagGameNoteListList;
    NSMutableArray *tagPlayerHeaderList;
    NSMutableArray *tagGameHeaderList;
    
    UITableView *noteTable;
    UIView *createBar;
    
    int noteScope;//0 - Player notes, 1 - Game notes
    int noteSort;
    
    BOOL hasAppeared;
    id<NotebookViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) NSMutableArray *playerNoteList;
@property (nonatomic, strong) NSMutableArray *gameNoteList;
@property (nonatomic, strong) NSMutableArray *tagPlayerNoteListList;
@property (nonatomic, strong) NSMutableArray *tagGameNoteListList;
@property (nonatomic, strong) NSMutableArray *tagPlayerHeaderList;
@property (nonatomic, strong) NSMutableArray *tagGameHeaderList;

@property (nonatomic, strong) UITableView *noteTable;
@property (nonatomic, strong) UIView *createBar;

@end

@implementation NotebookViewController

@synthesize playerNoteList;
@synthesize gameNoteList;
@synthesize tagPlayerNoteListList;
@synthesize tagGameNoteListList;
@synthesize tagPlayerHeaderList;
@synthesize tagGameHeaderList;

@synthesize noteTable;
@synthesize createBar;

- (id) initWithDelegate:(id<NotebookViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"NOTE";
        self.tabIconName = @"book";
        hasAppeared = NO;
        delegate = d;
        
        self.playerNoteList        = [[NSMutableArray alloc] initWithCapacity:10];
        self.gameNoteList          = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagPlayerNoteListList = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagGameNoteListList   = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagPlayerHeaderList   = [[NSMutableArray alloc] initWithCapacity:10];
        self.tagGameHeaderList     = [[NSMutableArray alloc] initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh)                name:@"NoteDeleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewNoteListReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedNoteList" object:nil];
        
        self.title = NSLocalizedString(@"NotebookTitleKey",@"");
    }
    return self;
}

- (void) loadView
{
    [super loadView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    self.noteTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    self.noteTable.contentInset = UIEdgeInsetsMake(0,0,44,0);
    self.noteTable.delegate = self;
    self.noteTable.dataSource = self;
    [self.view addSubview:self.noteTable];
    
    self.createBar = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44)];
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0*(self.view.bounds.size.width/3),0,self.view.bounds.size.width/3,44)];
    UIButton *text   = [[UIButton alloc] initWithFrame:CGRectMake(1*(self.view.bounds.size.width/3),0,self.view.bounds.size.width/3,44)];
    UIButton *audio  = [[UIButton alloc] initWithFrame:CGRectMake(2*(self.view.bounds.size.width/3),0,self.view.bounds.size.width/3,44)];
    [camera setImage:[UIImage imageNamed:@"camera"]     forState:UIControlStateNormal];
    [text   setImage:[UIImage imageNamed:@"note"]       forState:UIControlStateNormal];
    [audio  setImage:[UIImage imageNamed:@"microphone"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(cameraTouched) forControlEvents:UIControlEventTouchUpInside];
    [text   addTarget:self action:@selector(textTouched)   forControlEvents:UIControlEventTouchUpInside];
    [audio  addTarget:self action:@selector(audioTouched)  forControlEvents:UIControlEventTouchUpInside];
    [self.createBar addSubview:camera];
    [self.createBar addSubview:text];
    [self.createBar addSubview:audio];
    [self.view addSubview:self.createBar];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void) sortWithMode:(int)mode
{
    noteSort = mode;
    switch(noteSort)
    {
        case NOTE_SORT_NONE:
        {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO]];
            self.playerNoteList     = [NSMutableArray arrayWithArray:[self.playerNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList       = [NSMutableArray arrayWithArray:[self.gameNoteList   sortedArrayUsingDescriptors:sortDescriptors]];
            break;
        }
        case NOTE_SORT_ABC:
        {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
            self.playerNoteList     = [NSMutableArray arrayWithArray:[self.playerNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList       = [NSMutableArray arrayWithArray:[self.gameNoteList   sortedArrayUsingDescriptors:sortDescriptors]];
            break;
        }
        case NOTE_SORT_POP:
        {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"numRatings" ascending:NO]];
            self.playerNoteList     = [NSMutableArray arrayWithArray:[self.playerNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList       = [NSMutableArray arrayWithArray:[self.gameNoteList   sortedArrayUsingDescriptors:sortDescriptors]];
            break;
        }
        default:
            break;
    }
    [noteTable reloadData];
}

- (void) refresh
{
    if(noteScope == NOTE_SCOPE_PLAYER)    [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
    else if(noteScope == NOTE_SCOPE_GAME) [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
    
    [[AppServices sharedAppServices] fetchGameNoteTagsAsynchronously:YES];
}

- (void) showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicator]];
	[activityIndicator startAnimating];    
}

- (void) removeLoadingIndicator
{
    [self.navigationItem setRightBarButtonItem:nil];
    [noteTable reloadData];
}

- (void) noteEditorViewControllerDidFinish
{
    [self refreshViewFromModel];
}

- (void) refreshViewFromModel
{    
	self.playerNoteList = [[[AppModel sharedAppModel].playerNoteList allValues] mutableCopy];
    
    if([AppModel sharedAppModel].currentGame.allowShareNoteToList)
        self.gameNoteList = [[[AppModel sharedAppModel].gameNoteList allValues] mutableCopy];
    else
        self.gameNoteList = [[NSMutableArray alloc] initWithCapacity:10];
    
    for(int i = 0; i < [gameNoteList count]; i++)
    {
        if(!((Note *)[gameNoteList objectAtIndex:i]).showOnList)
        {
            [gameNoteList removeObjectAtIndex:i];
            i--;
        }
    }
    
    if([AppModel sharedAppModel].gameTagList)
    {
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"tagName" ascending:YES]];
        NSArray *tagList = [[AppModel sharedAppModel].gameTagList sortedArrayUsingDescriptors:sortDescriptors];
        
        [tagGameNoteListList removeAllObjects];
        [tagGameHeaderList   removeAllObjects];
        for(int i = 0; i < [tagList count]; i++)
        {
            NSString *tagName = [[tagList objectAtIndex:i] tagName];
            NSMutableArray *tempTagList = [[NSMutableArray alloc] initWithCapacity:5];
            for(int x = 0; x < [self.gameNoteList count]; x++)
            {                
                for(int y = 0; y < [[[self.gameNoteList objectAtIndex:x] tags] count]; y++)
                {
                    if ([[[[[self.gameNoteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName])
                        [tempTagList addObject:[self.gameNoteList objectAtIndex:x]];
                }
            }
            if([tempTagList count] >0)
            {
                [self.tagGameNoteListList addObject:tempTagList];
                [self.tagGameHeaderList addObject:tagName];
            }
        }
        
        [tagPlayerNoteListList removeAllObjects];
        [tagGameHeaderList     removeAllObjects];
        for(int i = 0; i < [tagList count]; i++)
        {
            NSString *tagName = [[tagList objectAtIndex:i] tagName];
            NSMutableArray *tempTagList = [[NSMutableArray alloc] initWithCapacity:5];
            for(int x = 0; x < [self.playerNoteList count]; x++)
            {
                for(int y = 0; y < [[[self.playerNoteList objectAtIndex:x] tags] count]; y ++)
                {
                    if ([[[[[self.playerNoteList objectAtIndex:x] tags] objectAtIndex:y] tagName] isEqualToString:tagName])
                        [tempTagList addObject:[self.playerNoteList objectAtIndex:x]];
                }
            }
            if([tempTagList count] >0)
            {
                [self.tagPlayerNoteListList addObject:tempTagList];
                [self.tagGameHeaderList     addObject:tagName];
            }
        }
        [self sortWithMode:NOTE_SORT_NONE];
    }
    
    [noteTable reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(noteSort == NOTE_SORT_TAG)
    {
        if     (noteScope == NOTE_SCOPE_PLAYER) return [self.tagPlayerNoteListList count];
        else if(noteScope == NOTE_SCOPE_GAME)   return [self.tagGameNoteListList   count];
    }
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(noteSort ==  NOTE_SORT_TAG)
    {
        if     (noteScope == NOTE_SCOPE_PLAYER) return [[self.tagPlayerNoteListList objectAtIndex:section] count];
        else if(noteScope == NOTE_SCOPE_GAME)   return [[self.tagGameNoteListList   objectAtIndex:section] count];
    }
    else
    {
        if     (noteScope == NOTE_SCOPE_PLAYER) return ([self.playerNoteList count] == 0) ? 1 : [self.playerNoteList count];
        else if(noteScope == NOTE_SCOPE_GAME)   return ([self.gameNoteList   count] == 0) ? 1 : [self.gameNoteList   count];
    }
    return ([self.gameNoteList count] == 0) ? 1 : [self.gameNoteList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *currentNoteList;
    
    if(noteSort == NOTE_SORT_TAG)
    {
        if     (noteScope == NOTE_SCOPE_PLAYER) currentNoteList = self.tagPlayerNoteListList;
        else if(noteScope == NOTE_SCOPE_GAME)   currentNoteList = self.tagGameNoteListList;
    }
    else
    {
        if     (noteScope == NOTE_SCOPE_PLAYER) currentNoteList = self.playerNoteList;
        else if(noteScope == NOTE_SCOPE_GAME)   currentNoteList = self.gameNoteList;
    }
    
	static NSString *CellIdentifier = @"Cell";
    if([currentNoteList count] == 0 && indexPath.row == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.text = NSLocalizedString(@"NotebookNoNotesKey", @"");
        cell.detailTextLabel.text = NSLocalizedString(@"NotebooksPressToAddKey", @"");
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
    NoteCell *cell;
    UITableViewCell *tempCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!tempCell || ![tempCell isKindOfClass:[NoteCell class]])
        cell = (NoteCell *)[[[NSBundle mainBundle] loadNibNamed:@"NoteCell" owner:[[ARISViewController alloc] init] options:nil] objectAtIndex:0];
    else
        cell = (NoteCell *)tempCell;
    
    Note *currNote;
    if(noteSort == NOTE_SORT_TAG)
        currNote = (Note *)[[currentNoteList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    else
        currNote = (Note *)[currentNoteList objectAtIndex:indexPath.row];

    [cell setupWithNote:currNote delegate:self];

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(noteSort == NOTE_SORT_TAG)
    {
        if(noteScope == NOTE_SCOPE_PLAYER && [self.tagPlayerHeaderList count] > section)
            return [self.tagPlayerHeaderList objectAtIndex:section];
        else if(noteScope == NOTE_SCOPE_GAME && [self.tagGameHeaderList count] > section)
            return [self.tagGameHeaderList objectAtIndex:section];
    }
    return @"";
}
    
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *currentNoteList;
    if(noteScope == NOTE_SCOPE_PLAYER)
    {
        currentNoteList = self.playerNoteList;
        if(noteSort == NOTE_SORT_TAG)
            currentNoteList = [self.tagPlayerNoteListList objectAtIndex:indexPath.section];
    }
    else
    {
        currentNoteList = self.gameNoteList;
        if(noteSort == NOTE_SORT_TAG)
            currentNoteList = [self.tagGameNoteListList objectAtIndex:indexPath.section];
    }
    
    [delegate displayGameObject:(Note *)[currentNoteList objectAtIndex:indexPath.row] fromSource:self];
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(noteSort == NOTE_SORT_TAG)
        return UITableViewCellEditingStyleNone;
    if(noteScope == NOTE_SCOPE_GAME && 
       ([self.gameNoteList count] != 0) && 
       [[self.gameNoteList objectAtIndex:indexPath.row] creatorId] == [AppModel sharedAppModel].player.playerId)
            return UITableViewCellEditingStyleDelete;
    else if(noteScope == NOTE_SCOPE_PLAYER && [self.playerNoteList count] != 0)
            return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AppServices sharedAppServices] deleteNoteWithNoteId:[(Note *)[self.playerNoteList objectAtIndex:indexPath.row] noteId]];
    if(noteScope == NOTE_SCOPE_GAME)
        [[AppModel sharedAppModel].gameNoteList   removeObjectForKey:[NSNumber numberWithInt:[(Note *)[self.gameNoteList objectAtIndex:indexPath.row] noteId]]];
    else if(noteScope == NOTE_SCOPE_PLAYER)
        [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:[(Note *)[self.playerNoteList objectAtIndex:indexPath.row] noteId]]];
    [self refreshViewFromModel];
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [noteTable reloadData];
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"Delete Note";
}

- (void) cameraTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:NO];
}

- (void) textTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:NO];
}

- (void) audiotouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:NO];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

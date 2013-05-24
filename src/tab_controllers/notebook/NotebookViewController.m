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

@interface NotebookViewController()  <UITableViewDelegate, UITableViewDataSource>
{
    BOOL menuDown;
    
    NSMutableArray *playerNoteList;
    NSMutableArray *gameNoteList;
    NSMutableArray *tagPlayerNoteListList;
    NSMutableArray *tagGameNoteListList;
    NSMutableArray *tagPlayerHeaderList;
    NSMutableArray *tagGameHeaderList;
    
    IBOutlet UIToolbar *filterToolBar;
    IBOutlet UISegmentedControl *filterControl;
    IBOutlet UITableView *noteTable;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIToolbar *sortToolBar;
    IBOutlet UISegmentedControl *sortControl;
    
    id<NotebookViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) NSMutableArray *playerNoteList;
@property (nonatomic, strong) NSMutableArray *gameNoteList;
@property (nonatomic, strong) NSMutableArray *tagPlayerNoteListList;
@property (nonatomic, strong) NSMutableArray *tagGameNoteListList;
@property (nonatomic, strong) NSMutableArray *tagPlayerHeaderList;
@property (nonatomic, strong) NSMutableArray *tagGameHeaderList;

@property (nonatomic, strong) IBOutlet UIToolbar *filterToolBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *filterControl;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UITableView *noteTable;
@property (nonatomic, strong) IBOutlet UIToolbar *sortToolBar;
@property (nonatomic, strong) IBOutlet UISegmentedControl *sortControl;

- (IBAction) filterButtonTouchAction:(id)sender;
- (IBAction) sortButtonTouchAction:(id)sender;
- (IBAction) barButtonTouchAction:(id)sender;

@end

@implementation NotebookViewController

@synthesize playerNoteList;
@synthesize gameNoteList;
@synthesize tagPlayerNoteListList;
@synthesize tagGameNoteListList;
@synthesize tagPlayerHeaderList;
@synthesize tagGameHeaderList;
@synthesize filterToolBar;
@synthesize filterControl;
@synthesize toolBar;
@synthesize noteTable;
@synthesize sortToolBar;
@synthesize sortControl;

- (id) initWithDelegate:(id<NotebookViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithNibName:@"NotebookViewController" bundle:nil])
    {
        delegate = d;
        
        menuDown  = NO;
        
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
        self.tabBarItem.image = [UIImage imageNamed:@"96-book"];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"14-gear"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleMenu)];
    
    float screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    [self.filterToolBar setFrame:CGRectMake(0,             -44, 320,                     44)];
    [self.toolBar       setFrame:CGRectMake(0,               0, 320,                     44)];
    [self.noteTable     setFrame:CGRectMake(0,              44, 320, screenHeight-(2*44)-49)];
    [self.sortToolBar   setFrame:CGRectMake(0, screenHeight-49, 320,                     44)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setMenuDisplayDown:menuDown];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void) toggleMenu
{
    [self setMenuDisplayDown:!menuDown];
}

- (void) setMenuDisplayDown:(BOOL)down
{
    menuDown = down;
    [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] playAudioAlert:@"swish" shouldVibrate:NO];
    
    float screenHeight = [UIScreen mainScreen].applicationFrame.size.height;
    if(menuDown)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.2];
        [self.filterToolBar setFrame:CGRectMake(0,                      0, 320,                     44)];
        [self.toolBar       setFrame:CGRectMake(0,                     44, 320,                     44)];
        [self.noteTable     setFrame:CGRectMake(0,                 (2*44), 320, screenHeight-(4*44)-49)];
        [self.sortToolBar   setFrame:CGRectMake(0, screenHeight-(2*44)-49, 320,                     44)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.2];
        [self.filterToolBar setFrame:CGRectMake(0,             -44, 320,                     44)];
        [self.toolBar       setFrame:CGRectMake(0,               0, 320,                     44)];
        [self.noteTable     setFrame:CGRectMake(0,              44, 320, screenHeight-(2*44)-49)];
        [self.sortToolBar   setFrame:CGRectMake(0, screenHeight-49, 320,                     44)];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [UIView commitAnimations];
    }

}

- (void) filterButtonTouchAction:(id)sender
{    
    [self refresh];
}

- (void) sortButtonTouchAction:(id)sender
{
    [self sortWithMode:[(UISegmentedControl *)sender selectedSegmentIndex]];
}

- (void) sortWithMode:(int)mode
{
    switch(mode)
    {
        case 0:
        {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO]];
            self.playerNoteList     = [NSMutableArray arrayWithArray:[self.playerNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList       = [NSMutableArray arrayWithArray:[self.gameNoteList   sortedArrayUsingDescriptors:sortDescriptors]];
            break;
        }
        case 1:
        {
            NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]];
            self.playerNoteList     = [NSMutableArray arrayWithArray:[self.playerNoteList sortedArrayUsingDescriptors:sortDescriptors]];
            self.gameNoteList       = [NSMutableArray arrayWithArray:[self.gameNoteList   sortedArrayUsingDescriptors:sortDescriptors]];
            break;
        }
        case 2:
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
    if(filterControl.selectedSegmentIndex == 0)
        [[AppServices sharedAppServices] fetchPlayerNoteListAsynchronously:YES];
    else
        [[AppServices sharedAppServices] fetchGameNoteListAsynchronously:YES];
    
    [[AppServices sharedAppServices] fetchGameNoteTagsAsynchronously:YES];
}

- (void) showLoadingIndicator
{
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:activityIndicator]];
	[activityIndicator startAnimating];    
}

- (void) removeLoadingIndicator
{
    [noteTable reloadData];
}

- (void) barButtonTouchAction:(id)sender
{
    NSString *startView;
    switch([sender tag])
    {
        case 0: startView = @"camera"; break;
        case 1: startView = @"text";   break;
        case 2: startView = @"audio";  break;
        default:startView = @"text";   break;
    }
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil inView:startView delegate:self] animated:NO];
}

- (void) refreshViewFromModel
{    
	self.playerNoteList = [[[AppModel sharedAppModel].playerNoteList allValues] mutableCopy];
    if([AppModel sharedAppModel].currentGame.allowShareNoteToList) self.gameNoteList = [[[AppModel sharedAppModel].gameNoteList allValues] mutableCopy];
    else                                                           self.gameNoteList = [[NSMutableArray alloc] initWithCapacity:10];
    
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
        [self sortWithMode:0];
    }
    
    [noteTable reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if([sortControl selectedSegmentIndex] == 3) //tag
    {
        if(self.filterControl.selectedSegmentIndex == 0) return [self.tagPlayerNoteListList count];
        else                                             return [self.tagGameNoteListList   count];
    }
    else
        return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([sortControl selectedSegmentIndex] == 3) //tag
    {
        if(self.filterControl.selectedSegmentIndex == 0) return [[self.tagPlayerNoteListList objectAtIndex:section] count];
        else                                             return [[self.tagGameNoteListList   objectAtIndex:section] count]; 
    }
    else
    {
        if(self.filterControl.selectedSegmentIndex == 0) return ([self.playerNoteList count] == 0) ? 1 : [self.playerNoteList count];
        else                                             return ([self.gameNoteList   count] == 0) ? 1 : [self.gameNoteList   count];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *currentNoteList;
    
    if([sortControl selectedSegmentIndex] == 3) //tag
    {
        if(self.filterControl.selectedSegmentIndex == 0) currentNoteList = self.tagPlayerNoteListList;
        else                                             currentNoteList = self.tagGameNoteListList;
    }
    else
    {
        if(self.filterControl.selectedSegmentIndex == 0) currentNoteList = self.playerNoteList;
        else                                             currentNoteList = self.gameNoteList;
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
        cell = (NoteCell *)[[[NSBundle mainBundle] loadNibNamed:@"NoteCell" owner:[[UIViewController alloc] init] options:nil] objectAtIndex:0]
;
    else
        cell = (NoteCell *)tempCell;
    
        
    Note *currNote;
    if([sortControl selectedSegmentIndex] == 3) //tag
        currNote = (Note *)[[currentNoteList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    else
        currNote = (Note *)[currentNoteList objectAtIndex:indexPath.row];

    [cell setupWithNote:currNote delegate:self];

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([sortControl selectedSegmentIndex] == 3) //tag
    {
        if(self.filterControl.selectedSegmentIndex == 0)
        {
            if([self.tagGameHeaderList count] > section)
                return [self.tagGameHeaderList objectAtIndex:section];
            else return @"";
        }
        else
        {
            if([self.tagGameHeaderList count] > section)
                return [self.tagGameHeaderList objectAtIndex:section];
            else return @"";
        }
        
    }
    else return @"";
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(indexPath.row % 2 == 0) cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0];  
    else                       cell.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];  
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *currentNoteList;
    if(self.filterControl.selectedSegmentIndex == 0)
    {
        if([sortControl selectedSegmentIndex] == 3) //tag
            currentNoteList = [self.tagPlayerNoteListList objectAtIndex:indexPath.section];
        else
            currentNoteList = self.playerNoteList;
    }
    else
    {
        if([sortControl selectedSegmentIndex] == 3) //tag
            currentNoteList = [self.tagGameNoteListList objectAtIndex:indexPath.section];
        else
            currentNoteList = self.gameNoteList;
    }
    
    [delegate displayGameObject:(Note *)[currentNoteList objectAtIndex:indexPath.row] fromSource:self];
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([sortControl selectedSegmentIndex] == 3) //tag
        return UITableViewCellEditingStyleNone;
    if(self.filterControl.selectedSegmentIndex == 1) //game notes
    {
        if(([self.gameNoteList count] != 0) && [[self.gameNoteList objectAtIndex:indexPath.row] creatorId] == [AppModel sharedAppModel].player.playerId)
            return UITableViewCellEditingStyleDelete;
    }
    else
    {
        if([self.playerNoteList count] != 0)
            return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AppServices sharedAppServices]deleteNoteWithNoteId:[(Note *)[self.playerNoteList objectAtIndex:indexPath.row] noteId]];
    if(self.filterControl.selectedSegmentIndex == 1) //game notes
        [[AppModel sharedAppModel].gameNoteList   removeObjectForKey:[NSNumber numberWithInt:[(Note *)[self.gameNoteList objectAtIndex:indexPath.row] noteId]]];
    else
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

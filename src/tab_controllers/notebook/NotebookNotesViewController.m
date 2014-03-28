//
//  NotebookNotesViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookNotesViewController.h"
#import "NoteViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AppModel.h"
#import "Game.h"
#import "NoteCell.h"
#import "ARISTemplate.h"
#import "NoteTag.h"

const int VIEW_MODE_MINE = 0;
const int VIEW_MODE_ALL  = 1;
const int VIEW_MODE_TAG  = 2;

@interface NotebookNotesViewController() <UITableViewDataSource, UITableViewDelegate, NoteCellDelegate, GameObjectViewControllerDelegate, NoteViewControllerDelegate, UISearchBarDelegate>
{
    UITableView *table;
    UISearchBar *searchBar;
    NSString *filterText;
    
    int viewMode;
    NoteTag *filterTag;
    
    NSArray *filteredNotes;
    
    UILabel *navTitleLabel;
    UIView *navTitleView;
    
    id <NotebookNotesViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NotebookNotesViewController

- (id) initWithDelegate:(id<NotebookNotesViewControllerDelegate>)d
{
    if(self = [super init])
    {
        viewMode = 1;
        filterText = @"";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoteListAvailable) name:@"NewNoteListAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataAvailable:)   name:@"NoteDataAvailable"    object:nil];
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.showsCancelButton = NO;
    
    navTitleView = [[UIView alloc] init];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.font = [ARISTemplate ARISTitleFont];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    switch(viewMode)
    {
        case VIEW_MODE_MINE: navTitleLabel.text = @"My Notes";    break;
        case VIEW_MODE_ALL:  navTitleLabel.text = @"All Notes";   break; 
        case VIEW_MODE_TAG:  navTitleLabel.text = filterTag.text; break; 
    }
    
    [navTitleView addSubview:navTitleLabel];
    self.navigationItem.titleView = navTitleView;
    
    table = [[UITableView alloc] initWithFrame:self.view.frame];
    table.contentInset = UIEdgeInsetsMake(100,0,49,0);
    [table setContentOffset:CGPointMake(0,-100)];  
    table.delegate   = self;
    table.dataSource = self;
    
    [self.view addSubview:table];
    [self.view addSubview:searchBar];   
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    navTitleView.frame  = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
    navTitleLabel.frame = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height);  
    
    searchBar.frame = CGRectMake(-4,64,self.view.bounds.size.width+8,36);//weird width/height because apple
    
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
    [table reloadData];  
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int) tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section
{
    NSArray *typeFilteredNotes;
    if     (viewMode == VIEW_MODE_MINE) typeFilteredNotes = [[AppModel sharedAppModel].currentGame.notesModel playerNotes];
    else if(viewMode == VIEW_MODE_ALL)  typeFilteredNotes = [[AppModel sharedAppModel].currentGame.notesModel listNotes];
    else if(viewMode == VIEW_MODE_TAG)  typeFilteredNotes = [[AppModel sharedAppModel].currentGame.notesModel notesMatchingTag:filterTag];
    
    if([filterText isEqualToString:@""])
        filteredNotes = typeFilteredNotes;
    else
    {
        NSMutableArray *textFilteredNotes = [[NSMutableArray alloc] initWithCapacity:[typeFilteredNotes count]];
        Note *n;
        
        for(int i = 0; i < [typeFilteredNotes count]; i++)
        {
            n = [typeFilteredNotes objectAtIndex:i];
            if([n.name rangeOfString:filterText options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)    
                [textFilteredNotes addObject:n];
        }
        filteredNotes = textFilteredNotes; 
    }
    return [filteredNotes count] + (1-[AppModel sharedAppModel].currentGame.notesModel.listComplete);
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![AppModel sharedAppModel].currentGame.notesModel.listComplete && indexPath.row >= [filteredNotes count])
    {
        [[AppModel sharedAppModel].currentGame.notesModel getNextNotes]; 
        UITableViewCell *cell;
        if(!(cell = [table dequeueReusableCellWithIdentifier:@"loadingCell"])) 
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadingCell"];
                             
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(cell.frame.size.width-65, 15, 60, 15);
            [cell addSubview:spinner];
            [spinner startAnimating]; 
        }
        return cell;
    }
    
    NoteCell *cell;
    if(!(cell = (NoteCell *)[table dequeueReusableCellWithIdentifier:[NoteCell cellIdentifier]]))
        cell = [[NoteCell alloc] initWithDelegate:self]; 
    Note *n = [filteredNotes objectAtIndex:indexPath.row];
    if(n.stubbed) [[AppModel sharedAppModel].currentGame.notesModel getDetailsForNote:n];   
    [cell populateWithNote:n loading:n.stubbed]; 

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![AppModel sharedAppModel].currentGame.notesModel.listComplete && indexPath.row >= [filteredNotes count])  return;
    
    NoteViewController *nvc = [[NoteViewController alloc] initWithNote:[filteredNotes objectAtIndex:indexPath.row] delegate:self];
    [self.navigationController pushViewController:nvc animated:YES];
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [self.navigationController popToViewController:self animated:YES];    
}

- (void) searchBar:(UISearchBar *)s textDidChange:(NSString *)t
{
    filterText = t;
    searchBar.showsCancelButton = YES; 
    [table reloadData];   
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)s
{
    filterText = @"";
    searchBar.text = @"";
    [searchBar resignFirstResponder]; 
    searchBar.showsCancelButton = NO;  
    [table reloadData]; 
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)s
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;  
    [table reloadData];  
}

- (void) setModeAll
{
    viewMode = VIEW_MODE_ALL; 
    navTitleLabel.text = @"All Notes"; 
    [table reloadData]; 
}

- (void) setModeMine
{
    viewMode = VIEW_MODE_MINE;
    navTitleLabel.text = @"My Notes";  
    [table reloadData];
}

- (void) setModeTag:(NoteTag *)t
{
    viewMode = VIEW_MODE_TAG;
    filterTag = t;
    navTitleLabel.text = filterTag.text;    
    [table reloadData];
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

//
//  NotebookNotesViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookNotesViewController.h"
#import "NoteViewController.h"

#import "AppModel.h"
#import "Game.h"
#import "NoteCell.h"

#import "User.h"

const long VIEW_MODE_MINE = 0;
const long VIEW_MODE_ALL  = 1;
const long VIEW_MODE_TAG  = 2;

@interface NotebookNotesViewController() <UITableViewDataSource, UITableViewDelegate, InstantiableViewControllerDelegate, NoteCellDelegate, NoteViewControllerDelegate, UISearchBarDelegate>
{
  UITableView *table;
  UISearchBar *searchBar;

  UILabel *navTitleLabel;
  UIView *navTitleView;

  NSArray *filteredNotes;

  long viewMode;
  Tag *filterTag;
  NSString *filterText;

  id <NotebookNotesViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NotebookNotesViewController

- (id) initWithDelegate:(id<NotebookNotesViewControllerDelegate>)d
{
  if(self = [super init])
  {
    viewMode = VIEW_MODE_MINE;
    filterText = @"";

    delegate = d;
    _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_TRIGGERS_AVAILABLE",self,@selector(newNoteListAvailable),nil);
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
    case VIEW_MODE_MINE: navTitleLabel.text = NSLocalizedString(@"NotebookMyNotesKey", @"");    break;
    case VIEW_MODE_ALL:  navTitleLabel.text = NSLocalizedString(@"NotebookAllNotesKey", @"");   break;
    case VIEW_MODE_TAG:  navTitleLabel.text = filterTag.tag; break;
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger) tableView:(UITableView *)t numberOfRowsInSection:(NSInteger)section
{
  NSArray *typeFilteredNotes;
  if     (viewMode == VIEW_MODE_MINE) typeFilteredNotes = [_MODEL_NOTES_ playerNotes];
  else if(viewMode == VIEW_MODE_ALL)  typeFilteredNotes = [_MODEL_NOTES_ listNotes];
  else if(viewMode == VIEW_MODE_TAG)  typeFilteredNotes = [_MODEL_NOTES_ notesMatchingTag:filterTag];

  NSMutableArray *textFilteredNotes;
  if([filterText isEqualToString:@""])
    textFilteredNotes = [NSMutableArray arrayWithArray:typeFilteredNotes];
  else
  {
    Note *n;
    textFilteredNotes = [[NSMutableArray alloc] initWithCapacity:typeFilteredNotes.count];
    for(long i = 0; i < typeFilteredNotes.count; i++)
    {
      n = [typeFilteredNotes objectAtIndex:i];
      //Search description
      if([n.desc rangeOfString:filterText options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)
        [textFilteredNotes addObject:n];
      //Search owner
      else if([[_MODEL_USERS_ userForId:n.user_id].display_name rangeOfString:filterText options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)
        [textFilteredNotes addObject:n];
      //Search tags
      else
      {
        NSArray *tags = [_MODEL_TAGS_ tagsForObjectType:@"NOTE" id:n.note_id];
        for(long j = 0; j < tags.count; j++)
        {
          if([((Tag *)tags[j]).tag rangeOfString:filterText options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)
          {
            [textFilteredNotes addObject:n];
            break; //must break so we don't add same note multiple times
          }
        }
      }
    }
  }

  filteredNotes = _ARIS_ARRAY_SORTED_ON_(textFilteredNotes,@"created");
  return filteredNotes.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 78.0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NoteCell *cell;
  if(!(cell = (NoteCell *)[table dequeueReusableCellWithIdentifier:[NoteCell cellIdentifier]]))
    cell = [[NoteCell alloc] initWithDelegate:self];
  Note *n = [filteredNotes objectAtIndex:indexPath.row];
  [cell populateWithNote:n];

  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  Instance *i = [_MODEL_INSTANCES_ instanceForId:0]; //create hacked instance
  i.object_type = @"NOTE";
  i.object_id = ((Note *)[filteredNotes objectAtIndex:indexPath.row]).note_id;
  i.qty = 1;
  NoteViewController *nvc = [[NoteViewController alloc] initWithInstance:i delegate:self];
  [self.navigationController pushViewController:nvc animated:YES];
}

- (void) instantiableViewControllerRequestsDismissal:(id<InstantiableViewControllerProtocol>)govc
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
  navTitleLabel.text = NSLocalizedString(@"NotebookAllNotesKey", @"");
  [table reloadData];
}

- (void) setModeMine
{
  viewMode = VIEW_MODE_MINE;
  navTitleLabel.text = NSLocalizedString(@"NotebookMyNotesKey", @"");
  [table reloadData];
}

- (void) setModeTag:(Tag *)t
{
  viewMode = VIEW_MODE_TAG;
  filterTag = t;
  navTitleLabel.text = filterTag.tag;
  [table reloadData];
}

- (void) backButtonTouched
{
  [delegate notesViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

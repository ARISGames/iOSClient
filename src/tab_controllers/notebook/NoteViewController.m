//
//  NoteViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "NoteViewController.h"
#import "NoteComment.h"
#import "NoteCommentsViewController.h"
#import "NoteCommentInputViewController.h"
#import "NoteEditorViewController.h"
#import "ARISMediaView.h"
#import "Note.h"
#import "User.h"
#import "AppModel.h"
#import "Game.h"

@interface NoteViewController () <NoteCommentInputViewControllerDelegate, NoteCommentsViewControllerDelegate, NoteEditorViewControllerDelegate, UIScrollViewDelegate, ARISMediaViewDelegate>
{
    Instance *instance;
    Note *note;

    UIView *navView;
    UILabel *title;
    UILabel *ownerdate;
    UILabel *tag;
    UIScrollView *scrollView;
    UILabel *desc;

    ARISMediaView *amv;
    NoteCommentInputViewController *commentInput;
    NoteCommentsViewController *commentsDisplay;

    id<NoteViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteViewController

- (id) initWithInstance:(Instance *)i delegate:(id<NoteViewControllerDelegate>)d
{
    if(self = [super init])
    {
        instance = i;
        note = [_MODEL_NOTES_ noteForId:i.object_id];
        delegate = d;
    }
    return self;
}
- (Instance *) instance { return instance; }

- (void) loadView
{
    [super loadView];

    navView = [[UIView alloc] init];

    title = [[UILabel alloc] init];
    title.font = [ARISTemplate ARISCellTitleFont];
    title.textColor = [UIColor ARISColorBlack];
    title.adjustsFontSizeToFitWidth = NO;
    title.textAlignment = NSTextAlignmentCenter;

    ownerdate = [[UILabel alloc] init];
    ownerdate.font = [ARISTemplate ARISSubtextFont];
    ownerdate.textColor = [UIColor ARISColorGray];
    ownerdate.adjustsFontSizeToFitWidth = NO;
    ownerdate.textAlignment = NSTextAlignmentCenter;

    tag = [[UILabel alloc] init];
    tag.font = [ARISTemplate ARISSubtextFont];
    tag.textColor = [UIColor ARISColorGray];
    tag.adjustsFontSizeToFitWidth = NO;
    tag.textAlignment = NSTextAlignmentCenter;

    [navView addSubview:title];
    [navView addSubview:ownerdate];
    [navView addSubview:tag];

    //need to predict format here otherwise label jumps around
    navView.frame = CGRectMake(0, 0, 200, 64);
    title.frame = CGRectMake(0,0,200,35);
    ownerdate.frame = CGRectMake(0,0,200,62);
    tag.frame = CGRectMake(0,0,200,86);
    self.navigationItem.titleView = navView;

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    scrollView.backgroundColor = [UIColor whiteColor];

    desc = [[UILabel alloc] initWithFrame:CGRectMake(10,84,self.view.frame.size.width-20,18)];
    desc.lineBreakMode = NSLineBreakByWordWrapping;
    desc.numberOfLines = 0;
    desc.font = [ARISTemplate ARISBodyFont];
    desc.textColor = [UIColor ARISColorDarkGray];

    commentInput    = [[NoteCommentInputViewController alloc] initWithDelegate:self];
    commentsDisplay = [[NoteCommentsViewController     alloc] initWithNoteComments:[_MODEL_NOTES_ noteCommentsForNoteId:note.note_id] delegate:self];

    [scrollView addSubview:desc];
    [scrollView addSubview:commentsDisplay.view];
    [self.view addSubview:scrollView];
    [self.view addSubview:commentInput.view];

    [self displayDataFromNote];
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

    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, 19, 19);
    [editButton setImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    editButton.accessibilityLabel = @"Edit Button";
    if(_MODEL_PLAYER_.user_id == note.user_id)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];

    navView.frame = CGRectMake(0, 0, 200, 64);
    title.frame = CGRectMake(0,0,200,35);
    ownerdate.frame = CGRectMake(0,0,200,62);
    tag.frame = CGRectMake(0,0,200,86);
    self.navigationItem.titleView = navView;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self formatSubviews];
}

- (void) formatSubviews
{
    scrollView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);

    long curY = 0;

    amv.frame = CGRectMake(0,curY,self.view.frame.size.width,amv.frame.size.height);

    curY = amv.frame.origin.y+amv.frame.size.height;

    if([note.desc length] > 0)
    {
        NSMutableParagraphStyle *paragraphStyle;
        CGRect textRect;
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textRect = [desc.text boundingRectWithSize:CGSizeMake(desc.frame.size.width,9999999)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:desc.font,NSParagraphStyleAttributeName:paragraphStyle}
                                             context:nil];
        CGSize descSize = textRect.size;
        desc.frame = CGRectMake(10,curY,self.view.frame.size.width-20,descSize.height+10);
    }
    else desc.frame = CGRectMake(10,curY,self.view.frame.size.width-20,0);

    curY += desc.frame.size.height + 20;

    commentInput.view.frame = CGRectMake(0, self.view.bounds.size.height-commentInput.view.frame.size.height, self.view.frame.size.width, commentInput.view.frame.size.height);

    if([_MODEL_NOTES_ noteCommentsForNoteId:note.note_id].count > 0)
        commentsDisplay.view.frame = CGRectMake(0, curY, self.view.frame.size.width, commentsDisplay.view.frame.size.height);
    else
        commentsDisplay.view.frame = CGRectMake(0, curY, self.view.frame.size.width, 0);

    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, commentsDisplay.view.frame.origin.y + commentsDisplay.view.frame.size.height + 266);
}

- (void) displayDataFromNote
{
    NSArray *tags = [_MODEL_TAGS_ tagsForObjectType:@"NOTE" id:note.note_id];
    if(tags.count > 0) tag.text = ((Tag *)[tags objectAtIndex:0]).tag;
    title.text = note.name;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    ownerdate.text = [NSString stringWithFormat:@"%@ %@",[_MODEL_USERS_ userForId:note.user_id].display_name,[format stringFromDate:note.created]];

    desc.text = note.desc;

    if(note.media_id)
    {
        if(!amv)
        {
            amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,10) delegate:self];
            [amv setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight];
            [amv setMedia:[_MODEL_MEDIA_ mediaForId:note.media_id]];
        }
        [amv setFrame:CGRectMake(0,0,self.view.frame.size.width,amv.frame.size.height)];

        if([[_MODEL_MEDIA_ mediaForId:note.media_id].type isEqualToString:@"IMAGE"])
            [amv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissComment)]];
        [scrollView addSubview:amv];
    }

    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissComment)]];

    [commentsDisplay setComments:[_MODEL_NOTES_ noteCommentsForNoteId:note.note_id]];
    [self formatSubviews];
}

- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv
{
    [self dismissComment];
    return YES;
}

- (void) noteDataAvailable:(NSNotification *)n
{
    if(((Note *)[n.userInfo objectForKey:@"note"]).note_id != note.note_id) return;
    note = [n.userInfo objectForKey:@"note"];
    [self displayDataFromNote];
}

- (void) dismissComment
{
    [commentInput dismissKeyboard];
}

- (void) commentBeganEditing
{
    // TODO respond to soft keyboard show event to adjust height (or not when hardware keyboard present)
    if(commentsDisplay.view.frame.origin.y+commentsDisplay.view.frame.size.height < self.view.bounds.size.height-(250+65))
    {
      scrollView.contentOffset = CGPointMake(0,-65);
    }
    else
    {
      scrollView.contentOffset = CGPointMake(0,(commentsDisplay.view.frame.origin.y+commentsDisplay.view.frame.size.height)-(scrollView.frame.size.height-250-commentInput.view.frame.size.height));
    }
    commentInput.view.frame = CGRectMake(0, self.view.bounds.size.height-commentInput.view.frame.size.height-250, self.view.frame.size.width, commentInput.view.frame.size.height);
}

- (void) commentCancelled
{
    if(commentsDisplay.view.frame.origin.y+commentsDisplay.view.frame.size.height < self.view.bounds.size.height-65)
    {
      scrollView.contentOffset = CGPointMake(0,-65);
    }
    else
    {
      scrollView.contentOffset = CGPointMake(0,(commentsDisplay.view.frame.origin.y+commentsDisplay.view.frame.size.height)-(scrollView.frame.size.height-commentInput.view.frame.size.height));
    }
    commentInput.view.frame = CGRectMake(0, self.view.bounds.size.height-commentInput.view.frame.size.height, self.view.frame.size.width, commentInput.view.frame.size.height);
}

- (void) commentConfirmed:(NSString *)c
{
    NoteComment *nc = [[NoteComment alloc] init];
    nc.note_id = note.note_id;
    nc.user_id = _MODEL_PLAYER_.user_id;
    nc.desc = c;
    [_MODEL_NOTES_ createNoteComment:nc];
    NSMutableArray *newComments = [NSMutableArray arrayWithArray:[_MODEL_NOTES_ noteCommentsForNoteId:note.note_id]];
    [newComments addObject:nc];
    [commentsDisplay setComments:newComments];
    // Reset position
    [self commentCancelled];
}

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) editButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:note mode:NOTE_EDITOR_MODE_TEXT delegate:self] animated:YES];
}

- (void) dismissSelf
{
    [delegate instantiableViewControllerRequestsDismissal:self];
}

- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n
{
    [self.navigationController popToViewController:self animated:YES];
    note = n;
    [self displayDataFromNote];
}

- (void) noteEditorDeletedNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:NO];
    [self dismissSelf];
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
    [self formatSubviews];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

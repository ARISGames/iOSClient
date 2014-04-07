//
//  NoteViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "NoteViewController.h"
#import "NoteComment.h"
#import "NoteTagEditorViewController.h"
#import "NoteCommentsViewController.h"
#import "NoteCommentInputViewController.h"
#import "NoteEditorViewController.h"
#import "ARISMediaView.h"
#import "Note.h"
#import "Player.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISTemplate.h"

@interface NoteViewController () <NoteTagEditorViewControllerDelegate, NoteCommentInputViewControllerDelegate, NoteCommentsViewControllerDelegate, NoteEditorViewControllerDelegate, UIScrollViewDelegate, ARISMediaViewDelegate>
{
    Note *note;
    
    UIView *navView;
    UILabel *title;  
    UILabel *ownerdate; 
    UILabel *tag; 
    UIScrollView *scrollView;  
    UILabel *desc; 
    NSMutableArray *mediaViews;
    NoteCommentInputViewController *commentInput; 
    NoteCommentsViewController *commentsDisplay;
    
    
    id<GameObjectViewControllerDelegate, NoteViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteViewController

- (id) initWithNote:(Note *)n delegate:(id<GameObjectViewControllerDelegate, NoteViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        note = n;
        delegate = d;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataAvailable:) name:@"NoteDataAvailable" object:nil];   
        [[AppModel sharedAppModel].currentGame.notesModel getDetailsForNote:note];
    }
    return self;
}

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
    
    mediaViews = [[NSMutableArray alloc] initWithCapacity:10];
    
    commentInput    = [[NoteCommentInputViewController alloc] initWithDelegate:self];
    commentsDisplay = [[NoteCommentsViewController     alloc] initWithNoteComments:note.comments delegate:self];
    
    [scrollView addSubview:desc];   
    [scrollView addSubview:commentInput.view];   
    [scrollView addSubview:commentsDisplay.view];   
    [self.view addSubview:scrollView];
    
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
    if([AppModel sharedAppModel].player.playerId == note.owner.playerId)
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
    
    if([note.desc length] > 0)
    {
        CGSize descSize = [desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width,9999999) lineBreakMode:NSLineBreakByWordWrapping]; 
        desc.frame = CGRectMake(10,0,self.view.frame.size.width-20,descSize.height+10); 
    }
    else desc.frame = CGRectMake(10,0,self.view.frame.size.width-20,0);  
    
    int curY = desc.frame.origin.y+desc.frame.size.height;
    for(int i = 0; i < [mediaViews count]; i++)
    {
        ((ARISMediaView *)[mediaViews objectAtIndex:i]).frame = CGRectMake(0,curY,self.view.frame.size.width,((ARISMediaView *)[mediaViews objectAtIndex:i]).frame.size.height);
        curY += ((ARISMediaView *)[mediaViews objectAtIndex:i]).frame.size.height;
    }
    
    commentInput.view.frame = CGRectMake(0, curY, self.view.frame.size.width, commentInput.view.frame.size.height);  
    
    if([note.comments count] > 0) commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, commentsDisplay.view.frame.size.height);  
    else                          commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, 0);   
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, commentsDisplay.view.frame.origin.y + commentsDisplay.view.frame.size.height + 216);  
}

- (void) displayDataFromNote
{
    if([note.tags count] > 0) tag.text = ((NoteTag*)[note.tags objectAtIndex:0]).text;
    title.text = note.name;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    ownerdate.text = [NSString stringWithFormat:@"%@ %@",note.owner.displayname,[format stringFromDate:note.created]]; 
    
    desc.text = note.desc;  
    
    NSMutableArray *tmpMediaViews = [[NSMutableArray alloc] initWithCapacity:[mediaViews count]];
    while([mediaViews count] > 0) 
    {
        [[mediaViews objectAtIndex:0] removeFromSuperview];
        [tmpMediaViews addObject:[mediaViews objectAtIndex:0]];
        [mediaViews removeObjectAtIndex:0];
    }
    for(int i = 0; i < [note.contents count]; i++)
    {
        ARISMediaView *amv;
        for(int j = 0; j < [tmpMediaViews count]; j++)
        { 
            //if(((Media *)[note.contents objectAtIndex:i]).mediaId == ((ARISMediaView *)[tmpMediaViews objectAtIndex:j]).media.mediaId)
            if(j == i)
                amv = [tmpMediaViews objectAtIndex:j];
        }
        if(!amv)
        {
            amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,10) delegate:self];
            [amv setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight];
            [amv setMedia:[note.contents objectAtIndex:i]];
        } 
        int y = 0;
        if(i > 0) y = ((ARISMediaView *)[mediaViews objectAtIndex:i-1]).frame.origin.y+((ARISMediaView *)[mediaViews objectAtIndex:i-1]).frame.size.height;
        [amv setFrame:CGRectMake(0,y,self.view.frame.size.width,amv.frame.size.height)]; 
        [mediaViews addObject:amv];
        
        if([((Media *)[note.contents objectAtIndex:i]).type isEqualToString:@"IMAGE"])
           [[mediaViews objectAtIndex:i] addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissComment)]]; 
        [scrollView addSubview:[mediaViews objectAtIndex:i]];   
    }
    
    [commentsDisplay setComments:note.comments];  
    [self formatSubviews];
}

- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv
{
    [self dismissComment];
    return YES;
}

- (void) noteDataAvailable:(NSNotification *)n
{
    if(((Note *)[n.userInfo objectForKey:@"note"]).noteId != note.noteId) return;
    note = [n.userInfo objectForKey:@"note"]; 
    [self displayDataFromNote];
}

- (void) dismissComment
{
    [commentInput dismissKeyboard];
}

- (void) commentBeganEditing
{
    scrollView.contentOffset = CGPointMake(0,(commentInput.view.frame.origin.y+commentInput.view.frame.size.height)-(scrollView.frame.size.height-216));
}

- (void) commentCancelled
{
    //scrollView.contentOffset = CGPointMake(0,-64); 
}

- (void) commentConfirmed:(NSString *)c
{
    [[AppServices sharedAppServices] addComment:c fromPlayer:[AppModel sharedAppModel].player toNote:note];
    NoteComment *nc = [[NoteComment alloc] init];
    nc.noteId = note.noteId; 
    nc.owner = [AppModel sharedAppModel].player;
    nc.text = c;
    [note.comments addObject:nc];
    [commentsDisplay setComments:note.comments];  
    scrollView.contentOffset = CGPointMake(0,-64);   
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
    [delegate gameObjectViewControllerRequestsDismissal:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

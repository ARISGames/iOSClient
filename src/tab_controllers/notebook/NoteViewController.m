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
#import "NoteContentsViewController.h"
#import "NoteCommentsViewController.h"
#import "NoteCommentInputViewController.h"
#import "ARISMediaView.h"
#import "Note.h"
#import "Player.h"
#import "AppModel.h"
#import "AppServices.h"
#import "Game.h"
#import "ARISTemplate.h"

@interface NoteViewController () <NoteTagEditorViewControllerDelegate, NoteContentsViewControllerDelegate, NoteCommentInputViewControllerDelegate, NoteCommentsViewControllerDelegate, UIScrollViewDelegate, ARISMediaViewDelegate>
{
    Note *note;
    
    UIScrollView *scrollView;
    UILabel *title;
    UILabel *owner; 
    UILabel *date; 
    NoteTagEditorViewController *tagsDisplay;
    UILabel *desc; 
    NoteContentsViewController *contentsDisplay;
    NoteCommentInputViewController *commentInput; 
    NoteCommentsViewController *commentsDisplay;
    
    UIView *overlayView;
    
    id<GameObjectViewControllerDelegate, NoteViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteViewController

- (id) initWithNote:(Note *)n delegate:(id<GameObjectViewControllerDelegate, NoteViewControllerDelegate>)d
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
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    scrollView.backgroundColor = [UIColor whiteColor];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.frame.size.width-65,20)];
    title.font = [ARISTemplate ARISTitleFont];
    title.adjustsFontSizeToFitWidth = NO; 
    title.text = note.name;
    
    date  = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
    date.font = [ARISTemplate ARISSubtextFont]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:note.created];
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75,35,self.view.frame.size.width-85,14)];
    owner.font = [ARISTemplate ARISSubtextFont]; 
    owner.textColor = [UIColor ARISColorDarkGray]; 
    owner.adjustsFontSizeToFitWidth = NO;  
    owner.text = note.owner.displayname;
       
    tagsDisplay = [[NoteTagEditorViewController alloc] initWithTags:note.tags editable:NO delegate:self];
    
    desc = [[UILabel alloc] initWithFrame:CGRectMake(10,84,self.view.frame.size.width-20,18)];
    desc.lineBreakMode = NSLineBreakByWordWrapping;
    desc.numberOfLines = 0;
    desc.font = [ARISTemplate ARISBodyFont]; 
    desc.textColor = [UIColor ARISColorDarkGray];  
    desc.text = note.desc;
    
    contentsDisplay = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    commentInput = [[NoteCommentInputViewController alloc] initWithDelegate:self];
    commentsDisplay = [[NoteCommentsViewController alloc] initWithNoteComments:note.comments delegate:self];
    
    [scrollView addSubview:title];
    [scrollView addSubview:owner]; 
    [scrollView addSubview:date]; 
    [scrollView addSubview:tagsDisplay.view]; 
    [scrollView addSubview:desc];  
    [scrollView addSubview:contentsDisplay.view];
    [scrollView addSubview:commentInput.view]; 
    [scrollView addSubview:commentsDisplay.view]; 
    
    [self.view addSubview:scrollView];
    
    [self formatSubviewFrames];
}
    
- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self formatSubviewFrames];
}

- (void) formatSubviewFrames
{
    scrollView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height); 
    title.frame = CGRectMake(10,10,self.view.frame.size.width-65,20); 
    date.frame  = CGRectMake(10,title.frame.origin.y+title.frame.size.height+5,65,14); 
    owner.frame = CGRectMake(75,title.frame.origin.y+title.frame.size.height+5,self.view.frame.size.width-85,14); 
    
    if([note.tags count] > 0) tagsDisplay.view.frame = CGRectMake(0,date.frame.origin.y+date.frame.size.height+5,self.view.frame.size.width,30);  
    else                      tagsDisplay.view.frame = CGRectMake(0,date.frame.origin.y+date.frame.size.height+5,self.view.frame.size.width,0);   
    
    if([note.desc length] > 0) 
    {
        CGSize descSize = [desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width,9999999) lineBreakMode:NSLineBreakByWordWrapping]; 
        desc.frame = CGRectMake(10,tagsDisplay.view.frame.origin.y+tagsDisplay.view.frame.size.height,self.view.frame.size.width-20,descSize.height); 
    }
    else desc.frame = CGRectMake(10,tagsDisplay.view.frame.origin.y+tagsDisplay.view.frame.size.height,self.view.frame.size.width-20,0);  
    
    if([note.contents count] > 0) contentsDisplay.view.frame = CGRectMake(0, desc.frame.origin.y+desc.frame.size.height+10, self.view.frame.size.width, 200); 
    else                          contentsDisplay.view.frame = CGRectMake(0, desc.frame.origin.y+desc.frame.size.height+10, self.view.frame.size.width, 0);  
    
    commentInput.view.frame = CGRectMake(0, contentsDisplay.view.frame.origin.y+contentsDisplay.view.frame.size.height, self.view.frame.size.width, commentInput.view.frame.size.height);  
    
    if([note.comments count] > 0) commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, commentsDisplay.view.frame.size.height);  
    else                          commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, 0);   
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, commentsDisplay.view.frame.origin.y + commentsDisplay.view.frame.size.height + 216); 
}

- (void) noteDataAvailable:(NSNotification *)n
{
    if(((Note *)[n.userInfo objectForKey:@"note"]).noteId != note.noteId) return;
    
    note = [n.userInfo objectForKey:@"note"];
    
    [tagsDisplay setTags:note.tags];  
    
    desc.text = note.desc;
    [self formatSubviewFrames]; 
    
    [contentsDisplay setContents:note.contents]; 
    [commentsDisplay setComments:note.comments]; 
}

- (void) mediaWasSelected:(Media *)m
{
    //A bunch of construction- all should be contained to here, though
    overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 74, self.view.frame.size.width-20, self.view.frame.size.height-84)];
    ARISMediaView *media = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,scroll.frame.size.width,scroll.frame.size.height) media:m mode:ARISMediaDisplayModeAspectFit delegate:self];
    [scroll addSubview:media];
    scroll.contentSize = scroll.frame.size;
    scroll.scrollEnabled = YES;
    scroll.maximumZoomScale = 20;
    scroll.minimumZoomScale = 1; 
    scroll.delegate = self;
    [overlayView addSubview:scroll];
    [overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTouched)]];
    overlayView.opaque = NO;
    overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.85];
    [self.view addSubview:overlayView];
    
    if([m.type isEqualToString:@"VIDEO"] || [m.type isEqualToString:@"AUDIO"]) 
        [media performSelector:@selector(play) withObject:nil afterDelay:1];
}

- (void) overlayTouched
{
    [overlayView removeFromSuperview];
    overlayView = nil;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)s
{
    return [s.subviews objectAtIndex:0];
}

- (void) commentBeganEditing
{
    [self formatSubviewFrames];
    scrollView.contentOffset = CGPointMake(0,(commentInput.view.frame.origin.y+commentInput.view.frame.size.height)-(scrollView.frame.size.height-216));
}

- (void) commentCancelled
{
    [self formatSubviewFrames]; 
    scrollView.contentOffset = CGPointMake(0,-64); 
}

- (void) commentConfirmed:(NSString *)c
{
    [self formatSubviewFrames]; 
    [[AppServices sharedAppServices] addComment:c fromPlayer:[AppModel sharedAppModel].player toNote:note];
    NoteComment *nc = [[NoteComment alloc] init];
    nc.noteId = note.noteId; 
    nc.owner = [AppModel sharedAppModel].player;
    nc.text = c;
    [note.comments addObject:nc];
    [commentsDisplay setComments:note.comments];  
    scrollView.contentOffset = CGPointMake(0,-64);   
}

- (void) ARISMediaViewFinishedPlayback:(ARISMediaView *)amv
{
    [self overlayTouched];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

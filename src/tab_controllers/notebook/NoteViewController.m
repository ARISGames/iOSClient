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
    UIImageView *ownerIcon;    
    UILabel *owner; 
    UILabel *date; 
    UIImageView *tagsIcon;    
    UILabel *tag; 
    UILabel *desc; 
    NoteContentsViewController *contentsDisplay;
    NoteCommentInputViewController *commentInput; 
    NoteCommentsViewController *commentsDisplay;
    
    UIView *overlayView;
    
    UIView *navView;
    UILabel *navTitleLabel; 
    UIView *navTagView;  
    
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
    
    navView = [[UIView alloc] init];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.font = [ARISTemplate ARISBodyFont]; 
    navTitleLabel.textColor = [UIColor ARISColorLightGray]; 
    navTitleLabel.adjustsFontSizeToFitWidth = NO;  
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    navTagView = [[UIView alloc] init];
    tagsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tags.png"]]; 
    tag = [[UILabel alloc] init];
    tag.font = [ARISTemplate ARISBodyFont]; 
    tag.textColor = [UIColor ARISColorLightGray]; 
    tag.adjustsFontSizeToFitWidth = NO;  
    tag.textAlignment = NSTextAlignmentCenter; 
    
    [navTagView addSubview:tagsIcon];
    [navTagView addSubview:tag];
    
    [navView addSubview:navTitleLabel];
    [navView addSubview:navTagView]; 
    
    //need to predict format here otherwise label jumps around
    navView.frame = CGRectMake(0, 0, 200, 64);
    navTitleLabel.frame = CGRectMake(0,0,200,30);
    navTagView.frame = CGRectMake(0,30,200,30);
    tagsIcon.frame = CGRectMake(0,0,20,20);
    tag.frame = CGRectMake(22,0,160,20);  
    self.navigationItem.titleView = navView;   
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    scrollView.backgroundColor = [UIColor whiteColor];
    
    ownerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user.png"]]; 
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75,35,self.view.frame.size.width-85,14)];
    owner.font = [ARISTemplate ARISBodyFont]; 
    owner.textColor = [UIColor ARISColorLightGray]; 
    owner.adjustsFontSizeToFitWidth = NO;  
    
    date = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
    owner.font = [ARISTemplate ARISBodyFont];  
    date.textColor = [UIColor ARISColorLightBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    
    desc = [[UILabel alloc] initWithFrame:CGRectMake(10,84,self.view.frame.size.width-20,18)];
    desc.lineBreakMode = NSLineBreakByWordWrapping;
    desc.numberOfLines = 0;
    desc.font = [ARISTemplate ARISBodyFont]; 
    desc.textColor = [UIColor ARISColorDarkGray];  
    
    contentsDisplay = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    commentInput = [[NoteCommentInputViewController alloc] initWithDelegate:self];
    commentsDisplay = [[NoteCommentsViewController alloc] initWithNoteComments:note.comments delegate:self];
    
    [scrollView addSubview:ownerIcon];  
    [scrollView addSubview:owner]; 
    [scrollView addSubview:date]; 
    [scrollView addSubview:desc];  
    [scrollView addSubview:contentsDisplay.view];
    [scrollView addSubview:commentInput.view]; 
    [scrollView addSubview:commentsDisplay.view]; 
    
    [self.view addSubview:scrollView];
    
    [self displayDataFromNote];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self formatSubviewFrames];
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
}

- (void) formatSubviewFrames
{
    navView.frame = CGRectMake(0, 0, 200, 64);
    navTitleLabel.frame = CGRectMake(0,0,200,30);
    navTagView.frame = CGRectMake(0,30,200,30);
    tagsIcon.frame = CGRectMake(0,0,20,20);
    tag.frame = CGRectMake(22,0,160,20); 
    
    scrollView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height); 
    ownerIcon.frame = CGRectMake(4,4,20,20);
    owner.frame = CGRectMake(30,10,self.view.frame.size.width-30,14); 
    float ownerwidth = [owner.text sizeWithAttributes:@{NSFontAttributeName:owner.font}].width; 
    date.frame  = CGRectMake(30+5+ownerwidth,10,self.view.frame.size.width-(35+ownerwidth),14);  
    
    if([note.desc length] > 0)
    {
        CGSize descSize = [desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width,9999999) lineBreakMode:NSLineBreakByWordWrapping]; 
        desc.frame = CGRectMake(10,35,self.view.frame.size.width-20,descSize.height); 
    }
    else desc.frame = CGRectMake(10,35,self.view.frame.size.width-20,0);  
    
    if([note.contents count] > 0) contentsDisplay.view.frame = CGRectMake(0, desc.frame.origin.y+desc.frame.size.height+10, self.view.frame.size.width, 200); 
    else                          contentsDisplay.view.frame = CGRectMake(0, desc.frame.origin.y+desc.frame.size.height+10, self.view.frame.size.width, 0);  
    
    commentInput.view.frame = CGRectMake(0, contentsDisplay.view.frame.origin.y+contentsDisplay.view.frame.size.height, self.view.frame.size.width, commentInput.view.frame.size.height);  
    
    if([note.comments count] > 0) commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, commentsDisplay.view.frame.size.height);  
    else                          commentsDisplay.view.frame = CGRectMake(0, commentInput.view.frame.origin.y+commentInput.view.frame.size.height, self.view.frame.size.width, 0);   
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, commentsDisplay.view.frame.origin.y + commentsDisplay.view.frame.size.height + 216); 
}

- (void) displayDataFromNote
{
    if([note.tags count] > 0) tag.text = ((NoteTag*)[note.tags objectAtIndex:0]).text;
    navTitleLabel.text = note.name;  
    owner.text = note.owner.displayname; 
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:note.created]; 
    
    desc.text = note.desc;  
    
    [self formatSubviewFrames]; 
    
    [contentsDisplay setContents:note.contents]; 
    [commentsDisplay setComments:note.comments];  
}

- (void) noteDataAvailable:(NSNotification *)n
{
    if(((Note *)[n.userInfo objectForKey:@"note"]).noteId != note.noteId) return;
    note = [n.userInfo objectForKey:@"note"]; 
    [self displayDataFromNote];
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

- (void) backButtonTouched
{
    [self dismissSelf];
}

- (void) dismissSelf
{
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

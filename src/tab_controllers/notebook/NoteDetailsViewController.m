//
//  NoteDetailsViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "NoteEditorViewController.h"
#import "NoteContent.h"
#import "TextViewController.h"
#import "AsyncMediaImageView.h"
#import "Media.h"
#import "NoteCommentViewController.h"
#import "UIImage+Scale.h"
#import "AppServices.h"
#import "AsyncMediaPlayerButton.h"

@interface NoteDetailsViewController() <UIScrollViewDelegate, TextViewControllerDelegate>
{
    Note *note;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UILabel *commentLabel;
    IBOutlet UILabel *likeLabel;
    IBOutlet UIBarButtonItem *likeButton;
    IBOutlet UIBarButtonItem *commentButton;    
}

@property (nonatomic) Note *note;

@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) IBOutlet UILabel *commentLabel;
@property (nonatomic) IBOutlet UILabel *likeLabel;
@property (nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property (nonatomic) IBOutlet UIBarButtonItem *commentButton;;

- (IBAction) commentButtonTouch;
- (IBAction) likeButtonTouch;

@end

@implementation NoteDetailsViewController

@synthesize scrollView,pageControl, note,commentLabel,likeButton,likeLabel,commentButton;

- (id)initWithNote:(Note *)n delegate:(NSObject<GameObjectViewControllerDelegate> *)d
{
    if (self = [super initWithNibName:@"NoteDetailsViewController" bundle:nil])
    {
        delegate = d;

        self.note = n;
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height);
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.exclusiveTouch = NO;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.canCancelContentTouches = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.hidesForSinglePage = YES;
    
    if(![AppModel sharedAppModel].currentGame.allowNoteComments)
    {
        self.commentButton.style = UIBarButtonItemStylePlain;
        self.commentButton.enabled = NO;
        self.commentButton.image = nil;
        self.commentLabel.hidden = YES;
    }
    if(![AppModel sharedAppModel].currentGame.allowNoteLikes)
    {
        self.likeButton.style = UIBarButtonItemStylePlain;
        self.likeButton.enabled = NO;
        self.likeButton.image = nil;
        self.likeLabel.hidden = YES;
    }
    
    if(self.note.creatorId == [AppModel sharedAppModel].player.playerId)
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EditKey", @"") style:UIBarButtonItemStyleDone target:self action:@selector(editButtonTouched)]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouch)]];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self refreshView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void) viewDidDisappear:(BOOL)animated
{
    while([[self.scrollView subviews] count] > 0)
        [[self.scrollView.subviews objectAtIndex:0] removeFromSuperview];
}

- (void) refreshView
{
    [self addFinishedUploadsToNote];
    
    if(![self.note.name isEqualToString:@""]) self.title = self.note.name;
    else                                      self.title = @"Note";
    self.commentLabel.text = [NSString stringWithFormat:@"%d",[self.note.comments count]];
    self.likeLabel.text    = [NSString stringWithFormat:@"%d",self.note.numRatings];
    if(self.note.userLiked) [self.likeButton setStyle:UIBarButtonItemStyleDone];
    else                    [self.likeButton setStyle:UIBarButtonItemStyleBordered];
    
    while([scrollView.subviews count] > 0)
        [[self.scrollView.subviews objectAtIndex:0] removeFromSuperview];
    self.scrollView.frame = self.navigationController.view.frame;
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 0;
    for(int x = 0; x < [self.note.contents count]; x++)
        [self loadNewPageWithContent:[self.note.contents objectAtIndex:x]];
}

- (void) addFinishedUploadsToNote
{    
    for(int x = [self.note.contents count]-1; x >= 0; x--)
    {
        if(![[[self.note.contents objectAtIndex:x] getUploadState] isEqualToString:@"uploadStateDONE"])
            [self.note.contents removeObjectAtIndex:x];
    }
    
    NSMutableDictionary *uploads = [AppModel sharedAppModel].uploadManager.uploadContentsForNotes;
    [self.note.contents addObjectsFromArray:[[uploads objectForKey:[NSNumber numberWithInt:self.note.noteId]] allValues]];
}

- (void) backButtonTouch
{
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) editButtonTouched
{
    NoteEditorViewController *noteVC = [[NoteEditorViewController alloc] initWithNote:self.note inView:nil delegate:self];
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (void) commentButtonTouch
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    NoteCommentViewController *noteCommentVC = [[NoteCommentViewController alloc] initWithNote:self.note delegate:self];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:noteCommentVC animated:NO];
    [UIView commitAnimations];}

- (void) likeButtonTouch
{
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked)
    {
        [[AppServices sharedAppServices]likeNote:self.note.noteId];
        self.note.numRatings++;
        [self.likeButton setStyle:UIBarButtonItemStyleDone];
    }
    else
    {
        [[AppServices sharedAppServices]unLikeNote:self.note.noteId];
        self.note.numRatings--;
        [self.likeButton setStyle:UIBarButtonItemStyleBordered];
    }
    self.likeLabel.text = [NSString stringWithFormat:@"%d",self.note.numRatings];
}

- (void) scrollViewDidScroll:(UIScrollView *)sender
{
    int pageWidth = scrollView.frame.size.width;
    pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void) loadNewPageWithContent:(NoteContent *)content
{    
    if(![content.getType isEqualToString:@"UPLOAD"])
    {
        pageControl.numberOfPages++;
        scrollView.contentSize = CGSizeMake(320 * pageControl.numberOfPages, scrollView.frame.size.height);
        CGRect frame = CGRectMake(scrollView.frame.size.width * (pageControl.numberOfPages-1), 0,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height);
        if([content.getType isEqualToString:@"TEXT"])
        {
            TextViewController *controller = [[TextViewController alloc] initWithNote:self.note content:content inMode:@"preview" delegate:self];
            controller.view.frame = frame;
            [scrollView addSubview:controller.view];
        }
        else if([content.getType isEqualToString:@"PHOTO"])
        {
            [scrollView addSubview:[[AsyncMediaImageView alloc] initWithFrame:frame andMedia:content.getMedia]];
        }
        else if([content.getType isEqualToString:@"AUDIO"] || [content.getType isEqualToString:@"VIDEO"])
            [scrollView addSubview:[[AsyncMediaPlayerButton alloc] initWithFrame:frame media:content.getMedia presentingController:[RootViewController sharedRootViewController] preloadNow:NO]];
    }
}

- (void) textChosen:(NSString *)s
{
    [[[AppModel sharedAppModel] uploadManager] uploadContentForNoteId:self.note.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:s withType:@"TEXT" withFileURL:[NSURL URLWithString:[NSString stringWithFormat:@"%d.txt",((NSString *)[NSString stringWithFormat:@"%@.txt",[NSDate date]]).hash]]];
}

- (void) textUpdated:(NSString *)s forContent:(NoteContent *)c
{
    c.text = s;
    [[AppServices sharedAppServices] updateNoteContent:c.contentId text:s];
}

- (void) textViewControllerCancelled
{
    
}

- (void) movieFinishedCallback:(NSNotification*)aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

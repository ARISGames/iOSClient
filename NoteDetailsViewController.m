//
//  DataCollectionViewController.m
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

@implementation NoteDetailsViewController
@synthesize scrollView,pageControl, delegate, viewControllers,note,commentLabel,likeButton,likeLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [scrollView release];
    [pageControl release];
    [viewControllers release];
    [note release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = self.note.title;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    //scrollView.showsVerticalScrollIndicator = NO;
    //scrollView.scrollsToTop = NO;
    scrollView.userInteractionEnabled = YES;
    scrollView.exclusiveTouch = NO;
    scrollView.canCancelContentTouches = YES;
    scrollView.delaysContentTouches = YES;
    scrollView.delegate = self;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 1;
    self.pageControl.hidesForSinglePage = YES;
    if (self.note.creatorId == [AppModel sharedAppModel].playerId) {
        
    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonTouched)] autorelease]];
    }
    if([self.delegate isKindOfClass:[Note class]]){
        [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouch)] autorelease]];
    }

       self.pageControl.currentPage = 0;
}
-(void)backButtonTouch{
    [self dismissModalViewControllerAnimated:NO];
}
-(void)editButtonTouched{
    NoteEditorViewController *noteVC = [[NoteEditorViewController alloc] initWithNibName:@"NoteEditorViewController" bundle:nil];
    noteVC.note = self.note;
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];

}
-(void)viewWillAppear:(BOOL)animated{

    [self addUploadsToNote];

    self.commentLabel.text = [NSString stringWithFormat:@"%d",[self.note.comments count]];
    self.likeLabel.text = [NSString stringWithFormat:@"%d",self.note.numRatings];
    if(self.note.userLiked) [self.likeButton setStyle:UIBarButtonItemStyleDone];
    else [self.likeButton setStyle:UIBarButtonItemStyleBordered];
    self.title = self.note.title;
    
    while([scrollView.subviews count]>0)
    [[self.scrollView.subviews objectAtIndex:0] removeFromSuperview];
    
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 1;
    self.pageControl.hidesForSinglePage = YES;
    numPages = 0;
    //self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);

    NoteContent *noteContent = [[NoteContent alloc] init];
    if([self.note.contents count] == 0){
        
    }
    else{
        for(int x = 0; x < [self.note.contents count]; x++){
            noteContent = [self.note.contents objectAtIndex:x];
            [self loadNewPageWithContent:noteContent];
        }
    }


}

-(void)addUploadsToNote{
    self.note = [[AppModel sharedAppModel] noteForNoteId: self.note.noteId playerListYesGameListNo:YES];
    for(int x = [self.note.contents count]-1; x >= 0; x--){
        if([[self.note.contents objectAtIndex:x] isUploading])
            [self.note.contents removeObjectAtIndex:x];
    }
    
    NSMutableDictionary *uploads = [AppModel sharedAppModel].uploadManager.uploadContents;
    NSArray *uploadContentForNote = [[uploads objectForKey:[NSNumber numberWithInt:self.note.noteId]]allValues];
    [self.note.contents addObjectsFromArray:uploadContentForNote];
    NSLog(@"NoteEditorVC: Added %d upload content(s) to note",[uploadContentForNote count]);
    
}

-(void)commentButtonTouch{
    [self showComments];
}
-(void)likeButtonTouch{
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked){
        [[AppServices sharedAppServices]likeNote:self.note.noteId];
        self.note.numRatings++;
        [self.likeButton setStyle:UIBarButtonItemStyleDone];
    }
    else{
        [[AppServices sharedAppServices]unLikeNote:self.note.noteId];
        self.note.numRatings--;
        [self.likeButton setStyle:UIBarButtonItemStyleBordered];
    }
    self.likeLabel.text = [NSString stringWithFormat:@"%d",self.note.numRatings];

}
-(void)shareButtonTouch{
    
}
-(void)showComments{
    NoteCommentViewController *noteCommentVC = [[NoteCommentViewController alloc]initWithNibName:@"NoteCommentViewController" bundle:nil];
    noteCommentVC.parentNote = self.note;
    noteCommentVC.delegate = self;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:noteCommentVC animated:NO];
    [UIView commitAnimations]; 

}
- (void)scrollViewDidScroll:(UIScrollView *)sender {

    int pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    pageControl.numberOfPages = numPages;
   }

-(void)saveButtonTouchAction{
   //[self displayTitleandDescriptionForm];
}
- (void)loadNewPageWithContent:(NoteContent *)content{
    
    if(![content.getType isEqualToString:@"UPLOAD"]){
    numPages++;
    scrollView.contentSize = CGSizeMake(320 * numPages, scrollView.frame.size.height);
    pageControl.numberOfPages = numPages;
        CGRect frame = CGRectMake( scrollView.frame.size.width * (numPages-1), 0, 
                                  scrollView.frame.size.width, 
                                  scrollView.frame.size.height);
    if([content.getType isEqualToString:kNoteContentTypeText]){
      TextViewController *controller = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        controller.previewMode = YES;
        controller.textToDisplay = content.getText;
        controller.title = self.note.title;
        [viewControllers addObject:controller];
            controller.view.frame = frame;
            [scrollView addSubview:controller.view];
        [controller release];

    }
    else if([content.getType isEqualToString:kNoteContentTypePhoto]){
        
            AsyncMediaImageView *controller = [[AsyncMediaImageView alloc] initWithFrame:frame andMedia:content.getMedia];
 
            [viewControllers addObject:controller];
            [scrollView addSubview:controller];
            [controller release];

    }
        else if([content.getType isEqualToString:kNoteContentTypeAudio] || [content.getType isEqualToString:kNoteContentTypeVideo]){

            AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:frame media:content.getMedia presentingController:self];
                                                   
            [viewControllers addObject:mediaButton];
            [scrollView addSubview:mediaButton];
                
            [mediaButton release];

        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)changePage:(id)sender{
    
}

@end

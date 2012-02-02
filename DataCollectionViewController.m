//
//  DataCollectionViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataCollectionViewController.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "NoteViewController.h"
#import "NoteContent.h"
#import "TextViewController.h"
#import "AsyncImageView.h"
#import "Media.h"
#import "ARISMoviePlayerViewController.h"
#import "NoteCommentViewController.h"
#import "UIImage+Scale.h"
#import "AppServices.h"

@implementation DataCollectionViewController
@synthesize scrollView,pageControl, delegate, viewControllers,note,commentLabel,likeButton,likeLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];

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
    NoteViewController *noteVC = [[NoteViewController alloc] initWithNibName:@"NoteViewController" bundle:nil];
    noteVC.note = self.note;
    noteVC.delegate = self;
    [self.navigationController pushViewController:noteVC animated:YES];

}
-(void)viewWillAppear:(BOOL)animated{
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

-(IBAction)playMovie:(id)sender {
    [[[viewControllers objectAtIndex:[sender tag]] moviePlayer] play];

	[self presentMoviePlayerViewControllerAnimated:[viewControllers objectAtIndex:[sender tag]]];
}
-(void)movieThumbDidFinish:(NSNotification*) aNotification
{
    NSDictionary *userInfo = aNotification.userInfo;
    UIImage *videoThumb = [userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    NSError *e = [userInfo objectForKey:MPMoviePlayerThumbnailErrorKey];
    NSNumber *time = [userInfo objectForKey:MPMoviePlayerThumbnailTimeKey];
    MPMoviePlayerController *player = aNotification.object;
    UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(320, 240)];        

    for(int i = 0; i < [self.viewControllers count]; i++){
        if([[self.viewControllers objectAtIndex:i] isKindOfClass:[ARISMoviePlayerViewController class]]){
            if( [[[self.viewControllers objectAtIndex:i] moviePlayer] isEqual:player]){
                
                [[[self.viewControllers objectAtIndex:i] mediaPlaybackButton] setBackgroundImage:videoThumbSized forState:UIControlStateNormal];

            }
        }
                                                                                                         
    }
    
      if (e) {
        //NSLog(@"MPMoviePlayerThumbnail ERROR: %@",e);
    }
}
- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	NSLog(@"ItemDetailsViewController: movieFinishedCallback");
	[self dismissMoviePlayerViewControllerAnimated];
}
-(void)saveButtonTouchAction{
   //[self displayTitleandDescriptionForm];
}
- (void)loadNewPageWithContent:(NoteContent *)content{
    if(![content.type isEqualToString:@"UPLOAD"]){
    numPages++;
    scrollView.contentSize = CGSizeMake(320 * numPages, scrollView.frame.size.height);
    pageControl.numberOfPages = numPages;
    if([content.type isEqualToString:@"TEXT"]){
      TextViewController *controller = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        controller.previewMode = YES;
        controller.textToDisplay = content.text;
        controller.title = self.note.title;
        [viewControllers addObject:controller];
        [controller release];
        if (nil == controller.view.superview) {
            CGRect frame = scrollView.frame;
            frame.origin.x = frame.size.width * (numPages-1);
            frame.origin.y = 0;
            controller.view.frame = frame;
            [scrollView addSubview:controller.view];}
    }
    else if([content.type isEqualToString:@"PHOTO"]){
        AsyncImageView *controller = [[AsyncImageView alloc] init];
        Media *m = [[Media alloc]init];
        m = [[AppModel sharedAppModel] mediaForMediaId:content.mediaId];
        [controller loadImageFromMedia:m];
            [viewControllers addObject:controller];
            [controller release];
            //[m release];
            if (nil == controller.superview) {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * (numPages-1);
                frame.origin.y = 0;
                controller.frame = frame;
                [scrollView addSubview:controller];}
        }
        else if([content.type isEqualToString:@"AUDIO"] || [content.type isEqualToString:@"VIDEO"]){
            //Setup the Button
            Media *media = [[Media alloc] init];
            media = [[AppModel sharedAppModel] mediaForMediaId:content.mediaId];
            UIButton *mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
            mediaPlaybackButton.tag = [viewControllers count];//the tag of the button is now equal to the corresponding movieplayers index into the viewControllers array...used in playMovie:
            [mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
            [mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
            
            //Create movie player object
         ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
            mMoviePlayer.moviePlayer.shouldAutoplay = NO;
           // [mMoviePlayer.moviePlayer prepareToPlay];
            
            //Setup the overlay
            UIImageView *playButonOverlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_button.png"]];
            playButonOverlay.center = mediaPlaybackButton.center;
            [viewControllers addObject:mMoviePlayer];
            
            //Create a thumbnail for the button
            if([content.type isEqualToString:@"VIDEO"]){
            if (![mediaPlaybackButton backgroundImageForState:UIControlStateNormal]) {
               /* UIImage *videoThumb = [mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];            
                UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(320, 240)];        
                [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];*/
                NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
                NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
                [mMoviePlayer.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
                
                NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
                [dispatcher addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];

            }
            }
            else {
                [mediaPlaybackButton setBackgroundImage:[UIImage imageNamed:@"microphoneBackground.jpg"] forState:UIControlStateNormal];
                mediaPlaybackButton.contentMode = UIViewContentModeScaleAspectFill;
            }
            
            if (nil == mediaPlaybackButton.superview) {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * (numPages-1);
                frame.origin.y = 0;
                mediaPlaybackButton.frame = CGRectMake(frame.origin.x, frame.origin.y, 320, playButonOverlay.frame.size.height);
                [mediaPlaybackButton addSubview:playButonOverlay];
                [scrollView addSubview:mediaPlaybackButton];
                

            }

            mMoviePlayer.mediaPlaybackButton = mediaPlaybackButton;
            [mediaPlaybackButton release];
            [playButonOverlay release];
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

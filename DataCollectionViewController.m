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

@implementation DataCollectionViewController
@synthesize scrollView,pageControl, delegate, viewControllers,note;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Add Media";
        viewControllers = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    //scrollView.showsVerticalScrollIndicator = NO;
    //scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = numPages;
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"Comments" style:UIBarButtonItemStylePlain target:self action:@selector(showComments)] autorelease]];
}
-(void)viewWillAppear:(BOOL)animated{
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
-(void)showComments{
    NoteCommentViewController *noteCommentVC = [[NoteCommentViewController alloc]initWithNibName:@"NoteCommentViewController" bundle:nil];
    noteCommentVC.parentNote = self.note;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:self.navigationController.view cache:YES];
    [self.navigationController pushViewController:noteCommentVC animated:NO];
    [UIView commitAnimations]; 

}
- (void)scrollViewDidScroll:(UIScrollView *)sender {

    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    pageControl.numberOfPages = numPages;
    
   }

-(void)saveButtonTouchAction{
   //[self displayTitleandDescriptionForm];
}
- (void)loadNewPageWithContent:(NoteContent *)content{

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
            if (nil == controller.superview) {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * (numPages-1);
                frame.origin.y = 0;
                controller.frame = frame;
                [scrollView addSubview:controller];}
        }
        else if([content.type isEqualToString:@"AUDIO"]){
                AudioRecorderViewController *controller = [[AudioRecorderViewController alloc] initWithNibName:@"AudioRecorderViewController" bundle:nil];
            Media *m = [[Media alloc]init];
            m = [[AppModel sharedAppModel] mediaForMediaId:content.mediaId];
            controller.delegate = self;
            controller.previewMode = YES;
            controller.soundFileURL = [NSURL URLWithString:m.url];
                [viewControllers addObject:controller];
                [controller release];
                if (nil == controller.view.superview) {
                    CGRect frame = scrollView.frame;
                    frame.origin.x = frame.size.width * (numPages-1);
                    frame.origin.y = 0;
                    controller.view.frame = frame;
                    [scrollView addSubview:controller.view];
                }
        }
        else if([content.type isEqualToString:@"VIDEO"]){
            Media *media = [[Media alloc] init];
            media = [[AppModel sharedAppModel] mediaForMediaId:content.mediaId];
            
            //Create movie player object
            ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
            mMoviePlayer.moviePlayer.shouldAutoplay = NO;
            [mMoviePlayer.moviePlayer prepareToPlay];		
            [viewControllers addObject:mMoviePlayer];
            [mMoviePlayer release];

            if (nil == mMoviePlayer.view.superview) {
                CGRect frame = scrollView.frame;
                frame.origin.x = frame.size.width * (numPages-1);
                frame.origin.y = 0;
                mMoviePlayer.view.frame = frame;
                [scrollView addSubview:mMoviePlayer.view];
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

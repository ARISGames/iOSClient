//
//  NoteDetailsViewController.h
//  ARIS
//
//  Created by Brian Thiel on 8/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "NoteContent.h"
#import "ARISMoviePlayerViewController.h"

@interface NoteDetailsViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    id __unsafe_unretained delegate;
    int pageNumber;
    int numPages;
   // UIButton *mediaPlaybackButton;
    IBOutlet UILabel *commentLabel;
    IBOutlet UILabel *likeLabel;
    
    //ARISMoviePlayerViewController *mMoviePlayer;
    Note *note;
    IBOutlet UIBarButtonItem *likeButton;
    IBOutlet UIBarButtonItem *commentButton;

}
@property(nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property(nonatomic) IBOutlet UIBarButtonItem *commentButton;;

@property(nonatomic, unsafe_unretained) id delegate;
@property(nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic) IBOutlet UILabel *commentLabel;
@property(nonatomic) IBOutlet UILabel *likeLabel;

@property(nonatomic)Note *note;
- (IBAction)saveButtonTouchAction;
- (IBAction)changePage:(id) sender;
- (void)loadNewPageWithContent:(NoteContent<NoteContentProtocol> *)content;
- (void)showComments;
- (IBAction)playMovie:(id)sender;
-(void)editButtonTouched;
-(IBAction)shareButtonTouch;
-(IBAction)commentButtonTouch;
-(IBAction)likeButtonTouch;
-(void)backButtonTouch;
-(void)movieThumbDidFinish:(NSNotification*) aNotification;
-(void)addUploadsToNote;

@end

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

@interface NoteDetailsViewController : GameObjectViewController <UIScrollViewDelegate> {
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
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

@property(nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic) IBOutlet UILabel *commentLabel;
@property(nonatomic) IBOutlet UILabel *likeLabel;

@property(nonatomic)Note *note;

- (id)initWithNote:(Note *)n delegate:(NSObject<GameObjectViewControllerDelegate> *)d;

- (IBAction)saveButtonTouchAction;
- (IBAction)changePage:(id) sender;
- (void)loadNewPageWithContent:(NoteContent *)content;
- (void)showComments;
-(void)editButtonTouched;
-(IBAction)shareButtonTouch;
-(IBAction)commentButtonTouch;
-(IBAction)likeButtonTouch;
-(void)backButtonTouch;
-(void)addUploadsToNote;

@end

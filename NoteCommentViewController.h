//
//  NoteCommentViewController.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "CameraViewController.h"
#import "AudioRecorderViewController.h"
#import "SCRRatingView.h"

@interface NoteCommentViewController : UIViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>
{
    IBOutlet UITableView *commentTable;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *addAudioButton;
    IBOutlet UIButton *addMediaFromAlbumButton;
    IBOutlet UIButton *addTextButton;
    IBOutlet UITextView *textBox;
    Note *parentNote;
    Note *commentNote;
    int rating;
    NSIndexPath *myIndexPath;
    BOOL commentValid;
    BOOL photoIconUsed, videoIconUsed, audioIconUsed,currNoteHasPhoto,currNoteHasAudio,currNoteHasVideo;
    UIView *inputView;
    UIBarButtonItem *hideKeyboardButton,*addCommentButton;
    id __unsafe_unretained delegate;
    NSMutableArray *movieViews;
    NSMutableDictionary *asyncMediaDict;
}

@property (nonatomic) IBOutlet UITableView *commentTable;

@property (nonatomic) IBOutlet UIButton *addPhotoButton;
@property (nonatomic) IBOutlet UIButton *addAudioButton;
@property (nonatomic) IBOutlet UIButton *addTextButton;
@property (nonatomic) IBOutlet UIButton *addMediaFromAlbumButton;
@property (nonatomic) IBOutlet UITextView *textBox;
@property (nonatomic) Note *parentNote;
@property (nonatomic) Note *commentNote;
@property (nonatomic) NSIndexPath *myIndexPath;
@property (readwrite,assign) int rating;
@property (readwrite,assign) BOOL commentValid;
@property (readwrite,assign) BOOL photoIconUsed;
@property (readwrite,assign) BOOL audioIconUsed;
@property (readwrite,assign) BOOL videoIconUsed;
@property (readwrite,assign) BOOL currNoteHasPhoto;
@property (readwrite,assign) BOOL currNoteHasAudio;
@property (readwrite,assign) BOOL currNoteHasVideo;
@property (nonatomic) IBOutlet UIView *inputView;
@property (nonatomic) UIBarButtonItem *addCommentButton;
@property (nonatomic) UIBarButtonItem *hideKeyboardButton;
@property (readwrite,unsafe_unretained) id delegate;
@property (nonatomic) NSMutableArray *movieViews;
@property (nonatomic) NSMutableDictionary *asyncMediaDict;

- (IBAction) addPhotoButtonTouchAction;
- (IBAction) addAudioButtonTouchAction;
- (IBAction) addTextButtonTouchAction;
- (IBAction) addMediaFromAlbumButtonTouchAction;
- (void) addedVideo;
- (void) addedAudio;
- (void) addedText;
- (void) addedPhoto;
- (void) showKeyboard;
- (void) hideKeyboard;
- (int) calculateTextHeight:(NSString *)text;
- (void) refreshViewFromModel;
- (void) addUploadsToComments;

@end

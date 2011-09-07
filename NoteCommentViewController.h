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

@interface NoteCommentViewController : UIViewController <UITextViewDelegate>{
    IBOutlet UITableView *commentTable;
    IBOutlet UIButton *addPhotoButton;
    IBOutlet UIButton *addAudioButton;
    IBOutlet UIButton *addMediaFromAlbumButton;
    IBOutlet UITextView *textBox;
    Note *parentNote;
    Note *commentNote;
    int rating;
    NSIndexPath *myIndexPah;
}
@property(nonatomic, retain)IBOutlet UITableView *commentTable;
@property(nonatomic, retain)IBOutlet UIButton *addPhotoButton;
@property(nonatomic, retain)IBOutlet UIButton *addAudioButton;
@property(nonatomic, retain)IBOutlet UIButton *addMediaFromAlbumButton;
@property(nonatomic, retain)IBOutlet UITextView *textBox;
@property(nonatomic, retain)Note *parentNote;
@property(nonatomic, retain)Note *commentNote;
@property(nonatomic, retain)NSIndexPath *myIndexPath;
@property(readwrite, assign)int rating;

-(IBAction)addPhotoButtonTouchAction;
-(IBAction)addAudioButtonTouchAction;
-(IBAction)addMediaFromAlbumButtonTouchAction;
-(void)addedVideo;
-(void)addedAudio;
-(void)addedText;
-(void)addedPhoto;
@end

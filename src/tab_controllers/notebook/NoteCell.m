//
//  NoteCell.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCell.h"
#import "Note.h"
#import "AppServices.h"

@interface NoteCell() <UITextViewDelegate>
{
    Note *note;
    
    IBOutlet UITextView *titleLabel;
    IBOutlet UIImageView *mediaIcon1;
    IBOutlet UIImageView *mediaIcon2;
    IBOutlet UIImageView *mediaIcon3;
    IBOutlet UIImageView *mediaIcon4;
    IBOutlet UILabel *likeLabel;
    
    IBOutlet UIButton *likesButton;
    IBOutlet UILabel *commentsLbl;
    IBOutlet UILabel *holdLbl;
    
    id __unsafe_unretained delegate;
}

@property (nonatomic) Note *note;
@property (nonatomic) IBOutlet UITextView *titleLabel;
@property (nonatomic) IBOutlet UIImageView *mediaIcon1;
@property (nonatomic) IBOutlet UIImageView *mediaIcon2;
@property (nonatomic) IBOutlet UIImageView *mediaIcon3;
@property (nonatomic) IBOutlet UIImageView *mediaIcon4;
@property (nonatomic) IBOutlet UILabel *likeLabel;
@property (nonatomic) IBOutlet UIButton *likesButton;
@property (nonatomic) IBOutlet UILabel *commentsLbl;
@property (nonatomic) IBOutlet UILabel *holdLbl;

- (IBAction) likeButtonTouched;

@end

@implementation NoteCell

@synthesize note;
@synthesize titleLabel;
@synthesize mediaIcon1;
@synthesize mediaIcon2;
@synthesize mediaIcon3;
@synthesize mediaIcon4;
@synthesize likeLabel;
@synthesize likesButton;
@synthesize commentsLbl;
@synthesize holdLbl;

- (void) setupWithNote:(Note *)n delegate:(id)d
{
    self.note = n;
    delegate = d;

    if(self.note.creatorId == [AppModel sharedAppModel].player.playerId)
        [holdLbl addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdTextBox:)]];
    [self.titleLabel setUserInteractionEnabled:NO];

    
    if([self.note.comments count] == 0)
    {
        self.commentsLbl.text = @"";
        [self.likesButton setFrame:CGRectMake(self.likesButton.frame.origin.x, 14, self.likesButton.frame.size.width, self.likesButton.frame.size.height)];
        [self.likeLabel   setFrame:CGRectMake(self.likeLabel.frame.origin.x,   26, self.likeLabel.frame.size.width,   self.likeLabel.frame.size.height)];
    }
    else
    {
        self.commentsLbl.text = [NSString stringWithFormat:@"%d %@",[self.note.comments count],NSLocalizedString(@"NotebookCommentsKey", @"")];
        [self.likesButton setFrame:CGRectMake(self.likesButton.frame.origin.x, 2,  self.likesButton.frame.size.width, self.likesButton.frame.size.height)];
        [self.likeLabel   setFrame:CGRectMake(self.likeLabel.frame.origin.x,   14, self.likeLabel.frame.size.width,   self.likeLabel.frame.size.height)];
    }
    self.likeLabel.text = [NSString stringWithFormat:@"%d",self.note.numRatings];
    if(self.note.userLiked) self.likesButton.selected = YES;
    self.titleLabel.text = self.note.name;
    if([self.note.contents count] == 0 && (self.note.creatorId != [AppModel sharedAppModel].player.playerId))
        self.userInteractionEnabled = NO;
    
    BOOL videoIconUsed = NO;
    BOOL photoIconUsed = NO;
    BOOL audioIconUsed = NO;
    BOOL textIconUsed  = NO;
    for(int x = 0; x < [self.note.contents count]; x++)
    {
        if([[(NoteContent *)[self.note.contents objectAtIndex:x] type] isEqualToString:@"TEXT"]&& !textIconUsed)
        {
            textIconUsed = YES;
            if     (self.mediaIcon1.image == nil) self.mediaIcon1.image = [UIImage imageNamed:@"noteicon.png"];
            else if(self.mediaIcon2.image == nil) self.mediaIcon2.image = [UIImage imageNamed:@"noteicon.png"];
            else if(self.mediaIcon3.image == nil) self.mediaIcon3.image = [UIImage imageNamed:@"noteicon.png"];
            else if(self.mediaIcon4.image == nil) self.mediaIcon4.image = [UIImage imageNamed:@"noteicon.png"];
        }
        else if ([[(NoteContent *)[self.note.contents objectAtIndex:x] type] isEqualToString:@"PHOTO"]&& !photoIconUsed)
        {
            photoIconUsed = YES;
            if     (self.mediaIcon1.image == nil) self.mediaIcon1.image = [UIImage imageNamed:@"defaultImageIcon.png"];
            else if(self.mediaIcon2.image == nil) self.mediaIcon2.image = [UIImage imageNamed:@"defaultImageIcon.png"];
            else if(self.mediaIcon3.image == nil) self.mediaIcon3.image = [UIImage imageNamed:@"defaultImageIcon.png"];
            else if(self.mediaIcon4.image == nil) self.mediaIcon4.image = [UIImage imageNamed:@"defaultImageIcon.png"];
        }
        else if([[(NoteContent *)[self.note.contents objectAtIndex:x] type] isEqualToString:@"AUDIO"] && !audioIconUsed)
        {
            audioIconUsed = YES;
            if     (self.mediaIcon1.image == nil) self.mediaIcon1.image = [UIImage imageNamed:@"defaultAudioIcon.png"];
            else if(self.mediaIcon2.image == nil) self.mediaIcon2.image = [UIImage imageNamed:@"defaultAudioIcon.png"];
            else if(self.mediaIcon3.image == nil) self.mediaIcon3.image = [UIImage imageNamed:@"defaultAudioIcon.png"];
            else if(self.mediaIcon4.image == nil) self.mediaIcon4.image = [UIImage imageNamed:@"defaultAudioIcon.png"];
        }
        else if([[(NoteContent *)[self.note.contents objectAtIndex:x] type] isEqualToString:@"VIDEO"] && !videoIconUsed)
        {
            videoIconUsed = YES;
            if     (self.mediaIcon1.image == nil) self.mediaIcon1.image = [UIImage imageNamed:@"defaultVideoIcon.png"];
            else if(self.mediaIcon2.image == nil) self.mediaIcon2.image = [UIImage imageNamed:@"defaultVideoIcon.png"];
            else if(self.mediaIcon3.image == nil) self.mediaIcon3.image = [UIImage imageNamed:@"defaultVideoIcon.png"];
            else if(self.mediaIcon4.image == nil) self.mediaIcon4.image = [UIImage imageNamed:@"defaultVideoIcon.png"];
        }
    }
    
    if(![AppModel sharedAppModel].currentGame.allowNoteLikes)
    {
        self.likesButton.enabled = NO;
        self.likeLabel.hidden = YES;
        self.likesButton.hidden = YES;
    }
}

- (void) likeButtonTouched
{
    self.likesButton.selected = !self.likesButton.selected;
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked)
    {
        [[AppServices sharedAppServices] likeNote:self.note.noteId];
        self.note.numRatings++;
    }
    else
    {
        [[AppServices sharedAppServices] unLikeNote:self.note.noteId];
        self.note.numRatings--;
    }
    likeLabel.text = [NSString stringWithFormat:@"%d",note.numRatings];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:NSLocalizedString(@"NodeEditorNewNoteKey", @"")]) textView.text = @"";
    return YES;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];  
        self.note.name = textView.text;
        
        [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:textView.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];

        return NO;
    }
    if([text isEqualToString:@"\b"]) return YES;
    if([textView.text length] > 20)  return NO;
    return YES;
}

- (void) holdTextBox:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStatePossible || gestureRecognizer.state == UIGestureRecognizerStateRecognized)
    {
        [self.titleLabel setEditable:YES];
        [self.titleLabel becomeFirstResponder];
    }
    else
        [self.titleLabel setUserInteractionEnabled:NO];
}

@end

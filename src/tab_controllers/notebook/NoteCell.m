//
//  NoteCell.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCell.h"
#import "AppServices.h"
#import "NotebookViewController.h"

@implementation NoteCell
@synthesize titleLabel,mediaIcon1,mediaIcon2,mediaIcon3,mediaIcon4,commentsLbl,likeLabel,holdLbl,note,index,delegate,likesButton;

- (void) awakeFromNib
{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(holdTextBox:)];
    NotebookViewController *nVC = (NotebookViewController *)self.delegate;
    if([AppModel sharedAppModel].isGameNoteList)
    {
        if([(Note *)[nVC.gameNoteList objectAtIndex:self.index] creatorId] == [AppModel sharedAppModel].player.playerId)
            [holdLbl addGestureRecognizer:gesture];
    }
    else
    {
        if([(Note *)[nVC.noteList objectAtIndex:self.index] creatorId] == [AppModel sharedAppModel].player.playerId)
            [holdLbl addGestureRecognizer:gesture];
    }

    //[holdLbl addGestureRecognizer:gesture];
    [self.titleLabel setUserInteractionEnabled:NO];
}

- (void) likeButtonTouched
{
    self.likesButton.selected = !self.likesButton.selected;
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked)
    {
        [[AppServices sharedAppServices]likeNote:self.note.noteId];
        self.note.numRatings++;
    }
    else
    {
        [[AppServices sharedAppServices]unLikeNote:self.note.noteId];
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
        NotebookViewController *nVC = (NotebookViewController *)self.delegate;
        if([AppModel sharedAppModel].isGameNoteList )
            ((Note *)[nVC.gameNoteList objectAtIndex:self.index]).name = textView.text;
        else
            ((Note *)[nVC.noteList     objectAtIndex:self.index]).name = textView.text;
        
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

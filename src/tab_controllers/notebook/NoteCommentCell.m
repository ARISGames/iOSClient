//
//  NoteCommentCell.m
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NoteCommentCell.h"
#import "AppServices.h"

@implementation NoteCommentCell
@synthesize titleLabel,mediaIcon2,mediaIcon3,mediaIcon4,userLabel,likesButton,note,likeLabel,retryButton,spinner;

-(void)initCell
{
    if(self.note.userLiked) self.likesButton.selected = YES;
    else                    self.likesButton.selected = NO;
    likeLabel.text = [NSString stringWithFormat:@"%d",self.note.numRatings];  
}

-(void)checkForRetry
{
    if ((self.note.contents.count > 0)&&![[[self.note.contents objectAtIndex:0] getUploadState] isEqualToString:@"uploadStateDONE"])
    {
        retryButton.hidden = NO;
        
        [self.titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 147, titleLabel.frame.size.height)];
        
        if([[[self.note.contents objectAtIndex:0] getUploadState] isEqualToString:@"uploadStateFAILED"])
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"Retry" forState: UIControlStateNormal];
            self.retryButton.userInteractionEnabled = YES;

            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self.retryButton setFrame:CGRectMake(228, 15, 80, 30)];
            [spinner stopAnimating];
            spinner.hidden = YES;
            
        }
        else if([[[self.note.contents objectAtIndex:0] getUploadState] isEqualToString:@"uploadStateQUEUED"])
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Waiting" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(208, 15, 100, 30)];
            self.retryButton.userInteractionEnabled = NO;

            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [spinner startAnimating];
            spinner.hidden = NO;
        }
        else
        {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Uploading" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(187, 15, 121, 30)];
            self.retryButton.userInteractionEnabled = NO;

            [spinner startAnimating];
            spinner.hidden = NO;
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    else
    {
        
        retryButton.hidden = YES;
        [self.titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 235, titleLabel.frame.size.height)];
        [spinner stopAnimating];
        spinner.hidden = YES;
    }
}

-(void)retryUpload
{    
    retryButton.hidden = YES;
    [self.titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 235, titleLabel.frame.size.height)];    
    [spinner startAnimating];
    spinner.hidden = NO;
    //[[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:self.content.getNoteId andFileURL:self.content.getMedia.url];
    NoteContent *noteC = [self.note.contents objectAtIndex:0];
    NSLog(@"Deleting Upload forNoteId:%d withFileURL:%@",noteC.getNoteId,noteC.getMedia.url);
    [[AppModel sharedAppModel].uploadManager uploadContentForNoteId:noteC.getNoteId withTitle:noteC.getTitle withText:noteC.getText withType:noteC.getType withFileURL:[NSURL URLWithString:noteC.getMedia.url]];
    NSLog(@"Retrying Upload forNoteId:%d withTitle:%@ withText:%@ withType:%@ withFileURL:%@",noteC.getNoteId,noteC.getTitle,noteC.getText,noteC.getType,noteC.getMedia.url);
    [self checkForRetry];
}

-(void)likeButtonTouched
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

@end

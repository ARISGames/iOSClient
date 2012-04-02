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
@synthesize titleLabel,mediaIcon1,mediaIcon2,mediaIcon3,mediaIcon4,starView,commentsLbl,likeLabel,holdLbl,note,index,delegate,likesButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)awakeFromNib{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(holdTextBox:)];
    NotebookViewController *nVC = (NotebookViewController *)self.delegate;
    if([AppModel sharedAppModel].isGameNoteList ){
        if([(Note *)[nVC.gameNoteList objectAtIndex:self.index] creatorId] == [AppModel sharedAppModel].playerId){
            [holdLbl addGestureRecognizer:gesture];
        }

    }
    else{
        if([(Note *)[nVC.noteList objectAtIndex:self.index] creatorId] == [AppModel sharedAppModel].playerId){
            [holdLbl addGestureRecognizer:gesture];

        }


    }

    //[holdLbl addGestureRecognizer:gesture];
    [self.titleLabel setUserInteractionEnabled:NO];

}
-(void)likeButtonTouched{
    self.likesButton.selected = !self.likesButton.selected;
    self.note.userLiked = !self.note.userLiked;
    if(self.note.userLiked){
        [[AppServices sharedAppServices]likeNote:self.note.noteId];
        self.note.numRatings++;
    }
    else{
        [[AppServices sharedAppServices]unLikeNote:self.note.noteId];
        self.note.numRatings--;
    }
    likeLabel.text = [NSString stringWithFormat:@"%d",note.numRatings];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    //[textView resignFirstResponder];
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //[self.titleLabel setUserInteractionEnabled:NO];
   // [textView resignFirstResponder];
    return YES;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"New Note"])
        textView.text = @"";
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
       // [self.titleLabel setUserInteractionEnabled:NO];
        [textView resignFirstResponder];  
        NotebookViewController *nVC = (NotebookViewController *)self.delegate;
        if([AppModel sharedAppModel].isGameNoteList ){
            [(Note *)[nVC.gameNoteList objectAtIndex:self.index]setTitle:textView.text];
        }
        else{
            [(Note *)[nVC.noteList objectAtIndex:self.index]setTitle:textView.text];
        }
        
        [[AppServices sharedAppServices] updateNoteWithNoteId:self.note.noteId title:textView.text publicToMap:self.note.showOnMap publicToList:self.note.showOnList];

        return NO;
    }
    if([text isEqualToString:@"\b"]) return  YES;
    if([textView.text length] > 20) return NO;
    return YES;
}
-(void)holdTextBox:(UIPanGestureRecognizer *) gestureRecognizer{

    if(gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStatePossible || gestureRecognizer.state == UIGestureRecognizerStateRecognized){
        //textbox has been held down so now do some stuff
        [self.titleLabel setEditable:YES];
        //[self.titleLabel setUserInteractionEnabled:YES];
        [self.titleLabel becomeFirstResponder];
    }
    else{
        [self.titleLabel setUserInteractionEnabled:NO];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc
{
    NSLog(@"NoteCell: Dealloc");
    
               
}



@end

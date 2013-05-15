//
//  NoteContentCell.m
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteContentCell.h"
#import "AppServices.h"
#import "NoteEditorViewController.h"
#import "AppModel.h"

@implementation NoteContentCell
@synthesize titleLbl,detailLbl,imageView,holdLbl,contentId,index,delegate,content,retryButton,spinner,parentTableView,indexPath;

-(void)awakeFromNib{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(holdTextBox:)];
    [holdLbl addGestureRecognizer:gesture];
    [self.titleLbl setUserInteractionEnabled:NO];
    
}

-(void)checkForRetry{
    if(![self.content respondsToSelector:@selector(getUploadState)] || ![[self.content getUploadState] isEqualToString:@"uploadStateDONE"]) {
        retryButton.hidden = NO;
        self.titleLbl.userInteractionEnabled = NO;
        self.holdLbl.userInteractionEnabled = NO;
        [self.titleLbl setFrame:CGRectMake(65, 4, 147, 30)];
        self.titleLbl.hidden = YES;
        if([[(UploadContent *)self.content getUploadState] isEqualToString:@"uploadStateFAILED"]){
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"blue_button.png"] forState:UIControlStateNormal];
            self.retryButton.userInteractionEnabled = YES;
            [self.retryButton setTitle: @"Retry" forState: UIControlStateNormal];
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self.retryButton setFrame:CGRectMake(228, 15, 80, 30)];
            [spinner stopAnimating];
            spinner.hidden = YES;
            
        }
        else if([[self.content getUploadState] isEqualToString:@"uploadStateQUEUED"]){
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Waiting" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(208, 15, 100, 30)];
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.retryButton.userInteractionEnabled = NO;
            [spinner startAnimating];
            spinner.hidden = NO;
        }
        else {
            [self.retryButton setBackgroundImage:[UIImage imageNamed:@"grey_button.png"] forState:UIControlStateNormal];
            [self.retryButton setTitle: @"  Uploading" forState: UIControlStateNormal];
            [self.retryButton setFrame:CGRectMake(187, 15, 121, 30)];
            self.retryButton.userInteractionEnabled = NO;
            
            [spinner startAnimating];
            spinner.hidden = NO;
            self.retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    else {
        self.titleLbl.hidden = NO;
        self.titleLbl.userInteractionEnabled = YES;
        self.holdLbl.userInteractionEnabled = YES;
        
        retryButton.hidden = YES;
        [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
        [spinner stopAnimating];
        spinner.hidden = YES;
    }
}

-(void)retryUpload{
    
    retryButton.hidden = YES;
    [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
    [spinner startAnimating];
    spinner.hidden = NO;
    NSLog(@"Deleting Upload forNoteId:%d withFileURL:%@",self.content.getNoteId,self.content.getMedia.url);
    [[AppModel sharedAppModel].uploadManager uploadContentForNoteId:self.content.getNoteId withTitle:self.content.getTitle withText:self.content.getText withType:self.content.getType withFileURL:[NSURL URLWithString:self.content.getMedia.url]];
    NSLog(@"Retrying Upload forNoteId:%d withTitle:%@ withText:%@ withType:%@ withFileURL:%@",self.content.getNoteId,self.content.getTitle,self.content.getText,self.content.getType,self.content.getMedia.url);
    [self checkForRetry];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    //[textView resignFirstResponder];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //[self.titleLabel setUserInteractionEnabled:NO];
    // [textView resignFirstResponder];
    [self.parentTableView setFrame:CGRectMake(self.parentTableView.frame.origin.x, self.parentTableView.frame.origin.y, self.parentTableView.frame.size.width, 261)];
    return YES;
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        // [self.titleLabel setUserInteractionEnabled:NO];
        [textView resignFirstResponder];  
        NoteEditorViewController *nVC = (NoteEditorViewController *)self.delegate;
        [[nVC.note.contents objectAtIndex:self.index]setTitle:textView.text];
        [[AppServices sharedAppServices] updateNoteContent:self.contentId title:textView.text];
        
        return NO;
    }
    if([textView.text length] > 24) textView.text = [textView.text substringToIndex:24];
    return YES;
}

-(void)holdTextBox:(UIPanGestureRecognizer *) gestureRecognizer{
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStatePossible || gestureRecognizer.state == UIGestureRecognizerStateRecognized){
        //textbox has been held down so now do some stuff
        [self.titleLbl setEditable:YES];
        //[self.titleLabel setUserInteractionEnabled:YES];
        [self.titleLbl becomeFirstResponder];
        [self.parentTableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.parentTableView setFrame:CGRectMake(self.parentTableView.frame.origin.x, self.parentTableView.frame.origin.y, self.parentTableView.frame.size.width, 160)];
    }
    else{
        [self.titleLbl setUserInteractionEnabled:NO];
    }
}

-(void)dealloc{
    NSLog(@"NoteContentCell: Dealloc");
    
    
}
@end

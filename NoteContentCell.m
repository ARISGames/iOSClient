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
@synthesize titleLbl,detailLbl,imageView,holdLbl,contentId,index,delegate,content,retryButton,spinner;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)awakeFromNib{
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(holdTextBox:)];
    [holdLbl addGestureRecognizer:gesture];
    [gesture release];
    [self.titleLbl setUserInteractionEnabled:NO];
    
}
-(void)checkForRetry{
    if (self.content.isUploading) {

        if([(UploadContent *)self.content attemptFailed]){
            retryButton.hidden = NO;
            [spinner stopAnimating];
            spinner.hidden = YES;
            [self.titleLbl setFrame:CGRectMake(65, 4, 147, 30)];
            [self.titleLbl setText:@"Upload Failed"];
        }
        else {
            [self.titleLbl setText:@"Media Uploading"];

            retryButton.hidden = YES;
            [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
            [spinner startAnimating];
            spinner.hidden = NO;
        }
    }
    else {
        
        retryButton.hidden = YES;
        [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
        [spinner stopAnimating];
        spinner.hidden = YES;
    }
}
-(void)retryUpload{
    [self.titleLbl setText:@"Media Uploading"];
    
    retryButton.hidden = YES;
    [self.titleLbl setFrame:CGRectMake(65, 4, 235, 30)];
    [spinner startAnimating];
    spinner.hidden = NO;
    //[[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:self.content.getNoteId andFileURL:self.content.getMedia.url];
     NSLog(@"Deleting Upload forNoteId:%d withFileURL:%@",self.content.getNoteId,self.content.getMedia.url);
    [[AppModel sharedAppModel].uploadManager uploadContentForNoteId:self.content.getNoteId withTitle:self.content.getTitle withText:self.content.getText withType:self.content.getType withFileURL:self.content.getMedia.url];
     NSLog(@"Retrying Upload forNoteId:%d withTitle:%@ withText:%@ withType:%@ withFileURL:%@",self.content.getNoteId,self.content.getTitle,self.content.getText,self.content.getType,self.content.getMedia.url);
    //[self checkForRetry];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    //[textView resignFirstResponder];
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    //[self.titleLabel setUserInteractionEnabled:NO];
    // [textView resignFirstResponder];
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
    }
    else{
        [self.titleLbl setUserInteractionEnabled:NO];
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end

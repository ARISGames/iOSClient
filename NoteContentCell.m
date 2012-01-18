//
//  NoteContentCell.m
//  ARIS
//
//  Created by Brian Thiel on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteContentCell.h"
#import "AppServices.h"
#import "NoteViewController.h"

@implementation NoteContentCell
@synthesize titleLbl,detailLbl,imageView,holdLbl,contentId,index,delegate;
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
        NoteViewController *nVC = (NoteViewController *)self.delegate;
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

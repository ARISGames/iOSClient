//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"
#import "Note.h"
#import "TitleAndDecriptionFormViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "NoteViewController.h"

@implementation TextViewController
@synthesize textBox,noteId,keyboardButton,textToDisplay,editMode,contentId,delegate,previewMode;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Add Text";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [textBox release];
    [keyboardButton release];
    [textToDisplay release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    if(editMode){
    
        self.textBox.text = textToDisplay;
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateContentTouchAction)];      
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    else{
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouchAction)];      
        self.navigationItem.rightBarButtonItem = saveButton;        
    }
    if(self.previewMode)  {
        self.textBox.userInteractionEnabled = NO;
        self.textBox.text = self.textToDisplay;
    }
  
    
    // Do any additional setup after loading the view from its nib.
    /*if(self.note)
    self.title = self.note.name;
    UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Keyboard" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
	self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    if(self.note && ([AppModel sharedAppModel].playerId != self.note.creatorId)) self.textBox.userInteractionEnabled = NO;
     */
}
-(void)viewWillAppear:(BOOL)animated{
    if(previewMode){
        self.textBox.userInteractionEnabled = NO;
        self.textBox.text = textToDisplay;
        self.textBox.frame = CGRectMake(0, 0, 320, 367);

    }
  else self.textBox.frame = CGRectMake(0, 0, 320, 330);
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
-(void)updateContentTouchAction{
    //server call here
    [[AppServices sharedAppServices]updateNoteContent:self.contentId text:self.textBox.text];

    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([self.textBox.text isEqualToString:@"Write note here..."])
    [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
    self.keyboardButton.hidden = NO;
}
-(void)hideKeyboard {
    [self.textBox resignFirstResponder];
    if(!previewMode)
    self.textBox.frame = CGRectMake(0, 0, 320, 330);
    else self.textBox.frame = CGRectMake(0, 0, 320, 367);
    self.keyboardButton.hidden = YES;
}

-(void)saveButtonTouchAction{
    
//Do server call here
    [[AppServices sharedAppServices] addContentToNoteWithText:self.textBox.text type:@"TEXT" mediaId:0 andNoteId:self.noteId];
    if([self.delegate isKindOfClass:[NoteViewController class]]) {
        [self.delegate setNoteValid:YES];
        [self.delegate setNoteChanged:YES];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:YES];
    [self.navigationController popViewControllerAnimated:NO];
    
    [UIView commitAnimations]; 
}

@end

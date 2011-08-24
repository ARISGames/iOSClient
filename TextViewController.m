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

@implementation TextViewController
@synthesize textBox,saveButton,noteId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Note";
        self.tabBarItem.image = [UIImage imageNamed:@"noteicon.png"];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
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
    // Do any additional setup after loading the view from its nib.
    /*if(self.note)
    self.title = self.note.name;
    UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Keyboard" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
	self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    if(self.note && ([AppModel sharedAppModel].playerId != self.note.creatorId)) self.textBox.userInteractionEnabled = NO;
     */
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
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([self.textBox.text isEqualToString:@"Write note here..."])
    [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
}
-(void)hideKeyboard {
    [self.textBox resignFirstResponder];
    self.textBox.frame = CGRectMake(0, 0, 320, 330);
}

-(void)saveButtonTouchAction{
    [self.saveButton setBackgroundColor:[UIColor lightGrayColor]];
    
//Do server call here
    [[AppServices sharedAppServices] addContentToNoteWithText:self.textBox.text type:@"TEXT" mediaId:0 andNoteId:self.noteId];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:YES];
    [self.navigationController popViewControllerAnimated:NO];
    
    [UIView commitAnimations]; 
}

@end

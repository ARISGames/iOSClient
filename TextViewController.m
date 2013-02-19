//
//  NoteViewController.m
//  ARIS
//
//  Created by Brian Thiel on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextViewController.h"
#import "Note.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "NoteEditorViewController.h"
#import "NotebookViewController.h"

@implementation TextViewController
@synthesize textBox,noteId,keyboardButton,textToDisplay,editMode,contentId,backView,previewMode,index,editView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TextViewTitleKey", @"");
    }
    return self;
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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey", @"")
                                                                   style: UIBarButtonItemStyleBordered
                                                                  target:self 
                                                                  action:@selector(backButtonTouchAction)];
    
    self.navigationItem.leftBarButtonItem = backButton;
	    if(self.editMode){
    
        self.textBox.text = self.textToDisplay;
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"" )style:UIBarButtonItemStylePlain target:self action:@selector(updateContentTouchAction)];      
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    else{
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouchAction)];      
        self.navigationItem.rightBarButtonItem = saveButton;    
    }
    if(self.previewMode)  {
        self.textBox.userInteractionEnabled = NO;
        self.textBox.text = self.textToDisplay;
    }
    if([self.backView isKindOfClass:[NoteEditorViewController class]] || [self.backView isKindOfClass:[NotebookViewController class]]) {

    [self.textBox becomeFirstResponder];
    }
    else self.textBox.userInteractionEnabled = NO;
    // Do any additional setup after loading the view from its nib.
    /*if(self.note)
    self.title = self.note.name;
    UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Keyboard" style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
	self.navigationItem.rightBarButtonItem = hideKeyboardButton;
    if(self.note && ([AppModel sharedAppModel].playerId != self.note.creatorId)) self.textBox.userInteractionEnabled = NO;
     */
}
-(void)backButtonTouchAction{
    if([backView isKindOfClass:[NotebookViewController class]]){
    [[AppServices sharedAppServices]deleteNoteWithNoteId:self.noteId];
    [[AppModel sharedAppModel].playerNoteList removeObjectForKey:[NSNumber numberWithInt:self.noteId]];   
    }
    [self.navigationController popToViewController:self.backView animated:NO];   
}
-(void)viewWillAppear:(BOOL)animated{
    if(previewMode){
        self.textBox.userInteractionEnabled = NO;
        self.textBox.text = self.textToDisplay;
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

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

-(void)updateContentTouchAction{
    //server call here
   NSMutableArray *noteC = [[AppModel sharedAppModel] noteForNoteId:self.noteId playerListYesGameListNo:YES].contents;
    for(int i = 0; i < noteC.count; i++){
        if(((NoteContent *)[noteC objectAtIndex:i]).contentId == self.contentId){
            NSLog(@"TextViewBefore: %@", ((NoteContent *)[noteC objectAtIndex:i]).text);
            ((NoteContent *)[noteC objectAtIndex:i]).text = self.textBox.text;
            NSLog(@"TextViewAfter: %@", ((NoteContent *)[noteC objectAtIndex:i]).text);
        }
    }
    [[AppServices sharedAppServices]updateNoteContent:self.contentId text:self.textBox.text];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([self.textBox.text isEqualToString:@"Write note here..."])
    [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
    //self.keyboardButton.hidden = NO;
}
-(void)hideKeyboard {
    [self.textBox resignFirstResponder];
    if(!previewMode)
    self.textBox.frame = CGRectMake(0, 0, 320, 330);
    else self.textBox.frame = CGRectMake(0, 0, 320, 367);
   // self.keyboardButton.hidden = YES;
}

-(void)saveButtonTouchAction{
    
//Do server call here
    if([self.editView isKindOfClass:[NoteEditorViewController class]]) {
        [self.editView setNoteValid:YES];
        [self.editView setNoteChanged:YES];
         
    }
    NSString *urlString = [NSString stringWithFormat:@"%@.txt",[NSDate date]];
    urlString = [NSString stringWithFormat:@"%d.txt",urlString.hash];
    NSURL *url = [NSURL URLWithString:urlString];
    [[[AppModel sharedAppModel] uploadManager]uploadContentForNoteId:self.noteId withTitle:[NSString stringWithFormat:@"%@",[NSDate date]] withText:self.textBox.text withType:kNoteContentTypeText withFileURL:url];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:YES];
    [self.navigationController popViewControllerAnimated:NO];
    
    [UIView commitAnimations]; 
}

@end

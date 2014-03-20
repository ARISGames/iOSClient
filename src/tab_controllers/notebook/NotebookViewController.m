//
//  NotebookViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NotebookViewController.h"
#import "NotebookNotesViewController.h"
#import "NoteViewController.h"
#import "NoteEditorViewController.h"
#import "NoteTagSelectorViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Color.h"

#import "AppModel.h"
#import "Game.h"
#import "ARISTemplate.h"
#import "CircleButton.h"

@interface NotebookViewController() <GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate, NotebookNotesViewControllerDelegate, NoteTagSelectorViewControllerDelegate>
{
    UIView *navTitleView;
    UILabel *navTitleLabel;
    
    CircleButton *newTextButton;
    CircleButton *newAudioButton; 
    CircleButton *newImageButton; 
    CircleButton *newVideoButton; 
    UILabel *allNotesButton;
    UILabel *myNotesButton; 
    UILabel *labelSelectorButton;  
    NotebookNotesViewController *notesViewController;
    NoteTagSelectorViewController *noteTagSelectorViewController; 
}

@end

@implementation NotebookViewController

- (id) initWithDelegate:(id<GamePlayTabBarViewControllerDelegate, NotebookViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"NOTE"; 
        self.tabIconName = @"notebook";
        self.title = NSLocalizedString(@"NotebookTitleKey",@""); 
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    navTitleView = [[UIView alloc] init];
    
    navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.text = @"Notebook";
    navTitleLabel.textAlignment = NSTextAlignmentCenter; 
    
    [navTitleView addSubview:navTitleLabel];
    self.navigationItem.titleView = navTitleView;  
                         
    UIColor *fc = [UIColor whiteColor];
    UIColor *sc = [UIColor blackColor]; 
    UIColor *tc = [UIColor blackColor]; 
    int sw = 2;
    
    newTextButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
    [newTextButton setTitle:@"t" forState:UIControlStateNormal];
    [newTextButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    [newTextButton addTarget:self action:@selector(newTextButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    newAudioButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newAudioButton setTitle:@"a" forState:UIControlStateNormal]; 
    [newAudioButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [newAudioButton addTarget:self action:@selector(newAudioButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    newImageButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newImageButton setTitle:@"i" forState:UIControlStateNormal]; 
    [newImageButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [newImageButton addTarget:self action:@selector(newImageButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    
    newVideoButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newVideoButton setTitle:@"v" forState:UIControlStateNormal]; 
    [newVideoButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    [newVideoButton addTarget:self action:@selector(newVideoButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    
    [self.view addSubview:newTextButton];  
    [self.view addSubview:newAudioButton];  
    [self.view addSubview:newImageButton];  
    [self.view addSubview:newVideoButton];  
    
    allNotesButton = [[UILabel alloc] init]; 
    allNotesButton.text = @"All";
    allNotesButton.font = [ARISTemplate ARISButtonFont]; 
    allNotesButton.userInteractionEnabled = YES;
    [allNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allNotesButtonTouched)]]; 
    [self.view addSubview:allNotesButton];
    
    myNotesButton = [[UILabel alloc] init];
    myNotesButton.text = @"Mine";
    myNotesButton.font = [ARISTemplate ARISButtonFont];
    myNotesButton.userInteractionEnabled = YES; 
    [myNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myNotesButtonTouched)]];
    [self.view addSubview:myNotesButton]; 
    
    labelSelectorButton = [[UILabel alloc] init];
    labelSelectorButton.text = @"Labels";
    labelSelectorButton.font = [ARISTemplate ARISButtonFont];
    labelSelectorButton.userInteractionEnabled = YES; 
    [labelSelectorButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSelectorButtonTouched)]];
    [self.view addSubview:labelSelectorButton];  
    
    notesViewController = [[NotebookNotesViewController alloc] initWithDelegate:self];
    noteTagSelectorViewController = [[NoteTagSelectorViewController alloc] initWithDelegate:self]; 
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    navTitleView.frame        = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
    navTitleLabel.frame       = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height); 
    
    int buttonPadding = ((self.view.frame.size.width/4)-30)/2; 
    newTextButton.frame  = CGRectMake(buttonPadding*1+30*0, 84, 30, 30);
    newAudioButton.frame = CGRectMake(buttonPadding*3+30*1, 84, 30, 30); 
    newImageButton.frame = CGRectMake(buttonPadding*5+30*2, 84, 30, 30); 
    newVideoButton.frame = CGRectMake(buttonPadding*7+30*3, 84, 30, 30); 
    
    allNotesButton.frame      = CGRectMake(10, 124, self.view.frame.size.width-20, 30); 
    myNotesButton.frame       = CGRectMake(10, 164, self.view.frame.size.width-20, 30); 
    labelSelectorButton.frame = CGRectMake(10, 204, self.view.frame.size.width-20, 30);  
    
    while([allNotesButton.subviews count]      > 0) [[allNotesButton.subviews      objectAtIndex:0] removeFromSuperview];
    while([myNotesButton.subviews count]       > 0) [[myNotesButton.subviews       objectAtIndex:0] removeFromSuperview]; 
    while([labelSelectorButton.subviews count] > 0) [[labelSelectorButton.subviews objectAtIndex:0] removeFromSuperview]; 
       
    UIImageView *i;
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,10,20,20); 
    [allNotesButton addSubview:i];
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,10,20,20); 
    [myNotesButton addSubview:i]; 
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,10,20,20); 
    [labelSelectorButton addSubview:i]; 
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [self.navigationController popToViewController:self animated:YES];    
}

- (void) addNote
{
    NoteEditorViewController *nevc = [[NoteEditorViewController alloc] initWithNote:nil delegate:self];
    [self.navigationController pushViewController:nevc animated:YES]; 
}

- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n
{
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) newTextButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:YES];
}

- (void) newAudioButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:YES];
}

- (void) newImageButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:YES];
}

- (void) newVideoButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil delegate:self] animated:YES];
}

- (void) allNotesButtonTouched
{
    [notesViewController setModeAll];
    [self.navigationController pushViewController:notesViewController animated:YES]; 
}

- (void) myNotesButtonTouched
{
    [notesViewController setModeMine];
    [self.navigationController pushViewController:notesViewController animated:YES];
}

- (void) labelSelectorButtonTouched
{
    [self.navigationController pushViewController:noteTagSelectorViewController animated:YES];
}

- (void) notesViewControllerRequestsDismissal:(NotebookNotesViewController *)n
{
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) noteTagSelectorViewControllerRequestsDismissal:(NoteTagSelectorViewController *)n
{
    [self.navigationController popToViewController:self animated:YES];  
}

- (void) noteTagSelectorViewControllerSelectedTag:(NoteTag *)t
{
    [self.navigationController popToViewController:self animated:NO];  
    [notesViewController setModeTag:t];
    [self.navigationController pushViewController:notesViewController animated:YES]; 
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

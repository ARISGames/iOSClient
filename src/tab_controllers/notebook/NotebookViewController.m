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

@interface NotebookViewController() <GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate, NotebookNotesViewControllerDelegate, NoteTagSelectorViewControllerDelegate>
{
    UIView *navTitleView;
    UILabel *navTitleLabel;
    
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
    
    allNotesButton.frame      = CGRectMake(10, 84, self.view.frame.size.width-20, 30); 
    myNotesButton.frame       = CGRectMake(10, 124, self.view.frame.size.width-20, 30); 
    labelSelectorButton.frame = CGRectMake(10, 164, self.view.frame.size.width-20, 30);  
    
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

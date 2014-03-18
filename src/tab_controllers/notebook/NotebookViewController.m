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

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Color.h"

#import "AppModel.h"
#import "Game.h"
#import "ARISTemplate.h"

@interface NotebookViewController() <GameObjectViewControllerDelegate, NoteViewControllerDelegate, NoteEditorViewControllerDelegate, NotebookNotesViewControllerDelegate>
{
    UIView *navTitleView;
    UILabel *navTitleLabel;
    
    UIButton *allNotesButton;
    UIButton *myNotesButton; 
    NotebookNotesViewController *notesViewController;
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
       
    allNotesButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [allNotesButton setTitle:@"All" forState:UIControlStateNormal]; 
    [allNotesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allNotesButton.titleLabel setFont:[ARISTemplate ARISButtonFont]]; 
    allNotesButton.titleLabel.textAlignment = NSTextAlignmentLeft;  
    [allNotesButton addTarget:self action:@selector(allNotesButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:allNotesButton];
    
    myNotesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myNotesButton setTitle:@"Mine" forState:UIControlStateNormal];
    [myNotesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal]; 
    [myNotesButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
    myNotesButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [myNotesButton addTarget:self action:@selector(myNotesButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    [self.view addSubview:myNotesButton]; 
    
    notesViewController = [[NotebookNotesViewController alloc] initWithDelegate:self];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    navTitleView.frame   = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
    navTitleLabel.frame  = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height); 
    allNotesButton.frame = CGRectMake(10, 84, self.view.frame.size.width-20, 30); 
    myNotesButton.frame  = CGRectMake(10, 124, self.view.frame.size.width-20, 30); 
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

- (void) notesViewControllerRequestsDismissal:(NotebookNotesViewController *)n
{
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

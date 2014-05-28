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
    
    UIView *fakeNavBG;
    UIView *line1;
    UIView *line2; 
    UIView *line3; 
    UIView *line4; 
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
    navTitleLabel.font = [ARISTemplate ARISTitleFont];
    navTitleLabel.text = NSLocalizedString(@"NotebookTitleKey", @"");
    navTitleLabel.textAlignment = NSTextAlignmentCenter; 
    
    [navTitleView addSubview:navTitleLabel];
    self.navigationItem.titleView = navTitleView;  
                         
    fakeNavBG = [[UIView alloc] init]; fakeNavBG.backgroundColor = [UIColor colorWithRed:0xF8/(float)0xFF green:0xF8/(float)0xFF blue:0xF8/(float)0xFF alpha:1.0];  
    line1 = [[UIView alloc] init]; line1.backgroundColor = [UIColor ARISColorLightGray]; 
    line2 = [[UIView alloc] init]; line2.backgroundColor = [UIColor ARISColorLightGray]; 
    line3 = [[UIView alloc] init]; line3.backgroundColor = [UIColor ARISColorLightGray]; 
    line4 = [[UIView alloc] init]; line4.backgroundColor = [UIColor ARISColorLightGray]; 
    
    [self.view addSubview:fakeNavBG]; 
    [self.view addSubview:line1];
    [self.view addSubview:line2]; 
    [self.view addSubview:line3]; 
    [self.view addSubview:line4]; 
    
    
    UIColor *fc = [UIColor whiteColor];
    UIColor *sc = [UIColor blackColor]; 
    UIColor *tc = [UIColor blackColor]; 
    int sw = 1;
    
    newTextButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
    [newTextButton setImage:[UIImage imageNamed:@"notebook.png"] forState:UIControlStateNormal];
    [newTextButton addTarget:self action:@selector(newTextButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    newAudioButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newAudioButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal]; 
    [newAudioButton addTarget:self action:@selector(newAudioButtonTouched) forControlEvents:UIControlEventTouchUpInside]; 
    
    newImageButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newImageButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];  
    [newImageButton addTarget:self action:@selector(newImageButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    
    newVideoButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw]; 
    [newVideoButton setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];   
    [newVideoButton addTarget:self action:@selector(newVideoButtonTouched) forControlEvents:UIControlEventTouchUpInside];  
    
    [self.view addSubview:newTextButton];  
    [self.view addSubview:newAudioButton];  
    [self.view addSubview:newImageButton];  
    [self.view addSubview:newVideoButton];  
    
    allNotesButton = [[UILabel alloc] init];
    allNotesButton.text = [NSString stringWithFormat:@"        %@", NSLocalizedString(@"NotebookAllNotesKey", @"")];
    allNotesButton.font = [ARISTemplate ARISButtonFont]; 
    allNotesButton.userInteractionEnabled = YES;
    [allNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allNotesButtonTouched)]]; 
    
    myNotesButton = [[UILabel alloc] init];
    myNotesButton.text = [NSString stringWithFormat:@"        %@", NSLocalizedString(@"NotebookMyNotesKey", @"")];
    myNotesButton.font = [ARISTemplate ARISButtonFont];
    myNotesButton.userInteractionEnabled = YES; 
    [myNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myNotesButtonTouched)]];
    
    labelSelectorButton = [[UILabel alloc] init];
    labelSelectorButton.text = [NSString stringWithFormat:@"        %@", NSLocalizedString(@"LabelsKey", @"")];
    labelSelectorButton.font = [ARISTemplate ARISButtonFont];
    labelSelectorButton.userInteractionEnabled = YES; 
    [labelSelectorButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSelectorButtonTouched)]];
    
    [self.view addSubview:allNotesButton];
    [self.view addSubview:myNotesButton]; 
    [self.view addSubview:labelSelectorButton];     
    
    notesViewController = [[NotebookNotesViewController alloc] initWithDelegate:self];
    noteTagSelectorViewController = [[NoteTagSelectorViewController alloc] initWithDelegate:self]; 
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    navTitleView.frame        = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
    navTitleLabel.frame       = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height); 
    
    int buttonDiameter = 50;
    int buttonPadding = ((self.view.frame.size.width/4)-buttonDiameter)/2; 
    newTextButton.frame  = CGRectMake(buttonPadding*1+buttonDiameter*0, 69, buttonDiameter, buttonDiameter);
    newAudioButton.frame = CGRectMake(buttonPadding*3+buttonDiameter*1, 69, buttonDiameter, buttonDiameter); 
    newImageButton.frame = CGRectMake(buttonPadding*5+buttonDiameter*2, 69, buttonDiameter, buttonDiameter); 
    newVideoButton.frame = CGRectMake(buttonPadding*7+buttonDiameter*3, 69, buttonDiameter, buttonDiameter); 
    
    allNotesButton.frame      = CGRectMake(10, 134, self.view.frame.size.width-20, 30); 
    myNotesButton.frame       = CGRectMake(10, 174, self.view.frame.size.width-20, 30); 
    labelSelectorButton.frame = CGRectMake(10, 214, self.view.frame.size.width-20, 30);  
    
    while(allNotesButton.subviews.count      > 0) [[allNotesButton.subviews      objectAtIndex:0] removeFromSuperview];
    while(myNotesButton.subviews.count       > 0) [[myNotesButton.subviews       objectAtIndex:0] removeFromSuperview]; 
    while(labelSelectorButton.subviews.count > 0) [[labelSelectorButton.subviews objectAtIndex:0] removeFromSuperview]; 
       
    UIImageView *i;
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward.png"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,7,20,20); 
    [allNotesButton addSubview:i];
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cabinet.png"]];
    i.contentMode = UIViewContentModeScaleAspectFit; 
    i.frame = CGRectMake(5,7,20,20);  
    [allNotesButton addSubview:i]; 
    
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward.png"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,7,20,20); 
    [myNotesButton addSubview:i]; 
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notebook.png"]];
    i.contentMode = UIViewContentModeScaleAspectFit;  
    i.frame = CGRectMake(5,7,20,20);   
    [myNotesButton addSubview:i];  
    
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForward.png"]];
    i.frame = CGRectMake(self.view.frame.size.width-20-20,7,20,20); 
    [labelSelectorButton addSubview:i]; 
    i = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tags.png"]];
    i.contentMode = UIViewContentModeScaleAspectFit;   
    i.frame = CGRectMake(5,7,20,20);    
    [labelSelectorButton addSubview:i];  
    
    fakeNavBG.frame = CGRectMake(0,0,self.view.bounds.size.width,129);   
    line1.frame = CGRectMake(0,129,self.view.bounds.size.width,1);  
    line2.frame = CGRectMake(0,169,self.view.bounds.size.width,1);   
    line3.frame = CGRectMake(0,209,self.view.bounds.size.width,1);   
    line4.frame = CGRectMake(0,249,self.view.bounds.size.width,1);       
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.translucent = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = YES;
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [self.navigationController popToViewController:self animated:YES];    
}

- (void) noteEditorCancelledNoteEdit:(NoteEditorViewController *)ne
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) noteEditorConfirmedNoteEdit:(NoteEditorViewController *)ne note:(Note *)n
{
    [self.navigationController popToViewController:self animated:YES]; 
}

- (void) noteEditorDeletedNoteEdit:(NoteEditorViewController *)ne //behave the same as cancelled
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) newTextButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_TEXT delegate:self] animated:YES];
}

- (void) newAudioButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_AUDIO delegate:self] animated:YES]; 
}

- (void) newImageButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_IMAGE delegate:self] animated:YES]; 
}

- (void) newVideoButtonTouched
{
    [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_VIDEO delegate:self] animated:YES]; 
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
    _ARIS_NOTIF_IGNORE_ALL_(self);                     
}

@end

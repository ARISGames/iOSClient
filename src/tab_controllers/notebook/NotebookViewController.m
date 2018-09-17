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

#import "AppModel.h"
#import "Game.h"
#import "CircleButton.h"
#import <Google/Analytics.h>


@interface NotebookViewController() <InstantiableViewControllerDelegate, NoteEditorViewControllerDelegate, NotebookNotesViewControllerDelegate, NoteTagSelectorViewControllerDelegate>
{
  Tab *tab;

  UIView *navTitleView;
  UILabel *navTitleLabel;

  CircleButton *newTextButton;
  CircleButton *newAudioButton;
  CircleButton *newCameraButton;
  CircleButton *newRollButton;

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

  id<NotebookViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NotebookViewController

- (id) initWithTab:(Tab *)t delegate:(id<NotebookViewControllerDelegate>)d
{
  if(self = [super init])
  {
    tab = t;
    delegate = d;
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
  navTitleLabel.text = self.tabTitle;
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
  long sw = 1;

  newTextButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
  [newTextButton setImage:[UIImage imageNamed:@"notebook.png"] forState:UIControlStateNormal];
  [newTextButton addTarget:self action:@selector(newTextButtonTouched) forControlEvents:UIControlEventTouchUpInside];

  newAudioButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
  [newAudioButton setImage:[UIImage imageNamed:@"microphone.png"] forState:UIControlStateNormal];
  [newAudioButton addTarget:self action:@selector(newAudioButtonTouched) forControlEvents:UIControlEventTouchUpInside];

  newCameraButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
  [newCameraButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
  [newCameraButton addTarget:self action:@selector(newCameraButtonTouched) forControlEvents:UIControlEventTouchUpInside];

  newRollButton = [[CircleButton alloc] initWithFillColor:fc strokeColor:sc titleColor:tc disabledFillColor:tc disabledStrokeColor:tc disabledtitleColor:tc strokeWidth:sw];
  [newRollButton setImage:[UIImage imageNamed:@"roll.png"] forState:UIControlStateNormal];
  [newRollButton addTarget:self action:@selector(newRollButtonTouched) forControlEvents:UIControlEventTouchUpInside];

  [self.view addSubview:newTextButton];
  [self.view addSubview:newAudioButton];
  [self.view addSubview:newCameraButton];
  [self.view addSubview:newRollButton];

  NSString *spacing = @"        "; // yes, really

  allNotesButton = [[UILabel alloc] init];
  allNotesButton.text = [NSString stringWithFormat:@"%@%@", spacing, NSLocalizedString(@"NotebookAllNotesKey", @"")];
  allNotesButton.font = [ARISTemplate ARISButtonFont];
  allNotesButton.userInteractionEnabled = YES;
  [allNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(allNotesButtonTouched)]];

  myNotesButton = [[UILabel alloc] init];
  myNotesButton.text = [NSString stringWithFormat:@"%@%@", spacing, NSLocalizedString(@"NotebookMyNotesKey", @"")];
  myNotesButton.font = [ARISTemplate ARISButtonFont];
  myNotesButton.userInteractionEnabled = YES;
  [myNotesButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myNotesButtonTouched)]];

  labelSelectorButton = [[UILabel alloc] init];
  labelSelectorButton.text = [NSString stringWithFormat:@"%@%@", spacing, NSLocalizedString(@"LabelsKey", @"")];
  labelSelectorButton.font = [ARISTemplate ARISButtonFont];
  labelSelectorButton.userInteractionEnabled = YES;
  [labelSelectorButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelSelectorButtonTouched)]];

  [self.view addSubview:allNotesButton];
  [self.view addSubview:myNotesButton];
  if([_MODEL_TAGS_ tags].count) [self.view addSubview:labelSelectorButton];

  notesViewController = [[NotebookNotesViewController alloc] initWithDelegate:self];
  noteTagSelectorViewController = [[NoteTagSelectorViewController alloc] initWithDelegate:self];
}

- (void) viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  navTitleView.frame  = CGRectMake(self.view.bounds.size.width/2-80, 5, 160, 35);
  navTitleLabel.frame = CGRectMake(0, 0, navTitleView.frame.size.width, navTitleView.frame.size.height);

  long buttonDiameter = 50;
  long buttonPadding = ((self.view.frame.size.width/4)-buttonDiameter)/2;
  newTextButton.frame   = CGRectMake(buttonPadding*1+buttonDiameter*0, 69, buttonDiameter, buttonDiameter);
  newAudioButton.frame  = CGRectMake(buttonPadding*3+buttonDiameter*1, 69, buttonDiameter, buttonDiameter);
  newCameraButton.frame = CGRectMake(buttonPadding*5+buttonDiameter*2, 69, buttonDiameter, buttonDiameter);
  newRollButton.frame   = CGRectMake(buttonPadding*7+buttonDiameter*3, 69, buttonDiameter, buttonDiameter);

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
  if([_MODEL_TAGS_ tags].count) line4.frame = CGRectMake(0,249,self.view.bounds.size.width,1);
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
  [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
  [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
  threeLineNavButton.accessibilityLabel = @"In-Game Menu";
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];
  // newly required in iOS 11: https://stackoverflow.com/a/44456952
  if ([threeLineNavButton respondsToSelector:@selector(widthAnchor)] && [threeLineNavButton respondsToSelector:@selector(heightAnchor)]) {
    [[threeLineNavButton.widthAnchor constraintEqualToConstant:27.0] setActive:true];
    [[threeLineNavButton.heightAnchor constraintEqualToConstant:27.0] setActive:true];
  }

  [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
  self.navigationController.navigationBar.translucent = YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = nil;
  self.navigationController.navigationBar.translucent = YES;
}

- (void) instantiableViewControllerRequestsDismissal:(id<InstantiableViewControllerProtocol>)govc
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

- (void) newCameraButtonTouched
{
  [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_CAMERA delegate:self] animated:YES];
}

- (void) newRollButtonTouched
{
  [self.navigationController pushViewController:[[NoteEditorViewController alloc] initWithNote:nil mode:NOTE_EDITOR_MODE_ROLL delegate:self] animated:YES];
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

- (void) noteTagSelectorViewControllerSelectedTag:(Tag *)t
{
  [self.navigationController popToViewController:self animated:NO];
  if(t)
  {
    [notesViewController setModeTag:t];
    [self.navigationController pushViewController:notesViewController animated:YES];
  }
}

- (void) showNav
{
  [delegate gamePlayTabBarViewControllerRequestsNav];
}

//implement gameplaytabbarviewcontrollerprotocol junk
- (NSString *) tabId { return @"NOTE"; }
- (NSString *) tabTitle { if(tab.name && ![tab.name isEqualToString:@""]) return tab.name; return NSLocalizedString(@"NotebookTitleKey",@""); }
- (ARISMediaView *) tabIcon
{
    ARISMediaView *amv = [[ARISMediaView alloc] init];
    if(tab.icon_media_id)
        [amv setMedia:[_MODEL_MEDIA_ mediaForId:tab.icon_media_id]];
    else
        [amv setImage:[UIImage imageNamed:@"notebook"]];
    return amv;
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

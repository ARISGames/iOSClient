//
//  NoteTagSelectorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 3/19/14.
//
//

#import "NoteTagSelectorViewController.h"
#import "NoteTagEditorViewController.h"

@interface NoteTagSelectorViewController () <NoteTagEditorViewControllerDelegate>
{
    NoteTagEditorViewController *tagViewController;
    id<NoteTagSelectorViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteTagSelectorViewController

- (id) initWithDelegate:(id<NoteTagSelectorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    tagViewController = [[NoteTagEditorViewController alloc] initWithTag:nil editable:YES delegate:self];
    [self.view addSubview:tagViewController.view];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    tagViewController.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    [tagViewController setExpandHeight:self.view.frame.size.height-64-216];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 27, 27);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    backButton.accessibilityLabel = @"Back Button";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [tagViewController beginEditing];
}

- (void) noteTagEditorAddedTag:(Tag *)t
{
    [delegate noteTagSelectorViewControllerSelectedTag:t];
}

- (void) noteTagEditorCancelled
{
    [delegate noteTagSelectorViewControllerRequestsDismissal:self];
}

- (void) noteTagEditorDeletedTag:(Tag *)nt
{
    //nope
}

- (void) noteTagEditorWillBeginEditing
{
    //don't care
}

- (void) backButtonTouched
{
    [delegate noteTagSelectorViewControllerRequestsDismissal:self];
}

@end

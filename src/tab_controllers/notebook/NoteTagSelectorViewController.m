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
    
    tagViewController = [[NoteTagEditorViewController alloc] initWithTags:[[NSArray alloc] init] editable:YES delegate:self];  
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
    [tagViewController beginEditing]; 
}

- (void) noteTagEditorAddedTag:(NoteTag *)nt
{
    [delegate noteTagSelectorViewControllerSelectedTag:nt];
}

- (void) noteTagEditorCreatedTag:(NoteTag *)nt
{
    //disallow creation (doesn't make sense in this context)
    [tagViewController stopEditing];  
    [tagViewController beginEditing]; 
}

@end

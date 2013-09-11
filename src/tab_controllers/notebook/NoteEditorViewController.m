//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/11/13.
//
//

#import "NoteEditorViewController.h"
#import "Note.h"

@interface NoteEditorViewController ()
{
    
    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteEditorViewController

- (id) initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d
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
}

- (void) viewWillAppear:(BOOL)animated
{
    
}

@end

//
//  NoteEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteEditorViewController.h"
#import "Note.h"

@interface NoteEditorViewController ()
{
    Note *note;
    id<NoteEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteEditorViewController

- (id)initWithNote:(Note *)n delegate:(id<NoteEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        note = n;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) refreshViewFromNote
{
    
}

@end

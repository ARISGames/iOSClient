//
//  NoteTagEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "NoteTagEditorViewController.h"

@interface NoteTagEditorViewController ()
{
    NSArray *tags;
    
    UIScrollView *scrollView;
    
    id<NoteTagEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagEditorViewController

- (id) initWithTags:(NSArray *)t delegate:(id<NoteTagEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tags = t;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.view addSubview:scrollView];
}

- (void) setTags:(NSArray *)t
{
    tags = t;
}

- (UIView *) tagViewForTag:(NSObject *)t
{
    return [[UIView alloc] init];
}

- (void) refreshViewFromTags
{
    while([[scrollView subviews] count] != 0) [[[scrollView subviews] objectAtIndex:0] removeFromSuperview];
    
    for(int i = 0; i < [tags count]; i++)
        [scrollView addSubview:[self tagViewForTag:[tags objectAtIndex:i]]];
}

@end

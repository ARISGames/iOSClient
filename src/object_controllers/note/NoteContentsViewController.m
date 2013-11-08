//
//  NoteContentsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteContentsViewController.h"
#import "NoteContent.h"
#import "ARISMediaView.h"
#import "AppModel.h"

@interface NoteContentsViewController () <ARISMediaViewDelegate>
{
    NSArray *contents;
    UIScrollView *scrollView;
    id<NoteContentsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteContentsViewController

- (id) initWithNoteContents:(NSArray  *)c delegate:(id<NoteContentsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        contents = c;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self refreshFromContents];
    
    [self.view addSubview:scrollView];
}
    
- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    scrollView.frame = self.view.bounds;
    int offset = 0;
    for(UIView *v in scrollView.subviews)
    {
        v.frame = CGRectMake(offset, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        offset += self.view.bounds.size.width;
    }
    scrollView.contentSize = CGSizeMake(offset,self.view.bounds.size.height);  
}

- (void) setContents:(NSArray *)c
{
    contents = c;
    [self refreshFromContents];
}

- (void) refreshFromContents
{
    NoteContent *c;
    int offset = 0;
    for(int i = 0; i < [contents count]; i++)
    {
        c = (NoteContent *)[contents objectAtIndex:i];
        if([c.type isEqualToString:@"TEXT"]) continue;
        ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(offset,0,self.view.bounds.size.width,self.view.bounds.size.height) media:[[AppModel sharedAppModel] mediaForMediaId:c.mediaId ofType:[c getType]] mode:ARISMediaDisplayModeAspectFill delegate:self];
        amv.clipsToBounds = YES;
        
        [scrollView addSubview:amv];
        offset += self.view.bounds.size.width;
    }
    scrollView.contentSize = CGSizeMake(offset,self.view.bounds.size.height);  
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

@end

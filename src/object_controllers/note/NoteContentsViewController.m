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
    
    NoteContent *c;
    for(int i = 0; i < [contents count]; i++)
    {
        if([((NoteContent *)[contents objectAtIndex:i]).type isEqualToString:@"PHOTO"])
            c = (NoteContent *)[contents objectAtIndex:i];
    }
    if(c)
    {
        ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) media:[[AppModel sharedAppModel] mediaForMediaId:c.mediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFill delegate:self];
        [self.view addSubview:amv];
    }
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

@end

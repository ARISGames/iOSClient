//
//  NoteContentsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/6/13.
//
//

#import "NoteContentsViewController.h"
#import "ARISMediaView.h"
#import "AppModel.h"

@interface NoteContentsViewController () <ARISMediaViewDelegate, UIScrollViewDelegate>
{
    NSArray *contents;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
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
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO; 
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-20,self.view.bounds.size.width,20)];
    [self refreshFromContents];
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl]; 
}
    
- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    scrollView.frame = self.view.bounds;
    pageControl.frame = CGRectMake(0,self.view.bounds.size.height-20,self.view.bounds.size.width,20); 
    
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
    Media *m;
    int offset = 0;
    for(int i = 0; i < [contents count]; i++)
    {
        m = (Media *)[contents objectAtIndex:i];
        ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(offset,0,self.view.bounds.size.width,self.view.bounds.size.height) media:m mode:ARISMediaDisplayModeAspectFill delegate:self];
        [amv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ARISMediaViewTouched)]]; 
        amv.clipsToBounds = YES;
        
        [scrollView addSubview:amv];
        offset += self.view.bounds.size.width;
    }
    scrollView.contentSize = CGSizeMake(offset,self.view.bounds.size.height);  
    pageControl.numberOfPages = [contents count]; 
}

- (void) scrollViewDidScroll:(UIScrollView *)s
{
    float percentScrolled = (scrollView.contentOffset.x+(0.5*scrollView.frame.size.width))/scrollView.contentSize.width;
    pageControl.currentPage = floor(percentScrolled*pageControl.numberOfPages);
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (void) ARISMediaViewTouched //this is obnoxious- if only tap gestures would pass the thing that was tapped...
{
    int nonTextMediaIndex = 0;
    Media *m;
    for(int i = 0; i < [contents count]; i++) //need to iterate, becuase "TEXT" types are skipped :/
    { 
        m = (Media *)[contents objectAtIndex:i];
        if(pageControl.currentPage == nonTextMediaIndex)
            [delegate mediaWasSelected:m];
        nonTextMediaIndex++; 
    }
}

@end

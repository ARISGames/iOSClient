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
    UILabel *noMediaNotice;
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
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    
    noMediaNotice = [[UILabel alloc] init];
    noMediaNotice.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"NotebookNoMediaKey", @"")];
    noMediaNotice.font = [ARISTemplate ARISBodyFont];
    noMediaNotice.textColor = [UIColor whiteColor];
    noMediaNotice.textAlignment = NSTextAlignmentCenter;
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-20,self.view.bounds.size.width,20)];
    pageControl.currentPageIndicatorTintColor = [UIColor ARISColorDarkBlue];
    pageControl.pageIndicatorTintColor = [UIColor ARISColorLightBlue]; 
    [self refreshFromContents];
    
    [self.view addSubview:noMediaNotice];
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
}
    
- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    noMediaNotice.frame = CGRectMake(0,self.view.bounds.size.height/2-15,self.view.bounds.size.width,30);
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
    while([scrollView subviews].count > 0) [[[scrollView subviews] objectAtIndex:0] removeFromSuperview];
    for(int i = 0; i < contents.count; i++)
    {
        m = (Media *)[contents objectAtIndex:i];
        ARISMediaView *amv = [[ARISMediaView alloc] initWithFrame:CGRectMake(offset,0,self.view.bounds.size.width,self.view.bounds.size.height) delegate:self];
        [amv setDisplayMode:ARISMediaDisplayModeAspectFill];
        [amv setMedia:m];
        [amv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ARISMediaViewTouched)]]; 
        amv.clipsToBounds = YES;
        
        [scrollView addSubview:amv];
        offset += self.view.bounds.size.width;
    }
    scrollView.contentSize = CGSizeMake(offset,self.view.bounds.size.height);  
    pageControl.numberOfPages = contents.count;
}

- (void) scrollViewDidScroll:(UIScrollView *)s
{
    float percentScrolled = (scrollView.contentOffset.x+(0.5*scrollView.frame.size.width))/scrollView.contentSize.width;
    pageControl.currentPage = floor(percentScrolled*pageControl.numberOfPages);
}

- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv
{
    [self ARISMediaViewTouched];
    return NO;
}

- (void) ARISMediaViewTouched //this is obnoxious- if only tap gestures would pass the thing that was tapped...
{
    [delegate mediaWasSelected:(Media *)[contents objectAtIndex:pageControl.currentPage]];
}

@end

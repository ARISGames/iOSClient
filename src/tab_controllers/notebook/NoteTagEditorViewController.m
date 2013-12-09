//
//  NoteTagEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "NoteTagEditorViewController.h"
#import "UIColor+ARISColors.h"
#import "Tag.h"

@interface NoteTagEditorViewController ()
{
    NSArray *tags;
    
    UIScrollView *scrollView;
    UILabel *plus;
    UIImageView *grad;
    
    BOOL editable;
    
    id<NoteTagEditorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagEditorViewController

- (id) initWithTags:(NSArray *)t editable:(BOOL)e delegate:(id<NoteTagEditorViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tags = t;
        editable = e;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width-30,30)];
    
    int width = [@" + " sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]].width;
    
    //make "plus" in similar way to tags
    plus = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25,5,width,20)];
    plus.font = [UIFont fontWithName:@"HelveticaNeue-Light"  size:18];
    plus.textColor = [UIColor whiteColor];
    plus.backgroundColor = [UIColor ARISColorLightBlue];
    plus.text = @" + ";
    plus.layer.cornerRadius = 8;
    plus.layer.masksToBounds = YES;
    [plus addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTagButtonTouched)]];
    
    grad = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_white_gradient"]];
    grad.frame = CGRectMake(self.view.frame.size.width-55,0,30,30);
    
    [self refreshViewFromTags];  
    [self.view addSubview:scrollView]; 
    if(editable) [self.view addSubview:plus]; 
    [self.view addSubview:grad]; 
}

- (void) viewDidLayoutSubviews
{
    plus.frame = CGRectMake(self.view.frame.size.width-25, 5, plus.frame.size.width, plus.frame.size.height); 
    scrollView.frame = CGRectMake(0,0,self.view.frame.size.width-30,self.view.frame.size.height); 
    grad.frame = CGRectMake(self.view.frame.size.width-55,0,30,30); 
}

- (void) setTags:(NSArray *)t
{
    tags = t;
    [self refreshViewFromTags];
}

- (UIView *) tagViewForTag:(Tag *)t
{
    int width;
    if(editable) width = [[NSString stringWithFormat:@" %@ x ",t.tagName] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]].width;
    else         width = [[NSString stringWithFormat:@" %@ ",  t.tagName] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]].width;
    UILabel *tagView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,20)];
    tagView.font = [UIFont fontWithName:@"HelveticaNeue-Light"  size:18];
    tagView.textColor = [UIColor whiteColor];
    tagView.backgroundColor = [UIColor ARISColorLightBlue];
    if(editable) tagView.text = [NSString stringWithFormat:@" %@ x ",t.tagName];
    else         tagView.text = [NSString stringWithFormat:@" %@ ",t.tagName]; 
    tagView.layer.cornerRadius = 8;
    tagView.layer.masksToBounds = YES;
    return tagView;
}

- (void) refreshViewFromTags
{
    while([[scrollView subviews] count] != 0) [[[scrollView subviews] objectAtIndex:0] removeFromSuperview];
    
    UIView *tv;
    int x = 10;
    for(int i = 0; i < [tags count]; i++)
    {
        tv = [self tagViewForTag:[tags objectAtIndex:i]];
        tv.frame = CGRectMake(x,5,tv.frame.size.width,tv.frame.size.height);
        x += tv.frame.size.width+10;
        [scrollView addSubview:tv];
    }
    scrollView.contentSize = CGSizeMake(x,30);
}

- (void) addTagButtonTouched
{
    
}

- (void) deleteTagButtonTouched:(Tag *)t
{
    
}

@end

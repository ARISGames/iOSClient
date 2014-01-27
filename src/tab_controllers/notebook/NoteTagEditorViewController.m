//
//  NoteTagEditorViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/8/13.
//
//

#import "NoteTagEditorViewController.h"
#import "ARISTemplate.h"
#import "NoteTag.h"

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
    
    int width = [@" + " sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    
    //make "plus" in similar way to tags
    plus = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-25,5,width,20)];
    plus.font = [ARISTemplate ARISBodyFont];
    plus.textColor = [UIColor whiteColor];
    plus.backgroundColor = [UIColor ARISColorLightBlue];
    plus.text = @" + ";
    plus.layer.cornerRadius = 8;
    plus.layer.masksToBounds = YES;
    plus.userInteractionEnabled = YES;
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

- (UIView *) tagViewForTag:(NoteTag *)t
{
    int width;
    if(editable) width = [[NSString stringWithFormat:@" %@ x ",t.text] sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    else         width = [[NSString stringWithFormat:@" %@ ",  t.text] sizeWithFont:[ARISTemplate ARISBodyFont]].width;
    UILabel *tagView = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,20)];
    tagView.font = [ARISTemplate ARISBodyFont];
    tagView.textColor = [UIColor whiteColor];
    tagView.backgroundColor = [UIColor ARISColorLightBlue];
    if(editable) tagView.text = [NSString stringWithFormat:@" %@ x ",t.text];
    else         tagView.text = [NSString stringWithFormat:@" %@ ",t.text]; 
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

- (void) deleteTagButtonTouched:(NoteTag *)t
{
    
}

@end

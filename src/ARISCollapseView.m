//
//  ARISCollapseView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "ARISCollapseView.h"
#import "ARISTemplate.h"

const int HANDLE_HEIGHT = 10;
const int TOUCH_BUFFER_HEIGHT = 20;
#define handle_buffer_height ((HANDLE_HEIGHT*handleShowing)+TOUCH_BUFFER_HEIGHT)

@interface ARISCollapseView() <UIScrollViewDelegate>
{
    UIView *handle;
    UIScrollView *contentContainerView;
    UIView *content;
    CGRect openFrame;
    CGRect tempDragStartFrame; //to hold state while dragging
    int handleShowing;
    
    id<ARISCollapseViewDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UIView *handle;
@property (nonatomic, strong) UIScrollView *contentContainerView;
@property (nonatomic, strong) UIView *content;
@end

@implementation ARISCollapseView
@synthesize handle;
@synthesize contentContainerView;
@synthesize content;

- (id) initWithContentView:(UIView *)v frame:(CGRect)f open:(BOOL)o showHandle:(BOOL)h draggable:(BOOL)d tappable:(BOOL)t delegate:(id<ARISCollapseViewDelegate>)del
{
    if(self = [super initWithFrame:f])
    {
        openFrame = [self frameWithBarAndTouchBuffer:f];
        
        handleShowing = h ? 1 : 0;
        
        if(!o) [super setFrame:CGRectMake(openFrame.origin.x,
                                       openFrame.origin.y+openFrame.size.height-handle_buffer_height,
                                       openFrame.size.width,
                                       handle_buffer_height)];
            
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        if(h)
        {
            self.handle = [[UIView alloc] initWithFrame:CGRectMake(0,TOUCH_BUFFER_HEIGHT,f.size.width,HANDLE_HEIGHT)];
            UILabel *dots = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, f.size.width, TOUCH_BUFFER_HEIGHT)];
            dots.backgroundColor = [UIColor clearColor];
            dots.textColor = [UIColor ARISColorGray];
            dots.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
            dots.textAlignment = NSTextAlignmentCenter;
            dots.text = @"...";
            [self.handle addSubview:dots];
            [self addSubview:self.handle];
        }
            
        self.contentContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, handle_buffer_height, openFrame.size.width, openFrame.size.height-handle_buffer_height)];
        self.contentContainerView.clipsToBounds = YES;
        self.contentContainerView.userInteractionEnabled = YES;
        self.contentContainerView.bounces = NO;
        self.contentContainerView.delegate = self;
        self.content = v;
        [self setContentFrame:self.content.frame];
        [self addSubview:self.contentContainerView];
        [self.contentContainerView addSubview:self.content];
        
        [self setBackgroundColor:[ARISTemplate ARISColorTextBackdrop]];
        
        if(t) [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapped:)]];
        if(d) [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanned:)]];
        
        delegate = del;
    }
    return self;
}

- (CGRect) frameWithBarAndTouchBuffer:(CGRect)f
{
    if(handleShowing && f.size.height < HANDLE_HEIGHT) { f.origin.y-=(HANDLE_HEIGHT-f.size.height); f.size.height = HANDLE_HEIGHT; }
    
    //invisible touch area buffer
    f.size.height += TOUCH_BUFFER_HEIGHT;
    f.origin.y    -= TOUCH_BUFFER_HEIGHT;
    
    return f;
}

- (void) setFrame:(CGRect)f
{
    openFrame = [self frameWithBarAndTouchBuffer:f];
    
    if(self.frame.size.height != handle_buffer_height) [self open];
    else                                               [self close];
}

- (void) setFrameHeight:(CGFloat)h
{
    [self setFrame:CGRectMake(openFrame.origin.x, self.frame.origin.y+self.frame.size.height-h, openFrame.size.width, h)];
}

- (void) setContentFrame:(CGRect)f
{
    self.content.frame = f;
    self.contentContainerView.contentSize = CGSizeMake(self.content.frame.origin.x+self.content.frame.size.width,self.content.frame.origin.y+self.content.frame.size.height);
}

- (void) setContentFrameHeight:(CGFloat)h
{
    [self setContentFrame:CGRectMake(self.content.frame.origin.x,self.content.frame.origin.y,self.content.frame.size.width,h)];
}

- (void) handleTapped:(UITapGestureRecognizer *)g
{
    if(self.frame.size.height == handle_buffer_height) [self open];
    else                                               [self close];
}

- (void) handlePanned:(UIPanGestureRecognizer *)g
{
    if(g.state == UIGestureRecognizerStateBegan) 
        tempDragStartFrame = self.frame;
    else if(g.state == UIGestureRecognizerStateEnded)
    {
        if(openFrame.size.height-self.frame.size.height < self.frame.size.height-handle_buffer_height)
            [self open];
        else
            [self close];
    }
    //else if((self.contentContainerView.contentOffset.y == 0 && [g translationInView:self].y < 0) ||
    //(self.contentContainerView.frame.size.height + self.contentContainerView.contentOffset.y == self.contentContainerView.contentSize.height && [g translationInView:self].y > 0))
    else 
    {
        CGFloat drag = [g translationInView:self].y;
        if(tempDragStartFrame.origin.y+drag < openFrame.origin.y)      drag = openFrame.origin.y - tempDragStartFrame.origin.y;
        if(tempDragStartFrame.size.height-drag < handle_buffer_height) drag = tempDragStartFrame.size.height - handle_buffer_height;
        
        [super setFrame:CGRectMake(tempDragStartFrame.origin.x, tempDragStartFrame.origin.y+drag, tempDragStartFrame.size.width, tempDragStartFrame.size.height-drag)];
    }
    
    if([(NSObject *)delegate respondsToSelector:@selector(collapseView:wasDragged:)])
        [delegate collapseView:self wasDragged:g];
}

- (void) open
{
    if([(NSObject *)delegate respondsToSelector:@selector(collapseView:didStartOpen:)]) [delegate collapseView:self didStartOpen:YES];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
    [super setFrame:openFrame];
    self.contentContainerView.frame = CGRectMake(0,handle_buffer_height,openFrame.size.width,openFrame.size.height-handle_buffer_height);
    self.contentContainerView.contentSize= self.content.frame.size;
    [UIView commitAnimations];
}

- (void) close
{
    if([(NSObject *)delegate respondsToSelector:@selector(collapseView:didStartOpen:)]) [delegate collapseView:self didStartOpen:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
    [super setFrame:CGRectMake(openFrame.origin.x, openFrame.origin.y+openFrame.size.height-handle_buffer_height, openFrame.size.width, handle_buffer_height)];
    self.contentContainerView.frame = CGRectMake(0,handle_buffer_height,openFrame.size.width,openFrame.size.height-handle_buffer_height);
    self.contentContainerView.contentSize= self.content.frame.size;
    [UIView commitAnimations];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    self.handle.backgroundColor               = backgroundColor;
    self.contentContainerView.backgroundColor = backgroundColor;
}

@end

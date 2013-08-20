//
//  ARISCollapseView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "ARISCollapseView.h"
#import "UIColor+ARISColors.h"

@interface ARISCollapseView()
{
    UIView *handle;
    UIView *childContainerView;
    UIView *childView;
    CGRect openFrame;
    CGRect dragStartFrame;
    int handleShowing;
    
    id<ARISCollapseViewDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UIView *handle;
@property (nonatomic, strong) UIView *childContainerView;
@property (nonatomic, strong) UIView *childView;
@end

@implementation ARISCollapseView
@synthesize handle;
@synthesize childContainerView;
@synthesize childView;

- (id) initWithView:(UIView *)v frame:(CGRect)f open:(BOOL)o showHandle:(BOOL)h draggable:(BOOL)d tappable:(BOOL)t delegate:(id<ARISCollapseViewDelegate>)del
{
    if(self = [super initWithFrame:f])
    {
        openFrame = [self morphFrame:f];
        
        handleShowing = h ? 1 : 0;
        
        if(!o) self.frame = CGRectMake(openFrame.origin.x, openFrame.origin.y+openFrame.size.height-(20+10*handleShowing), f.size.width, (20+10*handleShowing));
            
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        if(h)
        {
            self.handle = [[UIView alloc] initWithFrame:CGRectMake(0,20,f.size.width,10)];
            UILabel *dots = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, f.size.width, 20)];
            dots.backgroundColor = [UIColor clearColor];
            dots.textColor = [UIColor ARISColorText];
            dots.font = [UIFont fontWithName:@"Helvetica" size:30];
            dots.textAlignment = NSTextAlignmentCenter;
            dots.text = @"...";
            [self.handle addSubview:dots];
            [self addSubview:self.handle];
        }
            
        self.childContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, (20+10*handleShowing), openFrame.size.width, openFrame.size.height-(20+10*handleShowing))];
        self.childContainerView.userInteractionEnabled = YES;
        self.childView = v;
        self.childView.frame = self.childContainerView.bounds;
        [self addSubview:self.childContainerView];
        [self.childContainerView addSubview:self.childView];
        
        [self setBackgroundColor:[UIColor ARISColorTextBackdrop]];
        
        if(t) [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapped:)]];
        if(d) [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanned:)]];
        
        delegate = del;
    }
    return self;
}

- (CGRect) morphFrame:(CGRect)f
{
    if(handleShowing && f.size.height < 10) { f.origin.y-=(10-f.size.height); f.size.height = 10; }
    
    //touch area buffer
    f.size.height += 20;
    f.origin.y    -= 20;
    return f;
}
    
- (void) setOpenFrame:(CGRect)f
{
    openFrame = [self morphFrame:f];
    
    if(self.frame.size.height != (20+10*handleShowing)) [self open];
    else                                                [self close];
}

- (void) setOpenFrameHeight:(CGFloat)h
{
    [self setOpenFrame:CGRectMake(openFrame.origin.x, self.frame.origin.y+self.frame.size.height-h, openFrame.size.width, h)];
}

- (void) handleTapped:(UITapGestureRecognizer *)g
{
    if(self.frame.size.height == (20+10*handleShowing)) [self open];
    else                                                [self close];
}

- (void) handlePanned:(UIPanGestureRecognizer *)g
{
    if(g.state == UIGestureRecognizerStateBegan) 
        dragStartFrame = self.frame;
    else if(g.state == UIGestureRecognizerStateEnded)
    {
        if(openFrame.size.height-self.frame.size.height < self.frame.size.height-(20+10*handleShowing))
            [self open];
        else
            [self close];
    }
    else
    {
        CGFloat drag = [g translationInView:self].y;
        if(dragStartFrame.origin.y+drag < openFrame.origin.y)       drag = openFrame.origin.y - dragStartFrame.origin.y;
        if(dragStartFrame.size.height-drag < (20+10*handleShowing)) drag = dragStartFrame.size.height - (20+10*handleShowing);
        
        self.frame = CGRectMake(dragStartFrame.origin.x, dragStartFrame.origin.y+drag, dragStartFrame.size.width, dragStartFrame.size.height-drag);
    }
}

- (void) open
{
    if([(NSObject *)delegate respondsToSelector:@selector(collapseView:didStartOpen:)]) [delegate collapseView:self didStartOpen:YES];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
    self.frame = openFrame;
    self.childContainerView.frame = CGRectMake(0, (20+10*handleShowing), openFrame.size.width, openFrame.size.height-(20+10*handleShowing));
    [UIView commitAnimations];
}

- (void) close
{
    if([(NSObject *)delegate respondsToSelector:@selector(collapseView:didStartOpen:)]) [delegate collapseView:self didStartOpen:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
    self.frame = CGRectMake(openFrame.origin.x, openFrame.origin.y+openFrame.size.height-(20+10*handleShowing), openFrame.size.width, (20+10*handleShowing));
    self.childContainerView.frame = CGRectMake(0, (20+10*handleShowing), openFrame.size.width, openFrame.size.height-(20+10*handleShowing));
    [UIView commitAnimations];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    self.handle.backgroundColor             = backgroundColor;
    self.childContainerView.backgroundColor = backgroundColor;
}

@end

//
//  ARISCollapseView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "ARISCollapseView.h"
#import "ARISAppDelegate.h"

@interface ARISCollapseView()
{
    UIView *handle;
    UIView *childContainerView;
    UIView *childView;
    CGRect openFrame;
    
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

- (id) initWithView:(UIView *)v frame:(CGRect)f open:(BOOL)o delegate:(id<ARISCollapseViewDelegate>)d
{
    if(f.size.height < 10) { f.origin.y-=(10-f.size.height); f.size.height = 10; }
    if(self = [super initWithFrame:f])
    {
        if(!o) self.frame = CGRectMake(f.origin.x, f.origin.y+f.size.height-10, f.size.width, 10);
        
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        openFrame = f;
        self.handle = [[UIView alloc] initWithFrame:CGRectMake(0,0,f.size.width,10)];
        UILabel *dots = [[UILabel alloc] initWithFrame:CGRectMake(0, -15, f.size.width, 20)];
        dots.backgroundColor = [UIColor clearColor];
        dots.textColor = [UIColor whiteColor];
        dots.font = [UIFont fontWithName:@"Helvetica" size:30];
        dots.textAlignment = NSTextAlignmentCenter;
        dots.text = @"...";
        [self.handle addSubview:dots];
        self.childContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, f.size.width, f.size.height-10)];
        self.childView = v;
        self.childView.frame = self.childContainerView.bounds;
        [self addSubview:self.handle];
        [self addSubview:self.childContainerView];
        [self.childContainerView addSubview:self.childView];
        
        [self.handle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapped)]];
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        delegate = d;
    }
    return self;
}

- (void) setOpenFrame:(CGRect)f
{
    if(f.size.height < 10) f.size.height = 10;
    openFrame = f;
    self.childContainerView.frame = CGRectMake(0, 10, f.size.width, f.size.height-10);
    if(self.frame.size.height != 10) [self open];
}

- (void) handleTapped
{
    if(self.frame.size.height == 10) [self open];
    else                             [self close];
}

- (void) open
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
     self.frame = openFrame;
    [UIView commitAnimations];
}

- (void) close
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.1];
    self.frame = CGRectMake(openFrame.origin.x, openFrame.origin.y+openFrame.size.height-10, openFrame.size.width, 10);
    [UIView commitAnimations];
}

@end

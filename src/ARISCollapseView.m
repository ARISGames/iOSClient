//
//  ARISCollapseView.m
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import "ARISCollapseView.h"

@interface ARISCollapseView()
{
    UIView *handle;
    UIView *childView;
    CGRect openFrame;
    
    id<ARISCollapseViewDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, strong) UIView *handle;
@property (nonatomic, strong) UIView *childView;
@end

@implementation ARISCollapseView
@synthesize handle;
@synthesize childView;

- (id) initWithView:(UIView *)v frame:(CGRect)f open:(BOOL)o delegate:(id<ARISCollapseViewDelegate>)d
{
    if(f.size.height < 10) f.size.height = 10;
    if(self = [super initWithFrame:f])
    {
        if(!o) self.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, 10);
        
        self.clipsToBounds = YES;
        openFrame = f;
        self.handle = [[UIView alloc] initWithFrame:CGRectMake(0,0,f.size.width,10)];
        self.childView = v;
        self.childView.frame = CGRectMake(0,10,f.size.width,self.childView.frame.size.height);
        [self addSubview:self.handle];
        [self addSubview:self.childView];
        
        [self.handle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapped)]];
        delegate = d;
    }
    return self;
}

- (void) setOpenFrame:(CGRect)f
{
    if(f.size.height < 10) f.size.height = 10;
    openFrame = f;
    if(self.frame.size.height != 10) [self open];
}

- (void) handleTapped
{
    if(self.frame.size.height != 10) [self open];
    else                             [self close];
}

- (void) open
{
    self.frame = openFrame;
}

- (void) close
{
    self.frame = CGRectMake(openFrame.origin.x, openFrame.origin.y, openFrame.size.width, 10);
}

@end

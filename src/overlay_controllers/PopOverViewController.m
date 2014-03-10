//
//  PopOverViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "PopOverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "ARISMediaView.h"
#import "CircleView.h"
#import "Media.h"
#import "AppModel.h"
#import "ARISTemplate.h"

@interface PopOverViewController() <ARISMediaViewDelegate>
{
    CircleView *popOverView;
    ARISMediaView *iconMediaView;
    UILabel *header;
    UILabel *prompt;
        
    id<PopOverViewDelegate,StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation PopOverViewController
        
- (id) initWithDelegate:(id <PopOverViewDelegate, StateControllerProtocol>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];

    self.view.backgroundColor = [UIColor ARISColorTranslucentBlack];
    self.view.userInteractionEnabled = YES;
    
    popOverView = [[CircleView alloc] initWithBackgroundColor:[UIColor ARISColorTranslucentBlack] strokeColor:[UIColor ARISColorWhite]];
    popOverView.opaque = NO;
    
    header = [[UILabel alloc] init];
    header.font = [ARISTemplate ARISTitleFont];
    header.textColor = [UIColor ARISColorWhite]; 
    header.textAlignment = NSTextAlignmentCenter;
    header.backgroundColor = [UIColor clearColor];
    
    prompt = [[UILabel alloc] init];
    prompt.font = [ARISTemplate ARISSubtextFont];
    prompt.textColor = [UIColor ARISColorWhite];  
    prompt.textAlignment = NSTextAlignmentCenter; 
    prompt.backgroundColor = [UIColor clearColor];
    
    iconMediaView = [[ARISMediaView alloc] initWithDelegate:self];
    
    [popOverView addSubview:header];
    [popOverView addSubview:prompt];
    [popOverView addSubview:iconMediaView]; 
    
    [self.view addSubview:popOverView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    float radius = (self.view.bounds.size.width-40)/2;
    popOverView.frame = CGRectMake(20,self.view.bounds.size.height/2-radius,radius*2,radius*2);
    [iconMediaView setFrame:CGRectMake(radius-64,radius-84,128,128) withMode:ARISMediaDisplayModeAspectFit];
    header.frame = CGRectMake(20,radius+60,2*radius-40,24);
    prompt.frame = CGRectMake(20,radius+80,2*radius-40,24); 
}

- (void) setHeader:(NSString *)h prompt:(NSString *)p iconMediaId:(int)m
{
    if(!self.view) self.view.hidden = NO; //Just accesses view to force its load
    
    header.text = h;
    prompt.text = p;
    
    if(m != 0) [iconMediaView setMedia:[[AppModel sharedAppModel] mediaForMediaId:m]];
    else [iconMediaView setImage:[UIImage imageNamed:@"todo"]];
}

- (void) dismiss
{
    [delegate popOverRequestsDismiss];
}

@end

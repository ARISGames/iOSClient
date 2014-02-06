//
//  MapHUD.m
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import "MapHUD.h"
#import "ARISMediaView.h"
#import "ARISWebView.h"

@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol>
{
    UILabel *title; 
    ARISWebView *descriptionView;
    ARISMediaView *iconView; 
    
    id<MapHUDDelegate> __unsafe_unretained delegate;
}

@end
@implementation MapHUD

- (id) initWithDelegate:(id<MapHUDDelegate>)d
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
    title = [[UILabel alloc] init]; 
    descriptionView = [[ARISWebView alloc] initWithDelegate:self]; 
    iconView = [[ARISMediaView alloc] initWithDelegate:self]; 
    [self.view addSubview:title]; 
    [self.view addSubview:descriptionView]; 
    [self.view addSubview:iconView]; 
    
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    title.frame = CGRectMake(10,10,self.view.bounds.size.width-60, 20); 
    descriptionView.frame = CGRectMake(10,30,self.view.bounds.size.width-60, self.view.bounds.size.height-40);  
    [iconView setFrame:CGRectMake(self.view.bounds.size.width-50,10,40,40) withMode:ARISMediaDisplayModeAspectFill];
}

- (void) setTitle:(NSString *)t description:(NSString *)d icon:(Media *)m
{
    title.text = t;
    [descriptionView loadHTMLString:d baseURL:nil];
    [iconView setMedia:m];
}

@end

//
//  LoadingViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "ARISTemplate.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"

@interface LoadingViewController()
{
    UIImageView *splashImage;
    UIProgressView *progressBar;
    UILabel *progressLabel;
    
    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoadingViewController

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super init])
    {
        delegate = d;
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PERCENT_LOADED", self, @selector(percentLoaded:), nil);
    }
    return self;
}

- (void) loadView
{
    self.view.backgroundColor = [UIColor ARISColorLightGray];
    
    progressBar = [[UIProgressView alloc] init];
    progressLabel = [[UILabel alloc] init];
    
    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
    progressBar.progress = 0.0;
}

- (void) viewDidAppear:(BOOL)animated
{
    progressLabel.frame = CGRectMake(10, 60, self.view.frame.size.width, 40);
    progressBar.frame = CGRectMake(10, 80, self.view.frame.size.width, 10); 
}

- (void) percentLoaded:(NSNotification *)notif
{
    progressBar.progress = [notif.userInfo[@"percent"] floatValue];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);                 
}

@end

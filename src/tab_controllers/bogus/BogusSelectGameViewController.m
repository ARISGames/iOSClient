//
//  BogusSelectGameViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/8/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "BogusSelectGameViewController.h"
#import "ARISAppDelegate.h"

@interface BogusSelectGameViewController()
{
    id<BogusSelectGameViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation BogusSelectGameViewController

- (id)initWithDelegate:(id<BogusSelectGameViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"BogusTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"213-reply.png"];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate stopAudio];
    [delegate gameDismisallWasRequested];
}

@end

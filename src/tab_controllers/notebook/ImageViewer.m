//
//  ImageViewer.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewer.h"

@implementation ImageViewer
@synthesize imageView,media;

- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [self.imageView loadMedia:self.media];
}

- (NSInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

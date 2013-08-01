//
//  ImageViewer.m
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageViewer.h"

@interface ImageViewer() <ARISMediaViewDelegate>
@end

@implementation ImageViewer
@synthesize imageView,media;

- (void)dealloc
{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [self.imageView refreshWithFrame:self.imageView.frame media:self.media mode:ARISMediaDisplayModeAspectFit delegate:self];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
}

- (NSInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

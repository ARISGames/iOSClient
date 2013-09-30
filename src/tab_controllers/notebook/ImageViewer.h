//
//  ImageViewer.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

#import "ARISMediaView.h"
#import "Media.h"

@interface ImageViewer : ARISViewController
{
    IBOutlet ARISMediaView *imageView;
    Media *media;
}

@property(nonatomic)IBOutlet ARISMediaView *imageView;
@property(nonatomic) Media *media;

@end

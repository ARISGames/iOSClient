//
//  ImageViewer.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncMediaView.h"
#import "Media.h"
@interface ImageViewer : UIViewController {
    IBOutlet AsyncMediaView *imageView;
    Media *media;
}
@property(nonatomic,retain)IBOutlet AsyncMediaView *imageView;
@property(nonatomic,retain) Media *media;

-(void)updateImage;
@end

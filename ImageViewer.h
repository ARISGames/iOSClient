//
//  ImageViewer.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "Media.h"
@interface ImageViewer : UIViewController {
    IBOutlet AsyncImageView *imageView;
    Media *media;
}
@property(nonatomic,retain)IBOutlet AsyncImageView *imageView;
@property(nonatomic,retain) Media *media;

-(void)updateImage;
@end

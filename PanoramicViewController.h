//
//  PanoramicViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Panoramic.h"
#import "PLView.h"

@interface PanoramicViewController : UIViewController {
    Panoramic *panoramic;
    IBOutlet UIView *viewImageContainer;
    IBOutlet	PLView	*plView;
}

@property (nonatomic,retain)Panoramic *panoramic;
@property(nonatomic, retain) IBOutlet PLView	*plView;
@property(nonatomic, retain) IBOutlet UIView	*viewImageContainer;

- (void)loadImage:(NSString *)name;
@end

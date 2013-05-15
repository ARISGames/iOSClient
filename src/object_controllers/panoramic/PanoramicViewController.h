//
//  PanoramicViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"
#import "Panoramic.h"
#import "PLView.h"
#import "Media.h"

@interface PanoramicViewController : GameObjectViewController <UIImagePickerControllerDelegate>

- (id) initWithPanoramic:(Panoramic *)p delegate:(NSObject<GameObjectViewControllerDelegate> *)d;

@end

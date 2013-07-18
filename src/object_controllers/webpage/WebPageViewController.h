//
//  WebPageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"

@class WebPage;
@protocol StateControllerProtocol;

@interface WebPageViewController : GameObjectViewController 

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<GameObjectViewControllerDelegate, StateControllerProtocol> *)d;

@end

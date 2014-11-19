//
//  WebPageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol WebPageViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate>
@end

@class Instance;
@class Tab;
@interface WebPageViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<WebPageViewControllerDelegate>)d;
- (id) initWithTab:(Tab *)t delegate:(id<WebPageViewControllerDelegate>)d;
@end


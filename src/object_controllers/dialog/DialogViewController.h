//
//  DialogViewController.h
//  ARIS
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol DialogViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate>
@end

@class Instance;
@class Tab;
@interface DialogViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<DialogViewControllerDelegate>)d;
- (id) initWithTab:(Tab *)t delegate:(id<DialogViewControllerDelegate>)d;
@end

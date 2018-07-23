//
//  PlaqueFullViewController.h
//  ARIS
//
//  Created by Michael Tolly on 7/23/18.
//

#ifndef PlaqueFullViewController_h
#define PlaqueFullViewController_h

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol PlaqueFullViewControllerDelegate <InstantiableViewControllerDelegate, GamePlayTabBarViewControllerDelegate>
@end

@class Instance;
@class Tab;
@interface PlaqueFullViewController : ARISViewController <InstantiableViewControllerProtocol, GamePlayTabBarViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<PlaqueFullViewControllerDelegate>)d;
- (id) initWithTab:(Tab *)t delegate:(id<PlaqueFullViewControllerDelegate>)d;
@end

#endif /* PlaqueFullViewController_h */

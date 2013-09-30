//
//  GameObjectViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class GameObjectViewController;
@protocol GameObjectViewControllerDelegate
- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc;
@end

@interface GameObjectViewController : ARISViewController
{
    id<GameObjectViewControllerDelegate> __unsafe_unretained delegate;
}
@end

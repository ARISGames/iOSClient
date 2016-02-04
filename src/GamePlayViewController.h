//
//  GamePlayViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 5/2/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISContainerViewController.h"

@class Game;

@protocol GamePlayViewControllerDelegate
@end

@interface GamePlayViewController : ARISContainerViewController
{
    BOOL viewingObject; //because apple's heirarchy design is terrible
}
- (id) initWithDelegate:(id<GamePlayViewControllerDelegate>)d;
- (void) destroy;
@property (nonatomic, assign) BOOL viewingObject;
@end

//
//  GameCommentsViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Game;
@protocol GameCommentsViewControllerDelegate
@end

@interface GameCommentsViewController : ARISViewController
- (id) initWithGame:(Game*)g delegate:(id<GameCommentsViewControllerDelegate>)d;
@end

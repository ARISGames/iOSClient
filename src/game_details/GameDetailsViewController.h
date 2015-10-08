//
//  GameDetailsViewController.h
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Game;
@protocol GameDetailsViewControllerDelegate
- (void) gameDetailsCanceled:(Game *)g;
@end

@interface GameDetailsViewController : ARISViewController
- (id) initWithGame:(Game *)g downloaded:(BOOL)downloaded delegate:(id<GameDetailsViewControllerDelegate>)d;
@end

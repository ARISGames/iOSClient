//
//  GameDetailsViewController.h
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;
@protocol GameDetailsViewControllerDelegate
- (void) gameDetailsWereConfirmed:(Game *)g;
- (void) gameDetailsWereCanceled:(Game *)g;
@end

@interface GameDetailsViewController : UIViewController 
- (id) initWithGame:(Game *)g delegate:(id<GameDetailsViewControllerDelegate>)d;
@end

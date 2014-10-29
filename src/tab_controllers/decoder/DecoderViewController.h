//
//  DecoderViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol StateControllerProtocol;

@protocol DecoderViewControllerDelegate <GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@interface DecoderViewController : ARISViewController <GamePlayTabBarViewControllerDelegate>
- (id) initWithDelegate:(id<DecoderViewControllerDelegate>)d;
@end

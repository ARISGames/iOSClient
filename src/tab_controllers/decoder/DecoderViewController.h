//
//  DecoderViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol DecoderViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@class Tab;
@interface DecoderViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<DecoderViewControllerDelegate>)d;
@end

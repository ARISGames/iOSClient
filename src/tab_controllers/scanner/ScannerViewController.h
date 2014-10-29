//
//  ScannerViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"

@protocol StateControllerProtocol;

@protocol ScannerViewControllerDelegate <GamePlayTabBarViewControllerDelegate, StateControllerProtocol>
@end

@class Tab;
@interface ScannerViewController : ARISViewController <GamePlayTabBarViewControllerProtocol>
- (id) initWithTab:(Tab *)t delegate:(id<ScannerViewControllerDelegate>)d;
- (void) setPrompt:(NSString *)p;
@end

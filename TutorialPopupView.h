//
//  TutorialPopupView.h
//  ARIS
//
//  Created by David J Gagnon on 2/16/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	tutorialPopupKindNearbyTab		= 0,
	tutorialPopupKindQuestsTab		= 1,
	tutorialPopupKindMapTab			= 2,
	tutorialPopupKindInventoryTab	= 3,
};
typedef UInt32 tutorialPopupType;


@interface TutorialPopupView : UIView {
	CGFloat pointerXpos;
	NSString *title;
	NSString *message;
	tutorialPopupType type;
	UIViewController *associatedViewController;
}

@property (readwrite) CGFloat pointerXpos;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (readwrite) tutorialPopupType type;
@property (nonatomic) UIViewController *associatedViewController;

-(void) updatePointerPosition;

@end

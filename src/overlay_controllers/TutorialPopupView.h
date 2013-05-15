//
//  TutorialPopupView.h
//  ARIS
//
//  Created by David J Gagnon on 2/16/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPopupView : UIView
{
	CGFloat pointerXpos;
	NSString *title;
	NSString *message;
	UIViewController *associatedViewController;
}

@property (readwrite) CGFloat pointerXpos;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic) UIViewController *associatedViewController;

-(void) updatePointerPosition;

@end

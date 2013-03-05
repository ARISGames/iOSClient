//
//  GameObjectDisplayViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 3/1/13.
//
//

#import <UIKit/UIKit.h>

enum
{
	DisplayOriginNil	   = 0,
	DisplayOriginLocation  = 1,
	DisplayOriginCharacter = 2
};
typedef UInt32 DisplayOriginType;

@protocol DisplayOriginProtocol
- (DisplayOriginType) type;
- (void) didDisplayObject;
- (void) finishedDisplayingObject;
@end

@protocol DisplayableObjectProtocol
- (UIView *) getViewForDisplay;
@end

@interface GameObjectDisplayViewController : UIViewController
{
    UIViewController *delegate;
    
    UIView * currentlyDisplayedView;
    id<DisplayableObjectProtocol> currentlyDisplayedObject;
    id<DisplayOriginProtocol> currentlyDisplayedObjectOrigin;
    
    NSMutableArray *displayQueue; //Full of dictionaries of format: {"object":<DisplayableObjectProtocol>, "origin":<DisplayOriginProtocol>}
}

- (id)initWithRootViewController:(UIViewController *)d;
- (void)display:(id<DisplayableObjectProtocol>)object from:(id<DisplayOriginProtocol>)origin;

@end

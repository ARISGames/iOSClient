//
//  ARISTemplate.h
//  ARIS
//
//  Created by Phil Dougherty on 1/8/14.
//
//

#import <Foundation/Foundation.h>
#import "UIColor+ARISColors.h"

@interface ARISTemplate : NSObject

+ (UIColor *) ARISColorNavBarTint;
+ (UIColor *) ARISColorNavBarText;           
+ (UIColor *) ARISColorTabBarTint;
+ (UIColor *) ARISColorTabBarText;           
+ (UIColor *) ARISColorToolBarTint;
+ (UIColor *) ARISColorBarButtonTint;
+ (UIColor *) ARISColorSegmentedControlTint;
+ (UIColor *) ARISColorSearchBarTint;
+ (UIColor *) ARISColorHighlightedText;

+ (UIColor *) ARISColorContentBackdrop; //behind fullscreen content
+ (UIColor *) ARISColorNpcContentBackdrop; //behind npc media
+ (UIColor *) ARISColorTextBackdrop;    //behind large amounts of text
+ (UIColor *) ARISColorText;            //content text
+ (UIColor *) ARISColorViewBackdrop;    //behind navigation screens
+ (UIColor *) ARISColorViewText;        //labels on navigation screens
+ (UIColor *) ARISColorSideNavigationBackdrop;
+ (UIColor *) ARISColorSideNavigationText;

+ (NSString *) ARISHtmlTemplate;

+ (UIFont *) ARISDefaultFont;
+ (UIFont *) ARISNavTitleFont;
+ (UIFont *) ARISNavButtonFont;
+ (UIFont *) ARISTabTitleFont;
+ (UIFont *) ARISCellTitleFont;
+ (UIFont *) ARISCellSubtextFont;
+ (UIFont *) ARISButtonFont;
+ (UIFont *) ARISTitleFont;
+ (UIFont *) ARISBodyFont;
+ (UIFont *) ARISLabelFont;
+ (UIFont *) ARISSubtextFont;
+ (UIFont *) ARISInputFont;

@end

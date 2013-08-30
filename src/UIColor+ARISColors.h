//
//  UIColor+ARISColors.h
//  ARIS
//
//  Created by David Gagnon on 6/24/13.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (ARISColors)

+ (UIColor *) ARISColorScarlet;
+ (UIColor *) ARISColorDarkBlue;
+ (UIColor *) ARISColorLightBlue;
+ (UIColor *) ARISColorOrange;
+ (UIColor *) ARISColorRed;
+ (UIColor *) ARISColorYellow;
+ (UIColor *) ARISColorBlack;
+ (UIColor *) ARISColorLightGray;
+ (UIColor *) ARISColorGray;
+ (UIColor *) ARISColorDarkGray;
+ (UIColor *) ARISColorWhite;
+ (UIColor *) ARISColorOffWhite;

+ (UIColor *) ARISColorTranslucentBlack;
+ (UIColor *) ARISColorTranslucentWhite;

+ (UIColor *) ARISColorNavBarTint;
+ (UIColor *) ARISColorNavBarText;           
+ (UIColor *) ARISColorTabBarTint;
+ (UIColor *) ARISColorTabBarText;           
+ (UIColor *) ARISColorToolBarTint;
+ (UIColor *) ARISColorBarButtonTint;
+ (UIColor *) ARISColorSegmentedControlTint;
+ (UIColor *) ARISColorSearchBarTint;

+ (UIColor *) ARISColorContentBackdrop; //behind fullscreen content
+ (UIColor *) ARISColorNpcContentBackdrop; //behind npc media
+ (UIColor *) ARISColorTextBackdrop;    //behind large amounts of text
+ (UIColor *) ARISColorText;            //content text
+ (UIColor *) ARISColorViewBackdrop;    //behind navigation screens
+ (UIColor *) ARISColorViewText;        //labels on navigation screens
+ (UIColor *) ARISColorSideNaviagtionBackdrop;
+ (UIColor *) ARISColorSideNaviagtionText;


+ (NSString *) ARISHtmlTemplate;

@end

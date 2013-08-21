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
+ (UIColor *) ARISColorDarkGray;
+ (UIColor *) ARISColorWhite;
+ (UIColor *) ARISColorOffWhite;

+ (UIColor *) ARISColorTranslucentBlack;
+ (UIColor *) ARISColorTranslucentWhite;

+ (UIColor *) ARISColorNavBar;           
+ (UIColor *) ARISColorNavBarText;           
+ (UIColor *) ARISColorTabBar;           
+ (UIColor *) ARISColorTabBarText;           
+ (UIColor *) ARISColorToolBar;
+ (UIColor *) ARISColorBarButton;
+ (UIColor *) ARISColorSegmentedControl;
+ (UIColor *) ARISColorSearchBar;

+ (UIColor *) ARISColorContentBackdrop; //behind fullscreen content
+ (UIColor *) ARISColorTextBackdrop;    //behind large amounts of text
+ (UIColor *) ARISColorText;            //content text
+ (UIColor *) ARISColorViewBackdrop;    //behind navigation screens
+ (UIColor *) ARISColorViewText;        //labels on navigation screens

@end

//
//  UIImage+ARISColors.m
//  ARIS
//
//  Created by David Gagnon on 6/24/13.
//
//

#import "UIColor+ARISColors.h"

@implementation UIColor (ARISColors)

+ (UIColor *) ARISColorScarlet   { return [UIColor colorWithRed:(207.0/255.0) green:( 47.0/255.0)  blue:( 40.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorDarkBlue  { return [UIColor colorWithRed:(  0.0/255.0) green:(101.0/255.0)  blue:(149.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorLightBlue { return [UIColor colorWithRed:(132.0/255.0) green:(153.0/255.0)  blue:(165.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorOrange    { return [UIColor colorWithRed:(249.0/255.0) green:( 99.0/255.0)  blue:(  2.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorRed       { return [UIColor colorWithRed:(237.0/255.0) green:( 23.0/255.0)  blue:( 79.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorYellow    { return [UIColor colorWithRed:(216.0/255.0) green:(181.0/255.0)  blue:( 17.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorBlack     { return [UIColor colorWithRed:( 38.0/255.0) green:( 28.0/255.0)  blue:(  2.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorLightGray { return [UIColor colorWithRed:(214.0/255.0) green:(218.0/255.0)  blue:(211.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorDarkGray  { return [UIColor colorWithRed:( 30.0/255.0) green:( 30.0/255.0)  blue:( 30.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorWhite     { return [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0)  blue:(255.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorOffWhite  { return [UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0)  blue:(230.0/255.0) alpha:1.0]; }

+ (UIColor *) ARISColorTranslucentBlack { return [UIColor colorWithRed:(  0.0/255.0) green:(  0.0/255.0) blue:(  0.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorTranslucentWhite { return [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0]; }

+ (UIColor *) ARISColorNavBar           { return [UIColor ARISColorOffWhite]; }
+ (UIColor *) ARISColorTabBar           { return [UIColor ARISColorOffWhite]; }
+ (UIColor *) ARISColorToolBar          { return [UIColor ARISColorOffWhite]; }
+ (UIColor *) ARISColorBarButton        { return [UIColor ARISColorLightBlue]; }
+ (UIColor *) ARISColorSegmentedControl { return [UIColor ARISColorLightBlue]; }
+ (UIColor *) ARISColorSearchBar        { return [UIColor ARISColorOffWhite]; }
+ (UIColor *) ARISColorTextBackdrop     { return [UIColor ARISColorTranslucentBlack]; }
+ (UIColor *) ARISColorText             { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorContentBackdrop  { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorViewBackdrop     { return [UIColor ARISColorLightGray]; }

@end

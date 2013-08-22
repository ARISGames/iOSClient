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
//+ (UIColor *) ARISColorBlack     { return [UIColor colorWithRed:( 38.0/255.0) green:( 28.0/255.0)  blue:(  2.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorBlack     { return [UIColor colorWithRed:( 16.0/255.0) green:(  8.0/255.0)  blue:(  2.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorLightGray { return [UIColor colorWithRed:(214.0/255.0) green:(218.0/255.0)  blue:(211.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorGray      { return [UIColor colorWithRed:(150.0/255.0) green:(150.0/255.0)  blue:(150.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorDarkGray  { return [UIColor colorWithRed:( 30.0/255.0) green:( 30.0/255.0)  blue:( 30.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorWhite     { return [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0)  blue:(255.0/255.0) alpha:1.0]; }
+ (UIColor *) ARISColorOffWhite  { return [UIColor colorWithRed:(228.0/255.0) green:(229.0/255.0)  blue:(230.0/255.0) alpha:1.0]; }

//+ (UIColor *) ARISColorTranslucentBlack { return [UIColor colorWithRed:( 38.0/255.0) green:( 28.0/255.0) blue:(  2.0/255.0) alpha:0.8]; }
+ (UIColor *) ARISColorTranslucentBlack { return [UIColor colorWithRed:( 16.0/255.0) green:(  8.0/255.0) blue:(  2.0/255.0) alpha:0.8]; }
+ (UIColor *) ARISColorTranslucentWhite { return [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.9]; }

// Should put following in own class ARISTemplate or something
+ (UIColor *) ARISColorNavBar           { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorNavBarText       { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorTabBar           { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorTabBarText       { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorToolBar          { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorBarButton        { return [UIColor ARISColorGray]; }
+ (UIColor *) ARISColorSegmentedControl { return [UIColor ARISColorGray]; }
+ (UIColor *) ARISColorSearchBar        { return [UIColor ARISColorWhite]; }

+ (UIColor *) ARISColorTextBackdrop     { return [UIColor ARISColorTranslucentWhite]; }
+ (UIColor *) ARISColorText             { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorContentBackdrop  { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorViewBackdrop     { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorViewText         { return [UIColor ARISColorBlack]; }

+ (NSString *) ARISHtmlTemplate
{
    return 
    @"<html>"
    @"<head>"
    @"	<style type='text/css'><!--"
    @"  html { margin:0; padding:0; }"
    @"	body {"
    @"      color:#000000;"
    @"		font-size:17px;"
    @"		font-family:HelvetiaNeue;"
    @"      font-family:'HelveticaNeue-Light', 'Helvetica Neue Light', 'Helvetica Neue', 'Helvetica', 'Arial', 'Lucida Grande', 'sans-serif';"
    @"      margin:0;"
    @"      padding:10;"
    @"	}"
    @"	a { color: #FFFFFF; text-decoration: underline; }"
    @"	--></style>"
    @"</head>"
    @"<body>%@</body>"
    @"</html>";
}

@end

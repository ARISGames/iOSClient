//
//  ARISTemplate.m
//  ARIS
//
//  Created by Phil Dougherty on 1/8/14.
//
//

#import "ARISTemplate.h"
#import "AppModel.h"

@implementation ARISTemplate

+ (UIColor *) ARISColorNavBarTint             { return [UIColor ARISColorTranslucentWhite]; }
+ (UIColor *) ARISColorNavBarText             { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorTabBarTint             { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorTabBarText             { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorToolBarTint            { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorBarButtonTint          { return [UIColor ARISColorLightBlue]; }
+ (UIColor *) ARISColorSegmentedControlTint   { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorSearchBarTint          { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorHighlightedText        { return [UIColor ARISColorLightBlue]; }

+ (UIColor *) ARISColorTextBackdrop           { return [UIColor ARISColorTranslucentWhite]; }
+ (UIColor *) ARISColorText                   { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorContentBackdrop        { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorViewBackdrop           { return [UIColor ARISColorWhite]; }
+ (UIColor *) ARISColorViewText               { return [UIColor ARISColorBlack]; }
+ (UIColor *) ARISColorSideNavigationBackdrop { return [UIColor ARISColorWhite];  }
+ (UIColor *) ARISColorSideNavigationText     { return [UIColor ARISColorBlack]; }

+ (UIFont *) ARISDefaultFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISNavTitleFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISNavButtonFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISTabTitleFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:0*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:0];
}
+ (UIFont *) ARISCellTitleFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue" size:17];
}
+ (UIFont *) ARISCellBoldTitleFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
}
+ (UIFont *) ARISCellSubtextFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
}
+ (UIFont *) ARISButtonFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISTitleFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISBodyFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISLabelFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISSubtextFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
}
+ (UIFont *) ARISInputFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
}
+ (UIFont *) ARISAnnotFont
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13*2];
  else
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
}

+ (NSString *) ARISHtmlTemplate
{
  if(_MODEL_GAME_ && _MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
  {
    return
    @"<html>"
    @"<head>"
    @"  <style type='text/css'><!--"
    @"  html { margin:0; padding:0; }"
    @"  body {"
    @"      color:#000000;"
    @"      font-size:30px;"
    @"      font-family:HelveticaNeue-Light;"
    @"      margin:0;"
    @"      padding:20;"
    @"  }"
    @"  a { color: #000000; text-decoration: underline; }"
    @"  --></style>"
    @"</head>"
    @"<body>%@</body>"
    @"</html>";
  }
  else
  {
    return
    @"<html>"
    @"<head>"
    @"  <style type='text/css'><!--"
    @"  html { margin:0; padding:0; }"
    @"  body {"
    @"      color:#000000;"
    @"      font-size:15px;"
    @"      font-family:HelveticaNeue-Light;"
    @"      margin:0;"
    @"      padding:10;"
    @"  }"
    @"  a { color: #000000; text-decoration: underline; }"
    @"  --></style>"
    @"</head>"
    @"<body>%@</body>"
    @"</html>";
  }
}

@end

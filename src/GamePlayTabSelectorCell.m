//
//  GamePlayTabSelectorCell.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "GamePlayTabSelectorCell.h"
#import "ARISMediaView.h"

@interface GamePlayTabSelectorCell() <ARISMediaViewDelegate>
{
  ARISMediaView *icon;
  UILabel *label;

  id<GamePlayTabSelectorCellDelegate> __unsafe_unretained delegate;
}
@end

@implementation GamePlayTabSelectorCell

+ (NSString *) cellIdentifier { return @"tabcell"; };

- (id) initWithDelegate:(id<GamePlayTabSelectorCellDelegate>)d
{
  if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tabcell"])
  {
    delegate = d;

    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    icon = [[ARISMediaView alloc] initWithDelegate:self];
    icon.clipsToBounds = YES;
    icon.userInteractionEnabled = NO;
    [icon setDisplayMode:ARISMediaDisplayModeAspectFit];

    label = [[UILabel alloc] initWithFrame:CGRectMake(65,15,self.frame.size.width-85,14)];
    label.font = [ARISTemplate ARISButtonFont];
    label.textColor = [ARISTemplate ARISColorSideNavigationText];
    label.adjustsFontSizeToFitWidth = NO;

    [self addSubview:icon];
    [self addSubview:label];
  }
  return self;
}

- (void) setFrame:(CGRect)frame
{
  [super setFrame:frame];

  if(!label) return; //views not initted

  int pad = 6;
  [icon setFrame:CGRectMake(pad, pad, self.frame.size.height-(pad*2), self.frame.size.height-(pad*2))];
  label.frame = CGRectMake(self.frame.size.height,2,self.frame.size.width-self.frame.size.height,40);
}

- (void) setLabel:(NSString *)t
{
  label.text = t;
}

- (void) setIcon:(UIImage *)i
{
  [icon setImage:i];
}

@end


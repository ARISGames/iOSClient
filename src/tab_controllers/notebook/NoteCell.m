//
//  NoteCell.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NoteCell.h"
#import "Note.h"
#import "Media.h"
#import "User.h"
#import "AppModel.h"

#import "ARISMediaView.h"

@interface NoteCell() <ARISMediaViewDelegate>
{
  UILabel *label;
  UILabel *date;
  UILabel *owner;
  UILabel *desc;
  ARISMediaView *preview;
  CGRect previewFrameFull;
  CGRect previewFrameSmall;

  Note *note;

  id<NoteCellDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteCell

+ (NSString *) cellIdentifier { return @"notecell"; };

- (id) initWithDelegate:(id<NoteCellDelegate>)d
{
  if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notecell"])
  {
    delegate = d;

    label = [[UILabel alloc] initWithFrame:CGRectMake(65,15,self.frame.size.width-85,14)];
    label.font = [ARISTemplate ARISCellSubtextFont];
    label.textColor = [UIColor ARISColorDarkGray];
    label.adjustsFontSizeToFitWidth = NO;
    date = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
    date.font = [ARISTemplate ARISCellSubtextFont];
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;
    owner = [[UILabel alloc] initWithFrame:CGRectMake(65,35,self.frame.size.width-85,14)];
    owner.font = [ARISTemplate ARISCellSubtextFont];
    owner.textColor = [UIColor ARISColorDarkGray];
    owner.adjustsFontSizeToFitWidth = NO;
    desc = [[UILabel alloc] initWithFrame:CGRectMake(10,54,self.frame.size.width-self.frame.size.height-20,14)];
    desc.font = [ARISTemplate ARISCellSubtextFont];
    desc.textColor = [UIColor ARISColorDarkGray];
    desc.adjustsFontSizeToFitWidth = NO;
    preview = [[ARISMediaView alloc] initWithDelegate:self];
    preview.clipsToBounds = YES;
    preview.userInteractionEnabled = NO;

    [self addSubview:label];
    [self addSubview:date];
    [self addSubview:owner];
    [self addSubview:desc];
    [self addSubview:preview];

  }
  return self;
}

- (void) setFrame:(CGRect)frame
{
  [super setFrame:frame];

  if(!label) return; //views not initted

  previewFrameFull = CGRectMake(self.frame.size.width-(self.frame.size.height-4), 4, self.frame.size.height-8, self.frame.size.height-8);
  previewFrameSmall = CGRectMake(self.frame.size.width-(self.frame.size.height-24), 24, self.frame.size.height-48, self.frame.size.height-48);
  label.frame = CGRectMake(15,15,self.frame.size.width-previewFrameFull.size.width-10,14);
  date.frame = CGRectMake(10,35,65,14);
  owner.frame = CGRectMake(65,35,self.frame.size.width-85,14);
  desc.frame = CGRectMake(10,54,self.frame.size.width-self.frame.size.height-20,14);
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

- (void) populateWithNote:(Note *)n
{
  note = n;

  label.text = @"";

  label.frame = CGRectMake(15,15,self.frame.size.width-previewFrameFull.size.width-10,14);
  NSDateFormatter *format = [[NSDateFormatter alloc] init];
  [format setDateFormat:@"MM/dd/yy"];
  date.text = [format stringFromDate:n.created];
  desc.text = n.desc;

  if(n.media_id) [preview setMedia:[_MODEL_MEDIA_ mediaForId:n.media_id]];
  else           [preview setMedia:nil];
  [preview setFrame:previewFrameFull];
}

- (void) setPreviewMedia:(Media *)m
{
  [preview setImage:nil];
  if(!m) return;

  if([m.type isEqualToString:@"IMAGE"])
  {
    [preview setFrame:previewFrameFull];
    [preview setDisplayMode:ARISMediaDisplayModeAspectFill];
    [preview setMedia:m];
  }
  if([m.type isEqualToString:@"VIDEO"])
  {
    [preview setFrame:previewFrameSmall];
    [preview setDisplayMode:ARISMediaDisplayModeAspectFit];
    [preview setImage:[UIImage imageNamed:@"video.png"]];
  }
  if([m.type isEqualToString:@"AUDIO"])
  {
    [preview setFrame:previewFrameSmall];
    [preview setDisplayMode:ARISMediaDisplayModeAspectFit];
    [preview setImage:[UIImage imageNamed:@"microphone.png"]];
  }
}

- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv
{
  return NO;
}

@end

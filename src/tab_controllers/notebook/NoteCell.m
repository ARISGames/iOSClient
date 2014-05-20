//
//  NoteCell.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NoteCell.h"
#import "Note.h"
#import "NoteTag.h"
#import "Media.h"
#import "User.h"

#import "ARISMediaView.h"
#import "ARISTemplate.h"

@interface NoteCell() <ARISMediaViewDelegate>
{
    UILabel *title;
    UILabel *label; 
    UILabel *date; 
    UILabel *owner; 
    UILabel *desc; 
    ARISMediaView *preview;
    CGRect previewFrameFull;
    CGRect previewFrameSmall; 
    
    UIActivityIndicatorView *spinner;
    
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
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.frame.size.width-65,20)];
        title.font = [ARISTemplate ARISCellTitleFont];
        title.adjustsFontSizeToFitWidth = NO;
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
        
        [self addSubview:title];
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
    
    if(!title) return; //views not initted
    
    title.frame = CGRectMake(10,10,self.frame.size.width-65,20); 
    previewFrameFull = CGRectMake(self.frame.size.width-(self.frame.size.height-4), 4, self.frame.size.height-8, self.frame.size.height-8);
    previewFrameSmall = CGRectMake(self.frame.size.width-(self.frame.size.height-24), 24, self.frame.size.height-48, self.frame.size.height-48);  
    CGSize textSize = [[title text] sizeWithAttributes:@{NSFontAttributeName:[title font]}];   
    label.frame = CGRectMake(textSize.width+15,15,self.frame.size.width-previewFrameFull.size.width-(textSize.width+5)-10,14); 
    date.frame = CGRectMake(10,35,65,14); 
    owner.frame = CGRectMake(65,35,self.frame.size.width-85,14); 
    desc.frame = CGRectMake(10,54,self.frame.size.width-self.frame.size.height-20,14); 
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) populateWithNote:(Note *)n loading:(BOOL)l
{
    note = n;
    
    title.text = n.name;
    label.text = @"";
    if(n.tags.count > 0) label.text = ((NoteTag *)[n.tags objectAtIndex:0]).text;
    CGSize textSize = [[title text] sizeWithAttributes:@{NSFontAttributeName:[title font]}];   
    label.frame = CGRectMake(textSize.width+15,15,self.frame.size.width-previewFrameFull.size.width-(textSize.width+5)-10,14);  
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:n.created];
    owner.text = n.owner.display_name;
    desc.text = n.desc;
    
    Media *bestContentForDisplay;
    for(int i = 0; i < n.contents.count; i++)
    {
        if(!bestContentForDisplay || [bestContentForDisplay.type isEqualToString:@"AUDIO"])
            bestContentForDisplay = [n.contents objectAtIndex:i];
        else if([bestContentForDisplay.type isEqualToString:@"VIDEO"] && [((Media *)[n.contents objectAtIndex:i]).type isEqualToString:@"IMAGE"])
            bestContentForDisplay = [n.contents objectAtIndex:i];
    }
    [self setPreviewMedia:bestContentForDisplay];
    
    if(l) [self addSpinner];
    else  [self removeSpinner];
}

- (void) addSpinner
{
    if(spinner) [self removeSpinner];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.frame.size.width-65, 15, 60, 15);
    [self addSubview:spinner];
    [spinner startAnimating];
}

- (void) removeSpinner
{
	[spinner stopAnimating];
    [spinner removeFromSuperview];
    spinner = nil;
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
    //if([m.type isEqualToString:@"VIDEO"]) { [preview setFrame:previewFrameFull withMode:ARISMediaDisplayModeAspectFill]; [preview setMedia:m]; } 
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

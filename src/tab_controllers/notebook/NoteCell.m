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
#import "Player.h"

#import "ARISMediaView.h"
#import "ARISTemplate.h"

@interface NoteCell() <ARISMediaViewDelegate>
{
    UILabel *title;
    UILabel *date; 
    UILabel *owner; 
    UILabel *desc; 
    ARISMediaView *preview;
    
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
        [preview setFrame:CGRectMake(self.frame.size.width-self.frame.size.height-4, 4, self.frame.size.height-4, self.frame.size.height-8)]; 
        preview.clipsToBounds = YES; 
        
        [self addSubview:title];
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
    
    title.frame = CGRectMake(10,10,self.frame.size.width-65,20); 
    date.frame = CGRectMake(10,35,65,14); 
    owner.frame = CGRectMake(65,35,self.frame.size.width-85,14); 
    desc.frame = CGRectMake(10,54,self.frame.size.width-self.frame.size.height-20,14); 
    [preview setFrame:CGRectMake(self.frame.size.width-self.frame.size.height-4, 4, self.frame.size.height-4, self.frame.size.height-8)];  
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) populateWithNote:(Note *)n loading:(BOOL)l
{
    note = n;
    
    [self setTitle:n.name];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    [self setDate:[format stringFromDate:n.created]];
    [self setOwner:n.owner.displayname];
    [self setDescription:n.desc];
    
    if([n.contents count] > 0) [self setPreviewMedia:[n.contents objectAtIndex:0]];
    else                       [self setPreviewMedia:nil];
    
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

- (void) setTitle:(NSString *)t
{
    title.text = t;
}

- (void) setDate:(NSString *)d
{
    date.text = d; 
}

- (void) setOwner:(NSString *)o
{
    owner.text = o;
}

- (void) setDescription:(NSString *)d
{
    desc.text = d;
}

- (void) setPreviewMedia:(Media *)m
{
    if(!m) { [preview setImage:nil]; return; }
    
    if([m.type isEqualToString:@"IMAGE"]) { [preview setFrame:preview.frame withMode:ARISMediaDisplayModeAspectFill]; [preview setMedia:m]; }
    if([m.type isEqualToString:@"AUDIO"]) { [preview setFrame:preview.frame withMode:ARISMediaDisplayModeAspectFit]; [preview setImage:[UIImage imageNamed:@"microphone.png"]]; }
    if([m.type isEqualToString:@"VIDEO"]) { [preview setFrame:preview.frame withMode:ARISMediaDisplayModeAspectFit]; [preview setImage:[UIImage imageNamed:@"video.png"]]; }
}

@end

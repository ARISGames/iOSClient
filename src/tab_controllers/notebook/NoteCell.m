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

#import "ARISTemplate.h"

@interface NoteCell()
{
    UILabel *title;
    UILabel *date; 
    UILabel *owner; 
    UILabel *desc; 
    UIImageView *imageIcon;
    UIImageView *videoIcon; 
    UIImageView *audioIcon; 
    
    UILabel *edit;
    
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
        desc = [[UILabel alloc] initWithFrame:CGRectMake(10,54,self.frame.size.width-20,14)];
        desc.font = [ARISTemplate ARISCellSubtextFont]; 
        desc.textColor = [UIColor ARISColorDarkGray];  
        desc.adjustsFontSizeToFitWidth = NO;   
        imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-65,15,15,15)];
        imageIcon.contentMode = UIViewContentModeScaleAspectFit;    
        [imageIcon setImage:[UIImage imageNamed:@"camera.png"]];
        videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-45,15,15,15)];
        videoIcon.contentMode = UIViewContentModeScaleAspectFit;     
        [videoIcon setImage:[UIImage imageNamed:@"video.png"]]; 
        audioIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25,15,15,15)];
        audioIcon.contentMode = UIViewContentModeScaleAspectFit;     
        [audioIcon setImage:[UIImage imageNamed:@"microphone.png"]]; 
        
        edit = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40,10,40,20)];
        edit.font = [ARISTemplate ARISCellTitleFont]; 
        edit.textColor = [UIColor ARISColorDarkGray];
        edit.text = @"Edit";
        edit.userInteractionEnabled = YES;
        [edit addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editButtonTouched)]];
        
        [self addSubview:title];
        [self addSubview:date]; 
        [self addSubview:owner]; 
        [self addSubview:desc]; 
        [self addSubview:imageIcon]; 
        [self addSubview:videoIcon];  
        [self addSubview:audioIcon];  
        [self addSubview:edit];
    }
    return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) populateWithNote:(Note *)n loading:(BOOL)l editable:(BOOL)e
{
    note = n;
    
    [self setTitle:n.name];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    [self setDate:[format stringFromDate:n.created]];
    [self setOwner:n.owner.displayname];
    [self setDescription:n.desc];
    
    [self setHasImageIcon:NO];
    [self setHasAudioIcon:NO]; 
    [self setHasVideoIcon:NO]; 
    for(int i = 0; i < [n.contents count]; i++)
    {
        if([((Media *)[n.contents objectAtIndex:i]).type isEqualToString:@"IMAGE"]) [self setHasImageIcon:YES];
        if([((Media *)[n.contents objectAtIndex:i]).type isEqualToString:@"AUDIO"]) [self setHasAudioIcon:YES]; 
        if([((Media *)[n.contents objectAtIndex:i]).type isEqualToString:@"VIDEO"]) [self setHasVideoIcon:YES]; 
    }
    
    if(l) [self addSpinner];
    else  [self removeSpinner];
    
    if(e) [self addSubview:edit];
    else  [edit removeFromSuperview];
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

- (void) setHasImageIcon:(BOOL)i
{
    if(i) [self addSubview:imageIcon];
    else [imageIcon removeFromSuperview];
}

- (void) setHasVideoIcon:(BOOL)v
{
    if(v) [self addSubview:videoIcon];
    else  [videoIcon removeFromSuperview]; 
}

- (void) setHasAudioIcon:(BOOL)a
{
    if(a) [self addSubview:audioIcon];
    else  [audioIcon removeFromSuperview]; 
}

- (void) editButtonTouched
{
    [delegate editRequestedForNote:note];
}

@end

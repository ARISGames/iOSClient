//
//  NoteCell.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NoteCell.h"
#import "Note.h"
#import "NoteContent.h"

#import "UIColor+ARISColors.h"

@interface NoteCell()
{
    UILabel *title;
    UILabel *date; 
    UILabel *owner; 
    UILabel *desc; 
    UIImageView *imageIcon;
    UIImageView *videoIcon; 
    UIImageView *audioIcon; 
    
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
        title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        title.adjustsFontSizeToFitWidth = NO;
        date  = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
        date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
        date.textColor = [UIColor ARISColorDarkBlue];
        date.adjustsFontSizeToFitWidth = NO; 
        owner = [[UILabel alloc] initWithFrame:CGRectMake(75,35,self.frame.size.width-85,14)];
        owner.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
        owner.textColor = [UIColor ARISColorDarkGray]; 
        owner.adjustsFontSizeToFitWidth = NO; 
        desc  = [[UILabel alloc] initWithFrame:CGRectMake(10,54,self.frame.size.width-20,14)];
        desc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
        desc.textColor = [UIColor ARISColorDarkGray];  
        desc.adjustsFontSizeToFitWidth = NO;   
        imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-65,15,15,15)];
        [imageIcon setImage:[UIImage imageNamed:@"photo.png"]];
        videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-45,15,15,15)];
        [videoIcon setImage:[UIImage imageNamed:@"video.png"]]; 
        audioIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25,15,15,15)];
        [audioIcon setImage:[UIImage imageNamed:@"audio.png"]]; 
        
        [self addSubview:title];
        [self addSubview:date]; 
        [self addSubview:owner]; 
        [self addSubview:desc]; 
        [self addSubview:imageIcon]; 
        [self addSubview:videoIcon];  
        [self addSubview:audioIcon];  
    }
    return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) populateWithNote:(Note *)n
{
    [self setTitle:n.name];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    [self setDate:[format stringFromDate:[NSDate date]]]; //currently no date!
    [self setOwner:@"Phildo"]; //currently no owner!
    [self setTitle:n.name]; 
    [self setDescription:@"Check out this bird! It's totally crazy like woah just look at it!"]; //Currently no description
    
    [self setHasImageIcon:NO];
    [self setHasAudioIcon:NO]; 
    [self setHasVideoIcon:NO]; 
    for(int i = 0; i < [n.contents count]; i++)
    {
        NSLog(@"%@",[((NoteContent *)[n.contents objectAtIndex:i]) getType]);
        if([[((NoteContent *)[n.contents objectAtIndex:i]) getType] isEqualToString:@"PHOTO"]) [self setHasImageIcon:YES];
        if([[((NoteContent *)[n.contents objectAtIndex:i]) getType] isEqualToString:@"AUDIO"]) [self setHasAudioIcon:YES]; 
        if([[((NoteContent *)[n.contents objectAtIndex:i]) getType] isEqualToString:@"VIDEO"]) [self setHasVideoIcon:YES]; 
    }
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

@end

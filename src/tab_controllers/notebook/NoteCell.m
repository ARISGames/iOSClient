//
//  NoteCell.m
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "NoteCell.h"
#import "Note.h"

@interface NoteCell()
{
    UILabel *title;
    UILabel *date; 
    UILabel *owner; 
    UIImageView *imageIcon;
    UIImageView *videoIcon; 
    UIImageView *audioIcon; 
    UITextField *desc;
    
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
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.frame.size.width-20,20)];
        date  = [[UILabel alloc] initWithFrame:CGRectMake(10,35,self.frame.size.width-20,12)];
        owner = [[UILabel alloc] initWithFrame:CGRectMake(40,35,self.frame.size.width-20,12)];
        desc  = [[UITextField alloc] initWithFrame:CGRectMake(10,52,self.frame.size.width-20,self.frame.size.height-52-5)];
        imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50,10,10,20)];
        videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50,10,10,20)];
        audioIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-50,10,10,20)];
        
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
    //[self setDate:]; //currently no date!
    [self setOwner:n.name]; 
    [self setTitle:n.name]; 
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

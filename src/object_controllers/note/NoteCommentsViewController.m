//
//  NoteCommentsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 12/10/13.
//
//

#import "NoteCommentsViewController.h"
#import "Note.h"
#import "NoteComment.h"
#import "Player.h"
#import "ARISTemplate.h"

@interface NoteCommentsViewController () <UITextFieldDelegate>
{
    NSArray *comments; 
    id<NoteCommentsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteCommentsViewController

- (id) initWithNoteComments:(NSArray *)c delegate:(id<NoteCommentsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        comments = c;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    [self refreshFromComments];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void) setComments:(NSArray *)c
{
    comments = c;
    [self refreshFromComments];
}

- (void) refreshFromComments
{
    while([self.view.subviews count] > 0)
        [[self.view.subviews objectAtIndex:0] removeFromSuperview];
    
    UIView *cell;
    int yOffset = 0;
    
    for(int i = 0; i < [comments count]; i++)
    {
        cell = [self cellForComment:[comments objectAtIndex:i]];
        cell.frame = CGRectMake(0, yOffset, cell.frame.size.width, cell.frame.size.height);
        yOffset += cell.frame.size.height+10;
        [self.view addSubview:cell];
    }
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, yOffset);
}

- (UIView *) cellForComment:(NoteComment *)c
{
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    
    UILabel *author = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.frame.size.width-85,14)];
    author.font = [ARISTemplate ARISSubtextFont]; 
    author.textColor = [UIColor ARISColorDarkGray];   
    author.text = c.owner.displayname;   
    CGSize authSize = [author.text sizeWithFont:author.font constrainedToSize:CGSizeMake(author.frame.size.width,9999999) lineBreakMode:NSLineBreakByTruncatingTail];  
    author.frame = CGRectMake(author.frame.origin.x, author.frame.origin.y, authSize.width, 14);
    
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(author.frame.size.width+20,0,65,14)];
    date.font = [ARISTemplate ARISSubtextFont];  
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:c.created]; 
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 17, self.view.bounds.size.width-20, 20)];
    text.text = c.text; 
    text.lineBreakMode = NSLineBreakByWordWrapping;
    text.numberOfLines = 0; 
    text.font = [ARISTemplate ARISInputFont];
    CGSize textSize = [text.text sizeWithFont:text.font constrainedToSize:CGSizeMake(text.frame.size.width,9999999) lineBreakMode:NSLineBreakByWordWrapping];   
    text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, text.frame.size.width, textSize.height);
    
    cell.frame = CGRectMake(0, 0, self.view.bounds.size.width, text.frame.origin.y+text.frame.size.height);
    
    [cell addSubview:date];
    [cell addSubview:author]; 
    [cell addSubview:text]; 
    return cell;
}

@end

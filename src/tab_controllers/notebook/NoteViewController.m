//
//  NoteViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "NoteViewController.h"
#import "NoteContentsViewController.h"
#import "Note.h"
#import "UIColor+ARISColors.h"

@interface NoteViewController () <NoteContentsViewControllerDelegate>
{
    Note *note;
    
    UIScrollView *scrollView;
    UILabel *title;
    UILabel *owner; 
    UILabel *date; 
    UILabel *desc; 
    NoteContentsViewController *contentsDisplay;
    
    id<GameObjectViewControllerDelegate, NoteViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation NoteViewController

- (id) initWithNote:(Note *)n delegate:(id<GameObjectViewControllerDelegate, NoteViewControllerDelegate>)d
{
    if(self = [super init])
    {
        note = n;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    scrollView.backgroundColor =[UIColor whiteColor];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(10,10,self.view.frame.size.width-65,20)];
    title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    title.adjustsFontSizeToFitWidth = NO; 
    title.text = note.name;
    
    date  = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
    date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:note.created];
    
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75,35,self.view.frame.size.width-85,14)];
    owner.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    owner.textColor = [UIColor ARISColorDarkGray]; 
    owner.adjustsFontSizeToFitWidth = NO;  
    owner.text = note.owner.displayname;
    
    desc = [[UILabel alloc] initWithFrame:CGRectMake(10,54,self.view.frame.size.width-20,18)];
    desc.lineBreakMode = NSLineBreakByWordWrapping;
    desc.numberOfLines = 0;
    desc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18]; 
    desc.textColor = [UIColor ARISColorDarkGray];  
    desc.text = note.ndescription;
    CGSize descSize = [desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width,9999999) lineBreakMode:NSLineBreakByWordWrapping]; 
    desc.frame = CGRectMake(desc.frame.origin.x, desc.frame.origin.y, desc.frame.size.width, descSize.height);
    
    contentsDisplay = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    contentsDisplay.view.frame = CGRectMake(0, desc.frame.origin.y+desc.frame.size.height+10, self.view.frame.size.width, 200);
    [scrollView addSubview:contentsDisplay.view];
    
    [scrollView addSubview:title];
    [scrollView addSubview:owner]; 
    [scrollView addSubview:date]; 
    [scrollView addSubview:desc];  
    
    [self.view addSubview:scrollView];
}
    
- (void) viewDidLayoutSubviews
{
    
}

@end

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
    date  = [[UILabel alloc] initWithFrame:CGRectMake(10,35,65,14)];
    date.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    date.textColor = [UIColor ARISColorDarkBlue];
    date.adjustsFontSizeToFitWidth = NO;  
    owner = [[UILabel alloc] initWithFrame:CGRectMake(75,35,self.view.frame.size.width-85,14)];
    owner.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    owner.textColor = [UIColor ARISColorDarkGray]; 
    owner.adjustsFontSizeToFitWidth = NO;  
    
    desc  = [[UILabel alloc] initWithFrame:CGRectMake(10,54,self.view.frame.size.width-20,14)];
    desc.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14]; 
    desc.textColor = [UIColor ARISColorDarkGray];  
    desc.adjustsFontSizeToFitWidth = NO;    
    
    contentsDisplay = [[NoteContentsViewController alloc] initWithNoteContents:note.contents delegate:self];
    contentsDisplay.view.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
    [scrollView addSubview:contentsDisplay.view];
    
    title.text = note.name;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy"];
    date.text = [format stringFromDate:[NSDate date]]; //currently no date!
    owner.text = @"Phildo"; //currently no owner!
    desc.text = @"Check out this bird! It's totally crazy like woah just look at it!"; //Currently no description 
    
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

//
//  NoteTagPredictionViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/27/14.
//
//

#import "NoteTagPredictionViewController.h"
#import "NoteTag.h"
#import "SelectableNoteTagCellView.h"

#define CELL_HEIGHT 30

@interface NoteTagPredictionViewController() <SelectableNoteTagCellViewDelegate>
{
    NSArray *gameNoteTags;
    NSArray *playerNoteTags; 
    
    UIScrollView *matchingGameNoteTagsScrollView;
    UIScrollView *matchingPlayerNoteTagsScrollView; 
    
    NSString *queryString;
    
    id<NoteTagPredictionViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagPredictionViewController

- (id) initWithGameNoteTags:(NSArray *)gnt playerNoteTags:(NSArray *)pnt delegate:(id<NoteTagPredictionViewControllerDelegate>)d
{
    if(self = [super init])
    {
        gameNoteTags = gnt;
        playerNoteTags = pnt; 
        queryString = @"";
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    matchingGameNoteTagsScrollView   = [[UIScrollView alloc] init];
    matchingPlayerNoteTagsScrollView = [[UIScrollView alloc] init]; 
    matchingGameNoteTagsScrollView.scrollEnabled   = YES;
    matchingPlayerNoteTagsScrollView.scrollEnabled = YES;
    matchingGameNoteTagsScrollView.contentInset   = UIEdgeInsetsMake(0,0,0,0);
    matchingPlayerNoteTagsScrollView.contentInset = UIEdgeInsetsMake(0,0,0,0); 
    [self.view addSubview:matchingGameNoteTagsScrollView];
    [self.view addSubview:matchingPlayerNoteTagsScrollView]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    matchingGameNoteTagsScrollView.frame   = CGRectMake(0,                            0,self.view.bounds.size.width/2,self.view.bounds.size.height);
    matchingPlayerNoteTagsScrollView.frame = CGRectMake(0,self.view.bounds.size.width/2,self.view.bounds.size.width/2,self.view.bounds.size.height); 
    matchingGameNoteTagsScrollView.contentSize   = CGSizeMake(self.view.bounds.size.width/2,self.view.bounds.size.height);
    matchingPlayerNoteTagsScrollView.contentSize = CGSizeMake(self.view.bounds.size.width/2,self.view.bounds.size.height); 
    [self refreshMatchingTags];
}

- (void) queryString:(NSString *)qs
{
    queryString = qs;
    [self refreshMatchingTags]; 
}

- (void) refreshMatchingTags
{
    while(matchingGameNoteTagsScrollView.subviews.count   > 0) [[matchingGameNoteTagsScrollView.subviews   objectAtIndex:0] removeFromSuperview];
    while(matchingPlayerNoteTagsScrollView.subviews.count > 0) [[matchingPlayerNoteTagsScrollView.subviews objectAtIndex:0] removeFromSuperview]; 
    
    NSString *regex = [NSString stringWithFormat:@".*%@.*",queryString];
    NSString *tagTest;
    UIView *tagCell;
    for(int i = 0; i < gameNoteTags.count; i++)
    {
        tagTest = ((NoteTag *)[gameNoteTags objectAtIndex:i]).text;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            tagCell = [self cellForTag:((NoteTag *)[gameNoteTags objectAtIndex:i])];
            tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingGameNoteTagsScrollView.subviews.count, matchingGameNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
            [matchingGameNoteTagsScrollView addSubview:tagCell];
        }
    }
    matchingGameNoteTagsScrollView.contentSize = CGSizeMake(matchingGameNoteTagsScrollView.bounds.size.width, CELL_HEIGHT*matchingGameNoteTagsScrollView.subviews.count);
    
    for(int i = 0; i < playerNoteTags.count; i++)
    {
        tagTest = ((NoteTag *)[playerNoteTags objectAtIndex:i]).text;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound)  
        {
            tagCell = [self cellForTag:((NoteTag *)[playerNoteTags objectAtIndex:i])];
            tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingPlayerNoteTagsScrollView.subviews.count, matchingPlayerNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
            [matchingPlayerNoteTagsScrollView addSubview:tagCell];
        }
    }
    matchingPlayerNoteTagsScrollView.contentSize = CGSizeMake(matchingPlayerNoteTagsScrollView.bounds.size.width, CELL_HEIGHT*matchingPlayerNoteTagsScrollView.subviews.count);
}

- (UIView *) cellForTag:(NoteTag *)nt
{
    return [[SelectableNoteTagCellView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT) noteTag:nt delegate:self];
}

- (void) noteTagSelected:(NoteTag *)nt
{
    [delegate existingTagChosen:nt];
}

@end

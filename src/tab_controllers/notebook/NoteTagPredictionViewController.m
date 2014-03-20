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
    NSArray *noteTags;  
    
    UIScrollView *matchingNoteTagsScrollView;
    
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
        noteTags = [gameNoteTags arrayByAddingObjectsFromArray:playerNoteTags];
        queryString = @"";
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    matchingNoteTagsScrollView = [[UIScrollView alloc] init];
    matchingNoteTagsScrollView.scrollEnabled = YES;
    matchingNoteTagsScrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    [self.view addSubview:matchingNoteTagsScrollView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    matchingNoteTagsScrollView.frame       = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height); 
    matchingNoteTagsScrollView.contentSize = CGSizeMake(self.view.bounds.size.width,self.view.bounds.size.height); 
    [self refreshMatchingTags];
}

- (NSDictionary *) queryString:(NSString *)qs
{
    queryString = qs;
    return [self refreshMatchingTags]; 
}

- (NSDictionary *) refreshMatchingTags
{
    while(matchingNoteTagsScrollView.subviews.count   > 0) [[matchingNoteTagsScrollView.subviews   objectAtIndex:0] removeFromSuperview];
    
    NSMutableArray *matchedGameTags   = [[NSMutableArray alloc] init];
    NSMutableArray *matchedPlayerTags = [[NSMutableArray alloc] init]; 
    NSDictionary *matchedTags = [[NSDictionary alloc] initWithObjectsAndKeys:matchedGameTags, @"game", matchedPlayerTags, @"player", nil];
    
    NSString *regex = [NSString stringWithFormat:@".*%@.*",queryString];
    NSString *tagTest;
    UIView *tagCell;
    for(int i = 0; i < noteTags.count; i++)
    {
        tagTest = ((NoteTag *)[noteTags objectAtIndex:i]).text;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            [matchedGameTags addObject:((NoteTag *)[noteTags objectAtIndex:i])];
            tagCell = [self cellForTag:((NoteTag *)[noteTags objectAtIndex:i])];
            tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
            [matchingNoteTagsScrollView addSubview:tagCell];
        }
    }
    
    if(matchingNoteTagsScrollView.subviews.count == 0)
    {
        tagCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        UILabel *noTagsText = [[UILabel alloc] initWithFrame:CGRectMake(10,5,matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT-10)];
        noTagsText.text = @"(no game tags)";
        [tagCell addSubview:noTagsText];
        [matchingNoteTagsScrollView addSubview:tagCell]; 
    } 
    matchingNoteTagsScrollView.contentSize = CGSizeMake(matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count);
    
    return matchedTags;
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

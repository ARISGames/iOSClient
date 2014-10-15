//
//  NoteTagPredictionViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 1/27/14.
//
//

#import "NoteTagPredictionViewController.h"
#import "SelectableNoteTagCellView.h"
#import "AppModel.h"
#import "Game.h"
#import "NotesModel.h"

#define CELL_HEIGHT 30

@interface NoteTagPredictionViewController() <SelectableNoteTagCellViewDelegate>
{
    NSArray *tags;

    UIScrollView *matchingNoteTagsScrollView;

    NSString *queryString;

    id<NoteTagPredictionViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation NoteTagPredictionViewController

- (id) initWithTags:(NSArray *)t delegate:(id<NoteTagPredictionViewControllerDelegate>)d
{
    if(self = [super init])
    {
        tags = _ARIS_ARRAY_SORTED_ON_(t,@"text");
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

- (void) setTags:(NSArray *)t
{
    tags = _ARIS_ARRAY_SORTED_ON_(t,@"text");
    [self refreshMatchingTags];
}

- (NSArray *) queryString:(NSString *)qs
{
    queryString = qs;
    return [self refreshMatchingTags]; 
}

- (NSArray *) refreshMatchingTags
{
    while(matchingNoteTagsScrollView.subviews.count   > 0) [matchingNoteTagsScrollView.subviews[0] removeFromSuperview];
    
    NSMutableArray *matched = [[NSMutableArray alloc] init];
    
    NSString *regex = [NSString stringWithFormat:@".*%@.*",queryString];
    NSString *tagTest;
    UIView *tagCell;
    
    for(int i = 0; i < tags.count; i++)
    {
        tagTest = ((Tag *)tags[i]).tag;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            [matched addObject:((Tag *)tags[i])];
            tagCell = [self cellForTag:((Tag *)tags[i])];
            tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
            [matchingNoteTagsScrollView addSubview:tagCell];
        }
    } 
    
    //No Tags Title
    if(matchingNoteTagsScrollView.subviews.count == 0)
    {
        tagCell = [[UIView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        tagCell.userInteractionEnabled = NO;  
        UILabel *noTagsText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        noTagsText.text = [NSString stringWithFormat:@"  (%@)", NSLocalizedString(@"TagViewNoLabelsKey", @"")];
        noTagsText.textColor = [UIColor ARISColorDarkGray]; 
        noTagsText.font = [ARISTemplate ARISCellTitleFont];  
        [tagCell addSubview:noTagsText];
        [matchingNoteTagsScrollView addSubview:tagCell]; 
    } 
    matchingNoteTagsScrollView.contentSize = CGSizeMake(matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count);

    return matched;
}

- (UIView *) cellForTag:(Tag *)nt
{
    return [[SelectableNoteTagCellView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT) noteTag:nt delegate:self];
}

- (void) noteTagSelected:(Tag *)nt
{
    [delegate existingTagChosen:nt];
}

@end

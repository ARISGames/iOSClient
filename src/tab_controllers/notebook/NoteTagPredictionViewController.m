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
#import "AppModel.h"
#import "Game.h"
#import "NotesModel.h"
#import "ARISTemplate.h"
#import "UIColor+ARISColors.h"

#define CELL_HEIGHT 30

@interface NoteTagPredictionViewController() <SelectableNoteTagCellViewDelegate>
{
    NSArray *gameNoteTags;
    NSArray *playerNoteTags; 
    
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

- (void) setGameNoteTags:(NSArray *)gnt playerNoteTags:(NSArray *)pnt
{
    NSArray *sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES], nil];
    gameNoteTags = [gnt sortedArrayUsingDescriptors:sortDescriptors];
    playerNoteTags = [pnt sortedArrayUsingDescriptors:sortDescriptors]; 
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
    
    //Unlabeled
    tagTest = _MODEL_GAME_.notesModel.unlabeledTag.text;
    if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
    {
        [matchedGameTags addObject:_MODEL_GAME_.notesModel.unlabeledTag];
        tagCell = [self cellForTag:_MODEL_GAME_.notesModel.unlabeledTag];
        tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
        [matchingNoteTagsScrollView addSubview:tagCell];
    } 
    //Game Tag Title
    if([gameNoteTags count] > 0 && [playerNoteTags count] > 0)
    {
        tagCell = [[UIView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        tagCell.userInteractionEnabled = NO;  
        UILabel *noTagsText = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        noTagsText.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"TagViewGameTagsKey", @"")];
        noTagsText.textColor = [UIColor ARISColorDarkGray];
        noTagsText.font = [ARISTemplate ARISCellBoldTitleFont];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,28,1000,1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [tagCell addSubview:noTagsText];
        [tagCell addSubview:line]; 
        [matchingNoteTagsScrollView addSubview:tagCell];  
    }
    //Game Tags
    for(int i = 0; i < gameNoteTags.count; i++)
    {
        tagTest = ((NoteTag *)[gameNoteTags objectAtIndex:i]).text;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            [matchedGameTags addObject:((NoteTag *)[gameNoteTags objectAtIndex:i])];
            tagCell = [self cellForTag:((NoteTag *)[gameNoteTags objectAtIndex:i])];
            tagCell.frame = CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT);
            [matchingNoteTagsScrollView addSubview:tagCell];
        }
    } 
    //Player Tag Title
    if([gameNoteTags count] > 0 && [playerNoteTags count] > 0)
    {
        tagCell = [[UIView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT*matchingNoteTagsScrollView.subviews.count, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        tagCell.userInteractionEnabled = NO;  
        UILabel *noTagsText = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, matchingNoteTagsScrollView.bounds.size.width, CELL_HEIGHT)];
        noTagsText.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"TagViewPlayerCreatedTags", @"")];
        noTagsText.textColor = [UIColor ARISColorDarkGray]; 
        noTagsText.font = [ARISTemplate ARISCellBoldTitleFont]; 
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,28,1000,1)];
        line.backgroundColor = [UIColor ARISColorLightGray];
        [tagCell addSubview:noTagsText];
        [tagCell addSubview:line];  
        [matchingNoteTagsScrollView addSubview:tagCell];  
    } 
    //Player Tags
    for(int i = 0; i < playerNoteTags.count; i++)
    {
        tagTest = ((NoteTag *)[playerNoteTags objectAtIndex:i]).text;
        if([tagTest rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound) 
        {
            [matchedGameTags addObject:((NoteTag *)[playerNoteTags objectAtIndex:i])];
            tagCell = [self cellForTag:((NoteTag *)[playerNoteTags objectAtIndex:i])];
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
        noTagsText.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"TagViewNoLabelsKey", @"")];
        noTagsText.textColor = [UIColor ARISColorDarkGray]; 
        noTagsText.font = [ARISTemplate ARISCellTitleFont];  
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

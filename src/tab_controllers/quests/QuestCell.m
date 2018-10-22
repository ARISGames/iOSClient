//
//  QuestCell.m
//  ARIS
//
//  Created by Phil Dougherty on 2/27/14.
//
//

#import "QuestCell.h"
#import "Quest.h"
#import "ARISWebView.h"
#import "AppModel.h"

@interface QuestCell () <ARISWebViewDelegate>
{
    UILabel *titleView;
    ARISWebView *descriptionView;
    UIImageView *checkboxView;

    Quest *quest;
    id<QuestCellDelegate> __unsafe_unretained delegate;
}
@end

@implementation QuestCell

- (id) init
{
    if(self = [super init])
    {
        [self initializeViews];
        checkboxView = NULL;
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initializeViews];
    }
    return self;
}

- (void) setDelegate:(id<QuestCellDelegate>)d
{
    delegate = d;
}

- (void) initializeViews
{
    titleView = [[UILabel alloc] init];
    descriptionView = [[ARISWebView alloc] initWithDelegate:self];

    titleView.font = [ARISTemplate ARISCellTitleFont];
    descriptionView.scrollView.scrollEnabled = NO;

    titleView.frame = CGRectMake(10,10,self.frame.size.width-20,20);
    descriptionView.frame = CGRectMake(0, 20, self.frame.size.width, 15);

    titleView.userInteractionEnabled = NO;
    descriptionView.userInteractionEnabled = NO;

    [self addSubview:titleView];
    [self addSubview:descriptionView];
}

- (void) setQuest:(Quest *)q
{
    quest = q;
    titleView.text = quest.name;
    descriptionView.frame = CGRectMake(0,20,self.frame.size.width,15);
    [descriptionView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], q.desc] baseURL:nil];
}

- (void) setChecked:(BOOL)checked
{
    UIImage *img = [UIImage imageNamed:(checked ? @"check-full" : @"check-empty")];
    if (!checkboxView) {
        titleView.frame = CGRectMake
            ( titleView.frame.origin.x + 32
            , titleView.frame.origin.y
            , titleView.frame.size.width - 32
            , titleView.frame.size.height
            );
        checkboxView = [[UIImageView alloc] initWithImage:img];
        checkboxView.frame = CGRectMake(5, 5, 32, 32);
        [self addSubview:checkboxView];
    } else {
        checkboxView.image = img;
    }
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    float newHeight = [[wv stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
        newHeight *= 2;
    descriptionView.frame = CGRectMake(0,20,self.frame.size.width,newHeight);
    [delegate heightCalculated:descriptionView.frame.origin.y+descriptionView.frame.size.height forQuest:quest inCell:self];
}

@end

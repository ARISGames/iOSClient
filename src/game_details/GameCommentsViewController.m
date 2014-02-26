//
//  GameCommentsViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCommentsViewController.h"
#import "GameCommentsReviewViewController.h"

#import "AppServices.h"
#import "AppModel.h"

#import "Game.h"
#import "Player.h"
#import "GameComment.h"
#import "GameCommentCell.h"

#import "ARISTemplate.h"

@interface GameCommentsViewController () <UITableViewDelegate,UITableViewDataSource,GameCommentsReviewViewcontrollerDelegate, GameCommentCellDelegate>
{
    UIButton *writeAReviewButton;
	UITableView *commentsTable;
    
    NSMutableDictionary *cellSizes; //parallel to game.comments. can't store in cell since they are reused
    Game *game;
    id <GameCommentsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation GameCommentsViewController

- (id) initWithGame:(Game *)g delegate:(id<GameCommentsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        game = g;
        delegate = d;
        cellSizes = [[NSMutableDictionary alloc] initWithCapacity:game.comments.count+1]; //+1 for potential added comment
    }
    return self;
}

- (void) loadView
{
    [super loadView]; 
    self.view.backgroundColor = [UIColor whiteColor];
    
    writeAReviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [writeAReviewButton setTitle:@"Write a Review" forState:UIControlStateNormal];
    [writeAReviewButton setBackgroundColor:[UIColor ARISColorDarkBlue]];
    [writeAReviewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    writeAReviewButton.titleLabel.font = [ARISTemplate ARISButtonFont]; 
    [writeAReviewButton addTarget:self action:@selector(writeAReviewButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    commentsTable = [[UITableView alloc] init]; 
    commentsTable.dataSource = self;
    commentsTable.delegate = self; 
    
    [self.view addSubview:writeAReviewButton];
    [self.view addSubview:commentsTable]; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    writeAReviewButton.frame = CGRectMake(0,64,self.view.bounds.size.width,40);
    commentsTable.frame = CGRectMake(0,104,self.view.bounds.size.width,self.view.bounds.size.height-104); 
}

- (void) viewDidAppear:(BOOL)animated
{
	[commentsTable reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [game.comments count];
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameCommentCell *cell = [commentsTable dequeueReusableCellWithIdentifier:@"GCommentCell"];
    if(!cell) cell = [[GameCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCommentCell"];
    
    [cell setComment:[game.comments objectAtIndex:indexPath.row]];
    [cell setDelegate:self];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameComment *gc = [game.comments objectAtIndex:indexPath.row];
    if([cellSizes objectForKey:[gc description]])
        return [((NSNumber *)[cellSizes objectForKey:[gc description]])intValue];
    
	CGSize calcSize = [gc.text sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(self.view.bounds.size.width, 2000000) lineBreakMode:NSLineBreakByWordWrapping];
	return calcSize.height+30; 
}

- (void) heightCalculated:(int)h forComment:(GameComment *)gc inCell:(GameCommentCell *)gcc
{
    if(![cellSizes objectForKey:[gc description]])
    {
        [cellSizes setValue:[NSNumber numberWithInt:h] forKey:[gc description]]; 
        [commentsTable reloadData];
    }
}

- (void) writeAReviewButtonTouched
{
    GameCommentsReviewViewController *gcrvc = [[GameCommentsReviewViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:gcrvc animated:YES];
}

- (void) reviewCreatedWithRating:(int)r text:(NSString *)s
{
    [[AppServices sharedAppServices] saveGameComment:s game:game.gameId starRating:r];
    
    GameComment *gc = [[GameComment alloc] init];
    gc.text = s;
    gc.rating = r;
    gc.playerName = [AppModel sharedAppModel].player.username;
    [game.comments addObject:gc];
    [commentsTable reloadData];
    [self.navigationController popToViewController:self animated:YES];  
}

@end

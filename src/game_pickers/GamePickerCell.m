//
//  GamePickerCell.m
//  ARIS
//
//  Created by David J Gagnon on 2/19/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "GamePickerCell.h"
#import "Game.h"
#import "ARISStarView.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"

@interface GamePickerCell () <ARISMediaViewDelegate>
{
    Game *game;
    
    UIActivityIndicatorView *loadingIndicator;  
	UILabel *titleLabel;
	UILabel *customLabel;
	UILabel *authorLabel;
	UILabel *numReviewsLabel;
	ARISMediaView *iconView;
	ARISStarView *starView;
}
@end

@implementation GamePickerCell

- (id) init
{
    if(self = [super init])
    {
        [self initializeViews];
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_AVAILABLE", self, @selector(gameAvailable:), nil);
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initializeViews]; 
        _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_AVAILABLE", self, @selector(gameAvailable:), nil); 
    }
    return self;
}

- (void) initializeViews
{
    loadingIndicator = [[UIActivityIndicatorView alloc] init];   
    titleLabel       = [[UILabel alloc] init];
    customLabel      = [[UILabel alloc] init]; 
    authorLabel      = [[UILabel alloc] init]; 
    numReviewsLabel  = [[UILabel alloc] init]; 
    iconView         = [[ARISMediaView alloc] initWithDelegate:self]; 
    starView         = [[ARISStarView alloc] init];  
    
    [titleLabel      setFont:[ARISTemplate ARISCellTitleFont]]; 
    [authorLabel     setFont:[ARISTemplate ARISSubtextFont]]; 
    [customLabel     setFont:[ARISTemplate ARISCellSubtextFont]];
    customLabel.textAlignment = NSTextAlignmentRight;
    [numReviewsLabel setFont:[ARISTemplate ARISCellSubtextFont]];  
    [iconView setDisplayMode:ARISMediaDisplayModeAspectFill];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;  
    
    
    float cellWidth = [UIScreen mainScreen].bounds.size.width;
    loadingIndicator.frame = CGRectMake(cellWidth-20, 1, 15, 15);
    titleLabel.frame = CGRectMake(60,1,cellWidth-60,25); 
    authorLabel.frame = CGRectMake(60,23,cellWidth-60-80,15); 
    customLabel.frame = CGRectMake(cellWidth-80,24,60,15);  
    iconView.frame = CGRectMake(5, 5, 50, 50); 
    starView.frame = CGRectMake(60,40,60,12);    
    numReviewsLabel.frame = CGRectMake(160,40,cellWidth-160,15);  
    
    starView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:titleLabel];
    [self addSubview:customLabel]; 
    [self addSubview:authorLabel]; 
    [self addSubview:numReviewsLabel]; 
    [self addSubview:iconView]; 
    [self addSubview:starView];  
}

- (void) gameAvailable:(NSNotification *)n
{
    Game *g = n.userInfo[@"game"];
    if(g && game && g.game_id == game.game_id)
        [self setGame:g];
}

- (void) setGame:(Game *)g
{
    game = g;
    
    [loadingIndicator removeFromSuperview];
    [loadingIndicator stopAnimating];
    
    authorLabel.text = @"";
    if(game.authors.count == 0) //game not loaded //admittedly, an odd metric
    {
        [loadingIndicator startAnimating];
        [self addSubview:loadingIndicator];
        [_MODEL_GAMES_ requestGame:g.game_id];
    }
    else
    {
        for(long i = 0; i < game.authors.count; i++)
            authorLabel.text = [NSString stringWithFormat:@"%@%@, ",authorLabel.text,((User *)game.authors[i]).display_name];
    }
    
	titleLabel.text  = game.name;
    starView.rating  = game.rating;
    
	numReviewsLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumber numberWithLong:game.comments.count] stringValue], NSLocalizedString(@"GamePickerReviewsKey", @"")];
    
    if(!game.icon_media_id) [iconView setImage:[UIImage imageNamed:@"logo_icon.png"]];
    else                    [iconView setMedia:[_MODEL_MEDIA_ mediaForId:game.icon_media_id]];
    
    //set to distance by default
    //customLabel.text   = [NSString stringWithFormat:@"%1.1f %@", game.distanceFromPlayer/1000, NSLocalizedString(@"km", @"")]; 
}

- (void) setCustomLabelText:(NSString *)t
{
    customLabel.text = t;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

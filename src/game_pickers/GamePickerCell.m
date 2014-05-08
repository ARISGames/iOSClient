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
#import "ARISTemplate.h"

@interface GamePickerCell () <ARISMediaViewDelegate>
{
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

- (void) initializeViews
{
    titleLabel      = [[UILabel alloc] init];
    customLabel     = [[UILabel alloc] init]; 
    authorLabel     = [[UILabel alloc] init]; 
    numReviewsLabel = [[UILabel alloc] init]; 
    iconView        = [[ARISMediaView alloc] initWithDelegate:self]; 
    starView        = [[ARISStarView alloc] init];  
    
    [titleLabel      setFont:[ARISTemplate ARISCellTitleFont]]; 
    [authorLabel     setFont:[ARISTemplate ARISSubtextFont]]; 
    [customLabel     setFont:[ARISTemplate ARISCellSubtextFont]];
    customLabel.textAlignment = NSTextAlignmentRight;
    [numReviewsLabel setFont:[ARISTemplate ARISCellSubtextFont]];  
    [iconView setDisplayMode:ARISMediaDisplayModeAspectFill];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 10.0;  
    
    
    float cellWidth = [UIScreen mainScreen].bounds.size.width;
    [iconView setFrame:CGRectMake(5, 5, 50, 50)];
    [titleLabel      setFrame:CGRectMake(60,1,cellWidth-60,25)]; 
    [authorLabel     setFrame:CGRectMake(60,23,cellWidth-60-80,15)]; 
    [customLabel     setFrame:CGRectMake(cellWidth-80,24,60,15)];  
    [starView        setFrame:CGRectMake(60,40,60,12)];    
    [numReviewsLabel setFrame:CGRectMake(160,40,cellWidth-160,15)];  
    
    starView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:titleLabel];
    [self addSubview:customLabel]; 
    [self addSubview:authorLabel]; 
    [self addSubview:numReviewsLabel]; 
    [self addSubview:iconView]; 
    [self addSubview:starView];  
}

- (void) setGame:(Game *)g
{
	titleLabel.text  = g.name;
	//authorLabel.text = g.authors;
    starView.rating  = g.rating;
    
	numReviewsLabel.text = [NSString stringWithFormat:@"%@ %@", [[NSNumber numberWithInt:[g.comments count]] stringValue], NSLocalizedString(@"GamePickerReviewsKey", @"")];
    
    if(!g.icon_media_id) [iconView setImage:[UIImage imageNamed:@"logo_icon.png"]];
    else                 [iconView setMedia:[_MODEL_MEDIA_ mediaForId:g.icon_media_id]];
    
    //set to distance by default
    customLabel.text   = [NSString stringWithFormat:@"%1.1f %@", g.distanceFromPlayer/1000, NSLocalizedString(@"km", @"")]; 
}

- (void) setCustomLabelText:(NSString *)t
{
    customLabel.text = t;
}

@end

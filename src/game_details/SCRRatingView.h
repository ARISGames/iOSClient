//
//  SCRRatingView.h
//  Touch Customs
//
//  Created by Aleks Nesterow on 7/21/09.
//  aleks.nesterow@gmail.com
//  
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//  
//  Purpose
//  Displays a 5-star rating with ability to set user rating.
//

#define kSCRatingViewNonSelected	@"state-nonselected"
#define kSCRatingViewSelected		@"state-selected"
#define kSCRatingViewHalfSelected	@"state-halfselected"
#define kSCRatingViewHot			@"state-hot"
#define kSCRatingViewHighlighted	@"state-highlighted"
#define kSCRatingViewUserSelected	@"state-userselected"

@class SCRRatingView;

/** Allows you to process rating changes in the delegate. */
@protocol SCRRatingDelegate

/**
 * Invoked whenever the value of the userRating property changes.
 *
 * @param ratingView			Sender.
 * @param previousUserRating	Previous userRating property value.
 * @param userRating			Current userRating property value.
 */
- (void)ratingView:(SCRRatingView *)ratingView didChangeUserRatingFrom:(NSInteger)previousUserRating to:(NSInteger)userRating;

@optional

/**
 * Invoked whenever the value of the rating property changes.
 *
 * @param ratingView		Sender.
 * @param previousRating	Previous rating property value.
 * @param rating			Current rating property value.
 */
- (void)ratingView:(SCRRatingView *)ratingView didChangeRatingFrom:(CGFloat)previousRating to:(CGFloat)rating;

@end

/** UIView that displays a 5-star rating with ability to set user rating. */
@interface SCRRatingView : UIView {
	
@private
	CGFloat	_rating;
	NSInteger _userRating; /* User rating is supposed to be integer. */
	BOOL _highlighted;
	NSArray	*_starViews;
	NSArray	*_reflectionViews;
	NSMutableDictionary	*_stateImageDictionary;
	
	id<SCRRatingDelegate> __unsafe_unretained _delegate;
}

/** Use 0 to specify that there is no rate yet. All the other values will be aligned to [1-5] range. */
@property (nonatomic, assign) CGFloat rating;

/** 
 * Use 0 to specify that user decided to not leave rating just in the process.
 * All the other values will be aligned to [1-5] range.
 * In fact user rating - if set, i.e. 1+ - will always override rating.
 */
@property (nonatomic, assign) NSInteger userRating;

/**
 * Determines whether the control is highlighted. Introduced to support highlighted state in a TableView cell.
 */
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

@property (nonatomic, unsafe_unretained) IBOutlet id<SCRRatingDelegate> delegate;

/**
 * Customizes standard star images to the custom ones you specify here.
 * Make sure you call this method for all possible states for reach consistent look.
 */
- (void)setStarImage:(UIImage *)image forState:(NSString *)state;

- (void)setStarImagesForStates:(UIImage *)firstImage, ... NS_REQUIRES_NIL_TERMINATION;

@end

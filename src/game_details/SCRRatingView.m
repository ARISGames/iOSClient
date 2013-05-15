//
//  SCRRatingView.m
//  Touch Customs
//
//  Created by Aleks Nesterow on 7/21/09.
//  aleks.nesterow@gmail.com
//
//  Copyright © 2009 Screen Customs s.r.o. All rights reserved.
//

#import "SCRRatingView.h"
#import "SCRMemoryManagement.h"
#import "math.h"

#define PROP_RATING			@"rating"

#define MIN_RATING			1
#define MAX_RATING			5
#define STARS				MAX_RATING - MIN_RATING + 1

#define ALIGN(X)			(MIN(MAX_RATING, MAX(MIN_RATING, X)))

typedef UIImageView			StarView;
typedef UIImageView *		StarViewRef;

// image reflection
static const CGFloat kDefaultReflectionFraction = (2.0 / 3.0);
static const CGFloat kDefaultReflectionOpacity = 0.40;

@interface SCRRatingView (/* Private methods */)

- (NSMutableDictionary *)__stateImageDictionary;
- (UIImage *)__imageForState:(NSString *)state fromDictionary:(NSDictionary *)stateImageDict;
- (void)__initializeComponent;
- (NSInteger)__getRatingFromTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)__visualizeCurrentUserRating:(NSInteger)currentUserRating;
- (void)__visualizeCurrentRating:(CGFloat)currentRating;

@end

@implementation SCRRatingView

@synthesize delegate = _delegate;
@synthesize rating = _rating;
- (void)setRating:(CGFloat)value {
	
	if (_rating != value) {
		
		CGFloat previousRating = _rating;
		_rating = value;
		
		[self __visualizeCurrentRating:value];
		
		[self.delegate ratingView:self didChangeRatingFrom:previousRating to:_rating];
	}
}

@synthesize userRating = _userRating;
- (void)setUserRating:(NSInteger)value {
	
	NSInteger previousUserRating = _userRating;
	
	if (!value) {
		
		if (!_userRating /* User hasn't voted yet. */) {
			[self __visualizeCurrentRating:self.rating];
		} else {
			[self __visualizeCurrentRating:_userRating]; /* Visualizing previous user rating. */
		}
		
	} else {
		
		/* Align the passed value so that it would fit physical range of 5 stars. */
		_userRating = ALIGN(value);
		
		NSMutableDictionary *stateImageDict = [self __stateImageDictionary];
		
		for (NSInteger i = 0; i < _userRating; i++) {
			
			StarViewRef starView = [_starViews objectAtIndex:i];
			starView.image = [self __imageForState:kSCRatingViewUserSelected fromDictionary:stateImageDict];
		}
		
		if (value < _starViews.count) {
			/* Need to leave some stars with non-selected images. */
			for (NSInteger i = _starViews.count - 1; i >= value; i--) {
				StarViewRef starView = [_starViews objectAtIndex:i];
				starView.image = [self __imageForState:kSCRatingViewNonSelected fromDictionary:stateImageDict];
			}
		}
	}
	
	if (previousUserRating != _userRating) {
		[self.delegate ratingView:self didChangeUserRatingFrom:previousUserRating to:_userRating];
	}
}

@synthesize highlighted = _highlighted;
- (void)setHighlighted:(BOOL)value {
	
	for (StarViewRef starView in _starViews) {
		starView.highlighted = value;
	}
}

- (id)initWithFrame:(CGRect)frame {
	
	if ((self = [super initWithFrame:frame])) {
		[self __initializeComponent];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if ((self = [super initWithCoder:aDecoder])) {
		[self __initializeComponent];
	}
	
	return self;
}

#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh) {
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height {
    if (!height || !fromImage.image)
		return nil;
	
	CGFloat scale = 1.0f;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		scale = [UIScreen mainScreen].scale;
		
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height * scale);

	// create a bitmap graphics context the size of the image
	CGSize imageSize = CGSizeMake(fromImage.image.size.width, height);
	if (UIGraphicsBeginImageContextWithOptions) {
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0f);
	} else {
		UIGraphicsBeginImageContext(imageSize);
	}
	
	CGContextRef mainViewContentContext = UIGraphicsGetCurrentContext();

	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.image.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);

	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, fromImage.image.size.width, height), fromImage.image.CGImage);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	UIImage *reflectionImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return reflectionImage;
}

#pragma mark -

- (void)__initializeComponent {
	
	self.clipsToBounds = YES;
	
	NSMutableArray *starViewList = [[NSMutableArray alloc] initWithCapacity:STARS];
	NSMutableArray *reflectionViewList = [[NSMutableArray alloc] initWithCapacity:STARS];
	
	CGFloat height = CGRectGetHeight(self.frame);
	
	for (NSInteger i = 0; i < STARS; i++) {
		
		static CGFloat starWidth = 30;
		
		StarViewRef starView = [[StarView alloc] initWithFrame:CGRectMake(i * starWidth, 0, starWidth, height * 0.5)];
		starView.clearsContextBeforeDrawing = YES;
		starView.contentMode = UIViewContentModeCenter;
		starView.multipleTouchEnabled = YES;
		starView.tag = MIN_RATING + i; /* Associated rating, which is from MIN_RATING to MAX_RATING. */
		[starViewList addObject:starView];
		[self addSubview:starView];

		StarViewRef reflectionView = [[StarView alloc] initWithFrame:CGRectMake(i * starWidth, height * 0.5, starWidth, height * 0.5 * kDefaultReflectionFraction)];
		reflectionView.clearsContextBeforeDrawing = YES;
		reflectionView.contentMode = UIViewContentModeCenter;
		reflectionView.multipleTouchEnabled = NO;
		reflectionView.alpha = kDefaultReflectionOpacity;
		[reflectionViewList addObject:reflectionView];
		[self addSubview:reflectionView];
	}
	
	_starViews = starViewList;
	_reflectionViews = reflectionViewList;
}

- (void)dealloc {
	
    _stateImageDictionary = nil;
    _starViews = nil;
    _reflectionViews = nil;
	
}

#pragma mark Layout

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat starWidth = CGRectGetWidth(self.frame) / STARS;
	CGFloat y = height * 0.25 * (1 - kDefaultReflectionFraction);
	
	for (NSUInteger i = 0; i < STARS; i++) {
	
		StarViewRef starView = [_starViews objectAtIndex:i];
		starView.frame = CGRectMake(i * starWidth, y, starWidth, height * 0.5);

		StarViewRef reflectionView = [_reflectionViews objectAtIndex:i];
		reflectionView.frame = CGRectMake(i * starWidth, y + height * 0.5, starWidth, height * 0.5 * kDefaultReflectionFraction);
	}
}

#pragma mark Look-n-feel

- (void)setBackgroundColor:(UIColor *)color {
	[super setBackgroundColor:color];
	
	for (StarViewRef starView in _starViews)
		starView.backgroundColor = color;
	for (StarViewRef reflectionView in _reflectionViews)
		reflectionView.backgroundColor = color;
}

- (void)setOpaque:(BOOL)value {
	[super setOpaque:value];

	for (StarViewRef starView in _starViews)
		starView.opaque = value;
	for (StarViewRef reflectionView in _reflectionViews)
		reflectionView.opaque = value;
}

- (void)setStarImagesForStates:(UIImage *)firstImage, ... {
	BOOL visualize = FALSE;
	va_list args;
	va_start(args, firstImage);
	for (UIImage *image = firstImage; image; image = va_arg(args, UIImage *)) {
		NSString *state = va_arg(args, NSString *);
		if (state) {
			if ([kSCRatingViewHighlighted isEqualToString:state]) {
				for (StarViewRef starView in _starViews) {
					starView.highlightedImage = image;
				}
			} else {
				NSMutableDictionary *stateImageDict = [self __stateImageDictionary];
				[stateImageDict setObject:image forKey:state];
				visualize = TRUE;
			}
		}
	}
	va_end(args);
	
	if (visualize)
		[self __visualizeCurrentRating:self.rating];
}

- (void)setStarImage:(UIImage *)image forState:(NSString *)state {
	
	if ([kSCRatingViewHighlighted isEqualToString:state]) {
		
		for (StarViewRef starView in _starViews) {
			starView.highlightedImage = image;
		}
		
	} else {
		
		NSMutableDictionary *stateImageDict = [self __stateImageDictionary];
		[stateImageDict setObject:image forKey:state];
		
		[self __visualizeCurrentRating:self.rating];
	}
}

- (NSMutableDictionary *)__stateImageDictionary {
	
	if (!_stateImageDictionary) {
		_stateImageDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	
	return _stateImageDictionary;
}

- (UIImage *)__imageForState:(NSString *)state fromDictionary:(NSDictionary *)stateImageDict {
	
	UIImage *result = [stateImageDict objectForKey:state];
	return result;
}

- (NSInteger)__getRatingFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
	
	id touch = [touches anyObject];
	
	for (StarViewRef starView in _starViews) {
		
		if ([starView pointInside:[touch locationInView:starView] withEvent:event]) {
			return starView.tag;
		}
	}
	
	return 0;
}

- (void)__visualizeCurrentUserRating:(NSInteger)currentUserRating {
	
	NSDictionary *stateImageDict = [self __stateImageDictionary];
	
	/* Making red the stars that indicate the current rating. */
	
	for (NSInteger i = 0; i < currentUserRating; i++) {
		
		StarViewRef starView = [_starViews objectAtIndex:i];
		starView.image = [self __imageForState:kSCRatingViewHot fromDictionary:stateImageDict];

		StarViewRef reflectionView = [_reflectionViews objectAtIndex:i];
		reflectionView.image = [self reflectedImage:starView withHeight:starView.image.size.height * kDefaultReflectionFraction];
	}
	
	/* Leaving only star borders for the others. */
	
	for (NSInteger i = _starViews.count - 1; i >= currentUserRating; i--) {
		
		StarViewRef starView = [_starViews objectAtIndex:i];
		starView.image = [self __imageForState:kSCRatingViewNonSelected fromDictionary:stateImageDict];

		StarViewRef reflectionView = [_reflectionViews objectAtIndex:i];
		reflectionView.image = [self reflectedImage:starView withHeight:starView.image.size.height * kDefaultReflectionFraction];
	}
}

- (void)__visualizeCurrentRating:(CGFloat)currentRating {
	
	NSInteger counter = 0;
	NSDictionary *stateImageDict = [self __stateImageDictionary];
	
	if (currentRating != 0) {
		
		/* Round currentRating to 0.5 stop. */
		
		currentRating = (lroundf(ALIGN(currentRating) * 2)) / 2.0;
		
		/* First set images for full stars. */
		
		NSInteger fullStars = floorf(currentRating);
		for (NSInteger i = 0; i < fullStars; i++, counter++) {
			
			StarViewRef starView = [_starViews objectAtIndex:i];
			starView.image = [self __imageForState:kSCRatingViewSelected fromDictionary:stateImageDict];
			
			StarViewRef reflectionView = [_reflectionViews objectAtIndex:i];
			reflectionView.image = [self reflectedImage:starView withHeight:starView.image.size.height * kDefaultReflectionFraction];
		}
		
		/* Now set images for a half star if any. */
		
		if (currentRating - fullStars > 0) {
			
			StarViewRef starView = [_starViews objectAtIndex:counter];
			starView.image = [self __imageForState:kSCRatingViewHalfSelected fromDictionary:stateImageDict];
			
			StarViewRef reflectionView = [_reflectionViews objectAtIndex:counter];
			reflectionView.image = [self reflectedImage:starView withHeight:starView.image.size.height * kDefaultReflectionFraction];
			
			counter++;
		}
	}
	
	/* Leave other stars unselected. */
	
	for (NSInteger i = _starViews.count - 1; i >= counter; i--) {
		
		StarViewRef starView = [_starViews objectAtIndex:i];
		starView.image = [self __imageForState:kSCRatingViewNonSelected fromDictionary:stateImageDict];

		StarViewRef reflectionView = [_reflectionViews objectAtIndex:i];
		reflectionView.image = [self reflectedImage:starView withHeight:starView.image.size.height * kDefaultReflectionFraction];
	}
}

#pragma mark User Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSInteger starsToHighlight = [self __getRatingFromTouches:touches withEvent:event];
	[self __visualizeCurrentUserRating:starsToHighlight];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSInteger starsToHighlight = [self __getRatingFromTouches:touches withEvent:event];
	[self __visualizeCurrentUserRating:starsToHighlight];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	/* Basically this is final user rating. */
	NSInteger starsToSelect = [self __getRatingFromTouches:touches withEvent:event];
	[self setUserRating:starsToSelect];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self setUserRating:self.rating];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	if (self.userInteractionEnabled && [self pointInside:point withEvent:event]) {
		return self; /* Only intercept events if the touch happened inside the view. */
	}
	
	return [super hitTest:point withEvent:event];
}

- (void)setUserInteractionEnabled:(BOOL)value {
	
	[super setUserInteractionEnabled:value];
	
	for (StarViewRef starView in _starViews) {
		starView.userInteractionEnabled = value;
	}
}

@end

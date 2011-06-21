/*
 * This file is part of the PanoramaGL library.
 *
 *  Author: Javier Baez <javbaezga@gmail.com>
 *
 *  $Id$
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; version 3 of
 * the License
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#import "PLControl.h"

@interface PLControl ()

- (void)initializeValues;

- (void)loadImage:(PLResourceId)value;

- (void)createButton;
- (void)removeButton;

- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpInside:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;

@end


@implementation PLControl

@synthesize position;
@synthesize size;
@synthesize image, overImage;
@synthesize alpha;
@synthesize isVisible;
@synthesize isValid;
@synthesize rotate;
@synthesize delegate;

#pragma mark -
#pragma mark init methods

- (id)initWithView:(PLViewBase *)plView position:(CGPoint)positionValue size:(CGSize)sizeValue image:(PLResourceId)imageId overImage:(PLResourceId)overImageId
{
	if(self = [super init])
	{
		view = [plView retain];
		position = positionValue;
		size = sizeValue;
		image = imageId;
		overImage = overImageId;
		[self initializeValues];
	}
	return self;
}

+ (PLControl *)controlWithView:(PLViewBase *)view position:(CGPoint)positionValue size:(CGSize)sizeValue image:(PLResourceId)imageId overImage:(PLResourceId)overImageId
{
	return [[PLControl alloc] initWithView:view position:positionValue size:sizeValue image:imageId overImage:overImageId];
}

- (void)initializeValues
{	
	isVisible = YES;
	[self createButton];
}

#pragma mark -
#pragma mark utility methods

- (void)createButton
{
	[self removeButton];
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(position.x, position.y, size.width, size.height);
	button.backgroundColor = [UIColor clearColor];
	button.adjustsImageWhenHighlighted = NO;
	
	[self loadImage:image];
	
	[button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	
	[self addToView:view];
}

- (void)removeButton
{
	if(button)
	{
		[button removeFromSuperview];
		[button release];
	}
}

- (void)loadImage:(PLResourceId)value
{
	if(button)
		[button setBackgroundImage:[PLResources getResourceImageById:value] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark property methods

- (void)setPosition:(CGPoint)value
{	
	position = value;
	if(button)
		button.frame = CGRectMake(position.x, position.y, size.width, size.height);
}

- (void)setSize:(CGSize)value
{
	size = value;
	if(button)
		button.frame = CGRectMake(position.x, position.y, size.width, size.height);
}

- (void)setImage:(PLResourceId)value
{
	image = value;
	[self loadImage:value];
}

- (void)setRotate:(NSInteger)value
{	
	if(value % 90 != 0)
		return;
	rotate = value;
	button.transform = CGAffineTransformMakeRotation(value * kPI / 180.0f);
	if(value == 90 || value == -90)
		button.frame = CGRectMake(position.x, position.y, size.height, size.width);
	else 
		button.frame = CGRectMake(position.x, position.y, size.width, size.height);
}

- (void)isVisible:(BOOL)value
{
	if(button)
		button.hidden = !value;
}

- (BOOL)isValid
{
	return (button && image && overImage);
}

#pragma mark -
#pragma mark touch methods

- (void)buttonTouchDown:(id)sender
{
	[self loadImage:overImage];
}

- (void)buttonTouchUpInside:(id)sender
{
	[self loadImage:image];
	if(delegate && [delegate respondsToSelector:@selector(executeAction:)])
		[delegate executeAction:self];
}

- (void)buttonTouchUpOutside:(id)sender
{
	[self loadImage:image];
}

#pragma mark -
#pragma mark view methods

- (void)addToView:(PLViewBase *)value
{
	if(value && button)
	{
		if(view)
			[view release];
		view = [value retain];
		[view addSubview:button];
	}
}

- (void)removeFromView
{
	if(button && button.superview)
		[button removeFromSuperview];
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc
{
	[self removeButton];
	if(view)
		[view release];
	[super dealloc];
}

@end

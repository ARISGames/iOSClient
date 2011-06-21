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

#import "PLSceneElement.h"

@interface PLSceneElementBase(Protected)

- (void)translate;
- (void)rotate;
- (void)internalRotate:(PLRotation)rotationValue orientation:(PLOrientation)orientationValue rotationSign:(int)rotationSign;

- (void)beginRender;
- (void)endRender;
- (void)internalRender;

- (void)changeOrientation:(UIDeviceOrientation)orientation oldOrientation:(UIDeviceOrientation)oldOrientation;

- (void)swapPitchValues;
- (void)swapPitchValuesWithSign:(BOOL)sign;
- (void)swapYawValues;
- (void)swapYawValuesWithSign:(BOOL)sign;
- (void)swapPitchRangeByYawRange:(int)swapPitchValue swapYawValue:(int)swapYawValue;
- (void)swapPitchRangeByYawRange:(BOOL)isSwapPitchValues isSwapYawValues:(BOOL)isSwapYawValues isSwapPitchSign:(BOOL)isSwapPitchSign isSwapYawSign:(BOOL)isSwapYawSign;

@end


@implementation PLSceneElementBase

@synthesize isVisible, isValid;
@synthesize identificator;

#pragma mark -
#pragma mark init methods

- (void)initializeValues
{
	[super initializeValues];
	isVisible = YES;
	isValid = NO;
}

#pragma mark -
#pragma mark action methods

- (void)translate
{
	float yValue = isYZAxisInverseRotation ? position.z : position.y, zValue = isYZAxisInverseRotation ? position.y : position.z;
	glTranslatef(isXAxisEnabled ? position.x : 0.0f, isYAxisEnabled ? yValue : 0.0f, isZAxisEnabled ? zValue : 0.0f);
}

- (void)rotate
{
	PLOrientation orientationValue;
	int rotationSign = 0;
	
	switch (orientation) 
	{
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationPortrait:
			rotationSign = 1;
		case UIDeviceOrientationPortraitUpsideDown:
			if(!rotationSign)
				rotationSign = -1;
			orientationValue = PLOrientationPortrait;
			break;
		case UIDeviceOrientationLandscapeLeft:
			rotationSign = -1;
		case UIDeviceOrientationLandscapeRight:
			if(!rotationSign)
				rotationSign = 1;
			orientationValue = PLOrientationLandscape;
			break;
		default:
			rotationSign = 1;
			orientationValue = PLOrientationUnknown;
			break;
	}
	
	[self internalRotate:rotation orientation:orientationValue rotationSign:rotationSign];
}

- (void)internalRotate:(PLRotation)rotationValue orientation:(PLOrientation)orientationValue rotationSign:(int)rotationSign
{
	float yDirection = isYZAxisInverseRotation ? 0.0f : 1.0f, zDirection = isYZAxisInverseRotation ? 1.0f : 0.0f;
	
	if(orientationValue == PLOrientationLandscape)
	{
		if(isPitchEnabled)
			glRotatef(rotationSign * rotationValue.yaw * (isReverseRotation ? -1.0f : 1.0f), 1.0f, 0.0f, 0.0f);
		if(isYawEnabled)
			glRotatef(rotationSign * rotationValue.pitch * (isReverseRotation ? 1.0f : -1.0f), 0.0f, yDirection, zDirection);
	}
	else
	{
		if(isPitchEnabled)
			glRotatef(rotationSign * rotationValue.pitch * (isReverseRotation ? 1.0f : -1.0f), 1.0f, 0.0f, 0.0f);
		if(isYawEnabled)
			glRotatef(rotationSign * rotationValue.yaw * (isReverseRotation ? 1.0f : -1.0f), 0.0f, yDirection, zDirection);
	}
	if(isRollEnabled)
		glRotatef(rotationValue.roll * (isReverseRotation ? 1.0f : -1.0f), 0.0f, yDirection, zDirection);
}

#pragma mark -
#pragma mark render methods

- (void)beginRender
{
	glPushMatrix();
	[self rotate];
	[self translate];
}

- (void)endRender
{
	glPopMatrix();
}

- (BOOL)render
{
	if(isVisible && isValid)
	{
		[self beginRender];
		[self internalRender];
		[self endRender];
		return YES;
	}
	return NO;
}

- (void)internalRender
{
}

#pragma mark -
#pragma mark swap methods

- (void)swapPitchValues
{
	[self swapPitchValuesWithSign:NO];
}

- (void)swapPitchValuesWithSign:(BOOL)sign
{
	if(sign)
	{
		pitchRange.min = -pitchRange.min;
		pitchRange.max = -pitchRange.max;
	}
	[PLUtils swapFloatValues:&pitchRange.min :&pitchRange.max];
}

- (void)swapYawValues
{
	[self swapYawValuesWithSign:NO];
}

- (void)swapYawValuesWithSign:(BOOL)sign
{
	if(sign)
	{
		yawRange.min = -yawRange.min;
		yawRange.max = -yawRange.max;
	}
	[PLUtils swapFloatValues:&yawRange.min :&yawRange.max];
}

- (void)swapPitchRangeByYawRange:(BOOL)isSwapPitchValues isSwapYawValues:(BOOL)isSwapYawValues isSwapPitchSign:(BOOL)isSwapPitchSign isSwapYawSign:(BOOL)isSwapYawSign
{
	if(isSwapPitchValues)
		[self swapPitchValues];
	if(isSwapYawValues)
		[self swapYawValues];
	
	if(isSwapPitchSign)
		pitchRange = PLRangeMake(-pitchRange.min, -pitchRange.max);
	if(isSwapYawSign)
		yawRange = PLRangeMake(-yawRange.min, -yawRange.max);
	
	PLRange swapRange = pitchRange;
	pitchRange = yawRange;
	yawRange = swapRange;
}

- (void)swapPitchRangeByYawRange:(int)swapPitchValue swapYawValue:(int)swapYawValue
{
	[self swapPitchRangeByYawRange:swapPitchValue isSwapYawValues:swapYawValue isSwapPitchSign:swapPitchValue < 0 isSwapYawSign:swapYawValue < 0];
}

#pragma mark -
#pragma mark orientation methods

- (void)setOrientation:(UIDeviceOrientation)value
{
	if(value != UIDeviceOrientationFaceUp && value != UIDeviceOrientationFaceDown)
	{
		if(orientation != value)
		{
			oldOrientation = orientation;
			orientation = value;
			[self changeOrientation:orientation oldOrientation:oldOrientation];
		}
	}
}

- (void)changeOrientation:(UIDeviceOrientation)orientationValue oldOrientation:(UIDeviceOrientation)oldOrientationValue
{	
	float pitch = rotation.pitch, yaw = rotation.yaw;
	float swap = rotation.pitch;
	switch (orientationValue) 
	{
		//The orientation of the device cannot be determined.
		case UIDeviceOrientationUnknown:
		//The device is in portrait mode, with the device held upright and the home button at the bottom. (normal)
		case UIDeviceOrientationPortrait:
			switch(oldOrientationValue)
		{
			case UIDeviceOrientationPortraitUpsideDown:
				pitch = -pitch;
				yaw = -yaw;
				[self swapPitchValuesWithSign:YES];
				[self swapYawValuesWithSign:YES];
				break;
			case UIDeviceOrientationLandscapeLeft:
				pitch = yaw;
				yaw = -swap;
				[self swapPitchRangeByYawRange:0 swapYawValue:-1];
				break;
			case UIDeviceOrientationLandscapeRight:
				pitch = -yaw;	
				yaw = swap;
				[self swapPitchRangeByYawRange:-1 swapYawValue:0];
				break;
		}
			break;
		//The device is in portrait mode but upside down, with the device held upright and the home button at the top. (normal mirror)
		case UIDeviceOrientationPortraitUpsideDown:
			switch(oldOrientationValue)
		{
			case UIDeviceOrientationPortrait:
				pitch = -pitch;
				yaw = -yaw;
				[self swapPitchValuesWithSign:YES];
				[self swapYawValuesWithSign:YES];
				break;
			case UIDeviceOrientationLandscapeLeft:
				pitch = -yaw;
				yaw = swap;
				[self swapPitchRangeByYawRange:-1 swapYawValue:0];
				break;
			case UIDeviceOrientationLandscapeRight:
				pitch = yaw;
				yaw = -swap;
				[self swapPitchRangeByYawRange:0 swapYawValue:-1];
				break;
		}
			break;
		//The device is in landscape mode, with the device held upright and the home button on the right side. (button right side)
		case UIDeviceOrientationLandscapeLeft:
			switch(oldOrientationValue)
		{
			case UIDeviceOrientationUnknown:
			case UIDeviceOrientationPortrait:
				pitch = -yaw;
				yaw = swap;
				[self swapPitchRangeByYawRange:-1 swapYawValue:0];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				pitch = yaw;
				yaw = -swap;
				[self swapPitchRangeByYawRange:0 swapYawValue:-1];
				break;
			case UIDeviceOrientationLandscapeRight:
				pitch = -pitch;
				yaw = -yaw;
				[self swapPitchValuesWithSign:YES];
				[self swapYawValuesWithSign:YES];
				break;
		}
			break;
		//The device is in landscape mode, with the device held upright and the home button on the left side. (button left side)
		case UIDeviceOrientationLandscapeRight:
			switch(oldOrientationValue)
		{
			case UIDeviceOrientationUnknown:
			case UIDeviceOrientationPortrait:
				pitch = yaw;
				yaw = -swap;
				[self swapPitchRangeByYawRange:0 swapYawValue:-1];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				pitch = -yaw;
				yaw = swap;
				[self swapPitchRangeByYawRange:-1 swapYawValue:0];
				break;
			case UIDeviceOrientationLandscapeLeft:
				pitch = -pitch;
				yaw = -yaw;
				[self swapPitchValuesWithSign:YES];
				[self swapYawValuesWithSign:YES];
				break;
		}
			break;
	}
	rotation.pitch = pitch;
	rotation.yaw = yaw;
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc
{
	[super dealloc];
}

@end
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

#import "PLCamera.h"

@interface  PLCamera()

- (void)initializeValues;

- (void)calculateFov;

@end


@implementation PLCamera

@synthesize isFovEnabled;
@synthesize fov, fovSensitivity;
@synthesize fovFactor;
@synthesize fovRange;
@synthesize minDistanceToEnableFov;

#pragma mark -
#pragma mark init methods

+ (id)camera
{
	return [[PLCamera alloc] init];
}

- (void)initializeValues
{
	fovRange = PLRangeMake(kDefaultFovMinValue, kDefaultFovMaxValue);
	isFovEnabled = YES;
	fovSensitivity = kDefaultFovSensitivity;
	minDistanceToEnableFov = kDefaultMinDistanceToEnableFov;
	[super initializeValues];
	isValid = YES;
}

- (void)reset
{
	[self calculateFov];
	[super reset];
}

#pragma mark -
#pragma mark fov methods

- (void)calculateFov
{
	fov = fovRange.min <= 0.0f ? (fovRange.max >= 0.0f ? 0.0f : fovRange.max) : fovRange.min;
	self.fov = fov;
}

- (void)setFovRange:(PLRange)value
{
	if(value.max >= value.min)
	{			
		fovRange = PLRangeMake(value.min < kFovMinValue ? kFovMinValue : value.min, value.max > kFovMaxValue ? kFovMaxValue : value.max);
		[self calculateFov];
	}
}

- (void)setMinDistanceToEnableFov:(NSUInteger)value
{
	if(value > 0)
		minDistanceToEnableFov = value;
}

- (void)setFovSensitivity:(float)value
{
	if(value > 0.0f)
		fovSensitivity = value;
}

- (void)setFov:(float)value
{
	if(isFovEnabled)
	{
		fov = [PLMath normalizeFov:value range:fovRange];
		if(fov < 0.0f)
			fovFactor = kFovFactorOffsetValue + kFovFactorNegativeOffsetValue * (fov / kDefaultFovFactorMinValue);
		else if(fov >= 0.0f)
			fovFactor = kFovFactorOffsetValue + kFovFactorPositiveOffsetValue * (fov / kDefaultFovFactorMaxValue);
	}
}

- (void)addFovWithDistance:(float)distance;
{
	self.fov += (distance / fovSensitivity);
}

- (void)addFovWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint sign:(int)sign
{
	[self addFovWithDistance: [PLMath distanceBetweenPoints:startPoint :endPoint] * (sign < 0 ? -1 : 1)];
}

#pragma mark -
#pragma mark utility methods

- (void)cloneCameraProperties:(PLCamera *)value
{
	[super clonePropertiesOf:(PLObject *)value];
	fovRange = value.fovRange;
	isFovEnabled = value.isFovEnabled;
	fovSensitivity = value.fovSensitivity;
	minDistanceToEnableFov = value.minDistanceToEnableFov;
	self.fov = value.fov;
}

#pragma mark -
#pragma mark render methods

- (void)beginRender
{
	[self rotate];
	[self translate];
}

- (void)endRender
{
}

- (void)internalRender
{
}

@end

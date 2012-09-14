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

#import "PLObject.h"

@interface PLObject()

- (void)initializeValues;

@end


@implementation PLObject

@synthesize isXAxisEnabled, isYAxisEnabled, isZAxisEnabled;
@synthesize position;
@synthesize xRange, yRange, zRange;

@synthesize isPitchEnabled, isYawEnabled, isRollEnabled, isReverseRotation, isYZAxisInverseRotation;
@synthesize rotation;
@synthesize pitchRange, yawRange, rollRange;
@synthesize rotateSensitivity;
@synthesize x,y,z,yaw,pitch,roll;

@synthesize orientation;

#pragma mark -
#pragma mark init methods

- (id)init
{
	if(self = [super init])
		[self initializeValues];
	return self;
}

- (void)initializeValues
{
	xRange = yRange = zRange = PLRangeMake(kFloatMinValue, kFloatMaxValue);
	
	pitchRange = PLRangeMake(kDefaultPitchMinRange, kDefaultPitchMaxRange);
	yawRange = PLRangeMake(kDefaultYawMinRange, kDefaultYawMaxRange);
	rollRange = PLRangeMake(kDefaultRotateMinRange, kDefaultRotateMaxRange);
	
	isXAxisEnabled = isYAxisEnabled = isZAxisEnabled = YES;
	isPitchEnabled = isYawEnabled = isRollEnabled = YES;
	
	rotateSensitivity = kDefaultRotateSensitivity;	
	isReverseRotation = NO;
	
	isYZAxisInverseRotation = YES;
	
	oldOrientation = orientation = UIDeviceOrientationUnknown;
	
	position = PLPositionMake(0.0f, 0.0f, 0.0f);
	
	[self reset];
}

- (void)reset
{
	rotation = PLRotationMake(0.0f, 0.0f, 0.0f);
}

#pragma mark -
#pragma mark translate methods

- (void)translateWithX:(float)xValue y:(float)yValue
{
	position.x = xValue;
	position.y = yValue;
}

- (void)translateWithX:(float)xValue y:(float)yValue z:(float)zValue
{
	position = PLPositionMake(xValue, yValue, zValue);
}

#pragma mark -
#pragma mark rotate methods

- (void)rotateWithPitch:(float)pitchValue yaw:(float)yawValue
{
	self.pitch = pitchValue;
	self.yaw = yawValue;
}

- (void)rotateWithPitch:(float)pitchValue yaw:(float)yawValue roll:(float)rollValue
{
	self.rotation = PLRotationMake(pitchValue, yawValue, rollValue);
}

- (void)rotateWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
	[self rotateWithStartPoint:startPoint endPoint:endPoint sensitivity:rotateSensitivity];
}

- (void)rotateWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint sensitivity:(float)sensitivity
{
    //Note- uses setter functions to excecute actual changes in pitch rather than setting the variables 'pitch' and 'yaw'... tsk tsk tsk...
    //NSLog(@"start:%f %f end:%f %f",startPoint.x,startPoint.y,endPoint.x,endPoint.y);
	//self.pitch = (endPoint.y - startPoint.y) / sensitivity;
	//self.yaw = (startPoint.x - endPoint.x) / sensitivity;
    [self setScrollPitch:((endPoint.y - 208) / (sensitivity*3))];
    [self setScrollYaw:((160 - endPoint.x) / (sensitivity*3))];
}

#pragma mark -
#pragma mark position property methods

- (void)setPosition:(PLPosition)value
{
	[self setX:value.x];
	[self setY:value.y];
	[self setZ:value.z];
}

- (float)getX
{
	return position.x;
}

- (void)setX:(float)value
{
	if(isXAxisEnabled)
		position.x = [PLMath valueInRange:value range:xRange];
}

- (float)getY
{
	return position.y;
}

- (void)setY:(float)value
{
	if(isYAxisEnabled)
		position.y = [PLMath valueInRange:value range:yRange];
}

- (float)getZ
{
	return position.z;
}

- (void)setZ:(float)value
{
	if(isZAxisEnabled)
		position.z = [PLMath valueInRange:value range:zRange];
}

#pragma mark -
#pragma mark rotation property methods

- (void)setRotation:(PLRotation)value
{
	[self setPitch:value.pitch];
	[self setYaw:value.yaw];
	[self setRoll:value.roll];
}

- (float)getPitch
{
	return rotation.pitch;
}

- (void)setPitch:(float)value
{
	if(isPitchEnabled)
		rotation.pitch = [PLMath normalizeAngle:value range:pitchRange];
}

- (void)setScrollPitch:(float)value
{
	if(isPitchEnabled)
		rotation.pitch += [PLMath normalizeAngle:value range:pitchRange];
}
		
- (float)getYaw
{
	return rotation.yaw;
}

- (void)setYaw:(float)value
{
	if(isYawEnabled)
		rotation.yaw = [PLMath normalizeAngle:value range:PLRangeMake(-yawRange.max, -yawRange.min)];
}

- (void)setScrollYaw:(float)value
{
    if(isYawEnabled)
		rotation.yaw += [PLMath normalizeAngle:value range:PLRangeMake(-yawRange.max, -yawRange.min)];
}

- (float)getRoll
{
	return rotation.roll;
}

- (void)setRoll:(float)value
{
	if(isRollEnabled)
		rotation.roll = [PLMath normalizeAngle:value range:rollRange];
}

#pragma mark -
#pragma mark orientation methods

- (void)setOrientation:(UIDeviceOrientation)value
{
	if(value != UIDeviceOrientationFaceUp && value != UIDeviceOrientationFaceDown)
	{
		oldOrientation = orientation;
		orientation = value;
	}
}

#pragma mark -
#pragma mark utility methods

- (void)clonePropertiesOf:(PLObject *)value
{	
	self.isXAxisEnabled = value.isXAxisEnabled;
	self.isYAxisEnabled = value.isYAxisEnabled;
	self.isZAxisEnabled = value.isZAxisEnabled;
	
	self.isPitchEnabled = value.isPitchEnabled;
	self.isYawEnabled = value.isYawEnabled;
	self.isRollEnabled = value.isRollEnabled;
	
	self.isReverseRotation = value.isReverseRotation;
	
	self.isYZAxisInverseRotation = value.isYZAxisInverseRotation;
	
	self.rotateSensitivity = value.rotateSensitivity;
	
	self.xRange = value.xRange;
	self.yRange = value.yRange;
	self.zRange = value.zRange;
	
	self.pitchRange = value.pitchRange;
	self.yawRange = value.yawRange;
	self.rollRange = value.rollRange;
	
	self.x = value.x;
	self.y = value.y;
	self.z = value.z;
	
	self.pitch = value.pitch;
	self.yaw = value.yaw;
	self.roll = value.roll;
	
	self.orientation = value.orientation;
}

@end


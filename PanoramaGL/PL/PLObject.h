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

#import <Foundation/Foundation.h>

#import "PLStructs.h"
#import "PLMath.h"

@interface PLObject : NSObject 
{
	BOOL isXAxisEnabled, isYAxisEnabled, isZAxisEnabled;
	PLPosition position;
	PLRange xRange, yRange, zRange;
	
	BOOL isPitchEnabled, isYawEnabled, isRollEnabled, isReverseRotation, isYZAxisInverseRotation;
	PLRotation rotation;
	PLRange pitchRange, yawRange, rollRange;
	float rotateSensitivity;
	
	UIDeviceOrientation oldOrientation, orientation;
}

@property(nonatomic) BOOL isXAxisEnabled, isYAxisEnabled, isZAxisEnabled;
@property(nonatomic) PLPosition position;
@property(nonatomic, getter=getX, setter=setX) float x;
@property(nonatomic, getter=getY, setter=setY) float y;
@property(nonatomic, getter=getZ, setter=setZ) float z;
@property(nonatomic) PLRange xRange, yRange, zRange;

@property(nonatomic) BOOL isPitchEnabled, isYawEnabled, isRollEnabled, isReverseRotation, isYZAxisInverseRotation;
@property(nonatomic) PLRotation rotation;
@property(nonatomic, getter=getPitch, setter=setPitch) float pitch;
@property(nonatomic, getter=getYaw, setter=setYaw) float yaw;
@property(nonatomic, getter=getRoll, setter=setRoll) float roll;
@property(nonatomic) PLRange pitchRange, yawRange, rollRange;
@property(nonatomic) float rotateSensitivity;

@property(nonatomic) UIDeviceOrientation orientation;

- (void)reset;

- (float)getX;
- (void)setX:(float)value;
- (float)getY;
- (void)setY:(float)value;
- (float)getZ;
- (void)setZ:(float)value;

- (float)getPitch;
- (void)setPitch:(float)value;
- (float)getYaw;
- (void)setYaw:(float)value;
- (float)getRoll;
- (void)setRoll:(float)value;

- (void)translateWithX:(float)xValue y:(float)yValue;
- (void)translateWithX:(float)xValue y:(float)yValue z:(float)zValue;

- (void)rotateWithPitch:(float)pitchValue yaw:(float)yawValue;
- (void)rotateWithPitch:(float)pitchValue yaw:(float)yawValue roll:(float)rollValue;
- (void)rotateWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint) endPoint;
- (void)rotateWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint sensitivity:(float)sensitivity;

- (void)clonePropertiesOf:(PLObject *)value;

@end

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

#import "PLSceneElementBase.h"

@interface PLCamera : PLSceneElementBase 
{
	BOOL isFovEnabled;
	float fov, fovFactor, fovSensitivity;
	PLRange fovRange;
	NSUInteger minDistanceToEnableFov;
}

@property(nonatomic) BOOL isFovEnabled;
@property(nonatomic) float fov, fovSensitivity;
@property(nonatomic, readonly) float fovFactor;
@property(nonatomic) PLRange fovRange;
@property(nonatomic) NSUInteger minDistanceToEnableFov;

+ (id)camera;

- (void)addFovWithDistance:(float)distance;
- (void)addFovWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint sign:(int)sign;

- (void)cloneCameraProperties:(PLCamera *)value;

@end
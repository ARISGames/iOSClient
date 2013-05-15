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

#pragma mark -
#pragma mark structs definitions

struct PLRange 
{
	CGFloat min;
	CGFloat max;
};
typedef struct PLRange PLRange;

struct PLVertex 
{
	CGFloat x, y, z;
};
typedef struct PLVertex PLVertex;
typedef struct PLVertex PLPosition;

struct PLRotation
{
	CGFloat pitch, yaw, roll;
};
typedef struct PLRotation PLRotation;

struct PLShakeData
{
	long lastTime;
	PLPosition shakePosition;
	PLPosition shakeLastPosition;
};
typedef struct PLShakeData PLShakeData;

#pragma mark -
#pragma mark structs constructors

CG_INLINE PLRange
PLRangeMake(CGFloat min, CGFloat max)
{
	PLRange range = {min, max};
	return range;
}

CG_INLINE PLVertex
PLVertexMake(CGFloat x, CGFloat y, CGFloat z)
{
	PLVertex vertex = {x, y, z};
	return vertex;
}

CG_INLINE PLPosition
PLPositionMake(CGFloat x, CGFloat y, CGFloat z)
{
	PLPosition position = {x, y, z};
	return position;
}

CG_INLINE PLRotation
PLRotationMake(CGFloat pitch, CGFloat yaw, CGFloat roll)
{
	PLRotation rotation = {pitch, yaw, roll};
	return rotation;
}

CG_INLINE PLShakeData
PLShakeDataMake(long lastTime)
{
	PLShakeData shakeData = {lastTime, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};
	return shakeData;
}
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

#import "PLMath.h"

@implementation PLMath

#pragma mark -
#pragma mark distance methods

+ (float)distanceBetweenPoints:(CGPoint)point1 :(CGPoint)point2;
{
	return sqrt(((point2.x - point1.x) * (point2.x - point1.x)) + ((point2.y - point1.y) * (point2.y - point1.y)));
}

#pragma mark -
#pragma mark range methods

+ (float)valueInRange:(float)value range:(PLRange)range
{
	return MAX(range.min, MIN(value, range.max));
}

#pragma mark -
#pragma mark normalize methods

+ (float)normalizeAngle:(float)angle range:(PLRange)range;
{	
	float result = angle;
    if( range.min < 0.0f )
	{
        while (result <= -180.0f) result += 360.0f;
        while (result > 180.0f) result -= 360.0f;
    } 
	else 
	{
        while (result < 0.0f) result += 360.0f;
        while (result >= 360.0f) result -= 360.0f;
    }
	return [PLMath valueInRange:result range:range];
}

+ (float)normalizeFov:(float)fov range:(PLRange)range
{
	return [PLMath valueInRange:fov range:range];
}

+ (BOOL)isPowerOfTwo:(int)value
{
	while (!(value & 1))
		value = value >> 1;
	return (value == 1);
}

@end

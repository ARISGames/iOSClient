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

#import "PLControlZoomIn.h"

@implementation PLControlZoomIn

#pragma mark -
#pragma mark init methods

- (id)initWithView:(PLViewBase *)plView position:(CGPoint)positionValue size:(CGSize)sizeValue
{
	self = [super initWithView:plView position:(CGPoint)positionValue size:(CGSize)sizeValue image:PLResourceIdZoomIn overImage:PLResourceIdZoomInOver];
	return self;
}

+ (PLControlZoomIn *)controlZoomInWithView:(PLViewBase *)plView position:(CGPoint)positionValue size:(CGSize)sizeValue
{
	return [[PLControlZoomIn alloc] initWithView:plView position:positionValue size:sizeValue];
}

@end

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

@interface PLSceneElement(Protected)

- (void)evaluateIfElementIsValid;

@end


@implementation PLSceneElement

#pragma mark -
#pragma mark init methods

- (id)initWithId:(int)identificatorValue
{
	if(self = [super init])
		identificator = identificatorValue;
	return self;
}

- (id)initWithId:(int)identificatorValue texture:(PLTexture *)texture
{
	if(self = [self initWithId:identificatorValue])
		[self addTexture:texture];
	return self;
}

- (id)initWithTexture:(PLTexture *)texture
{
	if(self = [super init])
		[self addTexture:texture];
	return self;
}

- (void)initializeValues
{
	[super initializeValues];
	textures = [[NSMutableArray alloc] init];
}

#pragma mark -
#pragma mark texture methods

- (NSMutableArray *)getTextures
{
	return textures;
}

- (void)addTexture:(PLTexture *)texture
{
	if(texture && texture.isValid)
	{
		[textures addObject:texture];
		[self evaluateIfElementIsValid];
	}
}

- (void)addTextureAndRelease:(PLTexture *)texture
{
	[self addTexture:texture];
	if(texture)
		[texture release];
}

- (void)removeTexture:(PLTexture *)texture
{
	if(texture && texture.isValid)
	{
		[textures removeObject:texture];
		[self evaluateIfElementIsValid];
	}
}

- (void)removeTextureAtIndex:(NSUInteger)index
{
	[textures removeObjectAtIndex:index];
	[self evaluateIfElementIsValid];
}

- (void)removeAllTextures
{
	[textures removeAllObjects];
	[self evaluateIfElementIsValid];
}

#pragma mark -
#pragma mark utility methods

- (void)evaluateIfElementIsValid
{
	isValid = [textures count] > 0; 
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc
{
	if(textures)
	{
		[self removeAllTextures];
		[textures release];
	}
	[super dealloc];
}

@end
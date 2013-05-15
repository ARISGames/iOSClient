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

#import "PLView.h"

@interface PLView ()

- (void)initializeValues;

@end

@implementation PLView

@synthesize type;

#pragma mark -
#pragma mark init methods

- (void)initializeValues
{
	[super initializeValues];
	textures = [[NSMutableArray array] retain];
	type = PLViewTypeUnknown;
}

- (void)reset
{
	[super reset];
	if(scene && scene.currentCamera)
		[scene.currentCamera reset];
}

#pragma mark -
#pragma mark property methods

- (void)setType:(PLViewType)value
{
	type = value;
	if(sceneElement)
		[sceneElement release];
	
	switch (value)
	{
		case PLViewTypeCylindrical:
			sceneElement = [PLCylinder cylinder];
			break;
		case PLViewTypeSpherical:
			sceneElement = [PLSphere sphere];
			break;
		case PLViewTypeCubeFaces:
			sceneElement = [PLCube cube];
			break;
		case PLViewTypeUnknown:
			sceneElement = nil;
			break;
		default:
			[NSException raise:@"Invalid panorama type" format:@"Type unknown", nil];
			break;
	}
	
	if(sceneElement)
	{
		sceneElement = [sceneElement retain];
		for(PLTexture * texture in textures)
			[sceneElement addTexture:texture];
		[scene removeAllElements];
		[scene addElement:sceneElement];
	}
}

#pragma mark -
#pragma mark draw methods

- (void)drawViewInternally
{
	[super drawViewInternally];
	if(!isValidForFov && !isValidForOrientation && isScrollingEnabled)
		[scene.currentCamera rotateWithStartPoint:startPoint endPoint:endPoint sensitivity:scene.currentCamera.rotateSensitivity];
	[renderer render];
}

#pragma mark -
#pragma mark fov methods

- (BOOL)calculateFov:(NSSet *)touches
{
	if([super calculateFov:touches])
	{
		[scene.currentCamera addFovWithDistance:fovDistance];
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark texture methods

- (void)addTexture:(PLTexture *)texture
{
	if(texture)
	{
		[textures addObject:texture];
		if(sceneElement)
			[sceneElement addTexture:texture];
	}
}

- (void)addTextureAndRelease:(PLTexture *)texture
{
	if(texture)
	{
		[textures addObject:texture];
		if(sceneElement)
			[sceneElement addTextureAndRelease:texture];
	}
}
				
- (void)removeTexture:(PLTexture *)texture
{
	if(texture)
	{
		[textures removeObject:texture];
		if(sceneElement)
			[sceneElement removeTexture:texture];
	}
}
				
- (void)removeTextureAtIndex:(NSUInteger) index
{
	[textures removeObjectAtIndex:index];
	if(sceneElement)
		[sceneElement removeTextureAtIndex:index];
}
				
- (void)removeAllTextures
{
	[textures removeAllObjects];
	if(sceneElement)
		[sceneElement removeAllTextures];
}

#pragma mark -
#pragma mark orientation methods

- (void)orientationChanged:(UIDeviceOrientation)orientation
{
	if(scene && scene.currentCamera)
		scene.currentCamera.orientation = orientation;
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc 
{    
	if(textures)
		[textures release];
	if(sceneElement)
		[sceneElement release];
	[super dealloc];
}
				
@end

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

#import "PLScene.h"

@interface  PLScene()

- (void)initializeValues;

@end


@implementation PLScene

@synthesize cameras;
@synthesize currentCamera;
@synthesize cameraIndex;

@synthesize elements;

#pragma mark -
#pragma mark init methods

- (id)init
{
	if(self = [super init])
	{
		[self initializeValues];
		[self addCamera: [[PLCamera camera] retain]];
	}
	return self;
}

- (id)initWithCamera:(PLCamera *)camera
{
	if(self = [super init])
	{
		[self initializeValues];
		[self addCamera:camera];
	}
	return self;
}

- (id)initWithElement:(PLSceneElement *)element
{
	return [self initWithElement:element camera:[[[PLCamera alloc] init] retain]];
}

- (id)initWithElement:(PLSceneElement *)element camera:(PLCamera *)camera
{
	if(self = [super init])
	{
		[self initializeValues];
		[self addElement:element];
		[self addCamera:camera];
	}
	return self;
}

+ (id)scene
{
	return [[PLScene alloc] init];
}

+ (id)sceneWithCamera:(PLCamera *)camera
{
	return [[PLScene alloc] initWithCamera:camera];
}

+ (id)sceneWithElement:(PLSceneElement *)element
{
	return [[PLScene alloc] initWithElement:element];
}

+ (id)sceneWithElement:(PLSceneElement *)element camera:(PLCamera *)camera
{
	return [[PLScene alloc] initWithElement:element camera:camera];
}

- (void)initializeValues
{
	elements = [[NSMutableArray array] retain];
	cameras = [[NSMutableArray array] retain];
}

#pragma mark -
#pragma mark camera methods

- (void)setCameraIndex:(NSUInteger)index
{
	if(index < [cameras count])
	{
		cameraIndex = index;
		currentCamera = [cameras objectAtIndex:index];
	}
}

- (void)addCamera:(PLCamera *)camera
{
	if([cameras count] == 0)
	{
		cameraIndex = 0;
		currentCamera = camera;
	}
	[cameras addObject:camera];
}

- (void)removeCameraAtIndex:(NSUInteger)index
{
	[cameras removeObjectAtIndex:index];
	if([cameras count] == 0)
	{
		currentCamera = nil;
		cameraIndex = -1;
	}
}

#pragma mark -
#pragma mark element methods

- (void)addElement:(PLSceneElement *)element
{
	[elements addObject:element];
}

- (void)removeElementAtIndex:(NSUInteger)index
{
	[elements removeObjectAtIndex:index];
}

- (void)removeAllElements
{
	[elements removeAllObjects];
}

#pragma mark -
#pragma mark dealloc methods

- (void)dealloc
{
	if(elements)
		[elements release];
	if(cameras)
		[cameras release];
	if(currentCamera)
		[currentCamera release];
	[super dealloc];
}

@end

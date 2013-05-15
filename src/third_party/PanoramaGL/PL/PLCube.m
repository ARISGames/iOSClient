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

#import "PLCube.h"

@implementation PLCube

#pragma mark -
#pragma mark init methods

+ (id)cube
{
	return [[PLCube alloc] init];
}

+ (id)cubeWithTextures:(PLTexture *)front :(PLTexture *)back :(PLTexture *)left :(PLTexture *)right :(PLTexture *)top :(PLTexture *)bottom
{
	PLCube * cube = [PLCube cube];
	[cube addTexture:front];
	[cube addTexture:back];
	[cube addTexture:left];
	[cube addTexture:right];
	[cube addTexture:top];
	[cube addTexture:bottom];
	return cube;
}

#pragma mark -
#pragma mark utility methods

- (void)evaluateIfElementIsValid
{
	isValid = ([textures count] >= 6);
}

#pragma mark -
#pragma mark render methods

- (void)internalRender
{	
	#define R kRatio
	static GLfloat cube[] = 
	{
		// Front Face
		-R, -R,  R,
		 R, -R,  R,
		-R,  R,  R,
		 R,  R,  R,
		// Back Face
		-R, -R, -R,
		-R,  R, -R,
		 R, -R, -R,
		 R,  R, -R,
		// Right Face
		-R, -R,  R,
		-R,  R,  R,
		-R, -R, -R,
		-R,  R, -R,
		// Left Face
		 R, -R, -R,
	 	 R,  R, -R,
		 R, -R,  R,
		 R,  R,  R,
		// Top Face
		-R,  R,  R,
		 R,  R,  R,
		-R,  R, -R,
		 R,  R, -R,
		// Bottom Face
		-R, -R,  R,
		-R, -R, -R,
		 R, -R,  R,
		 R, -R, -R,
	};
	
	static GLfloat textureCoords[] = 
	{
		// Front Face
		0.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 1.0f,
		1.0f, 1.0f,
		// Back Face
		1.0f, 0.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,
		// Right Face
		1.0f, 0.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,
		// Left Face
		1.0f, 0.0f,
		1.0f, 1.0f,
		0.0f, 0.0f,
		0.0f, 1.0f,
		// Top Face
		0.0f, 0.0f,
		1.0f, 0.0f,
		0.0f, 1.0f,
		1.0f, 1.0f,
		// Bottom Face
		0.0f, 1.0f,
		0.0f, 0.0f,
		1.0f, 1.0f,
		1.0f, 0.0f
	};
	
	glRotatef(90.0f, 1.0f, 0.0f, 0.0f);
	
	glEnable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	glVertexPointer(3, GL_FLOAT, 0, cube);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	glShadeModel(GL_SMOOTH);
	
	// Front Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeFrontFaceIndex]).textureId);
	glNormal3f(0.0f, 0.0f, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// Back Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeBackFaceIndex]).textureId);
	glNormal3f(0.0f, 0.0f, -1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 4, 4);
	
	// Right Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeRightFaceIndex]).textureId);
	glNormal3f(-1.0f, 0.0f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 8, 4);
	
	// Left Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeLeftFaceIndex]).textureId);
	glNormal3f(1.0f, 0.0f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 12, 4);
	
	// Top Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeTopFaceIndex]).textureId);
	glNormal3f(0.0f, 1.0f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 16, 4);
	
	// Bottom Face
	glBindTexture(GL_TEXTURE_2D, ((PLTexture *)[textures objectAtIndex:kCubeBottomFaceIndex]).textureId);
	glNormal3f(0.0f, -1.0f, 0.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 20, 4);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
	glDisable(GL_CULL_FACE);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
}

@end

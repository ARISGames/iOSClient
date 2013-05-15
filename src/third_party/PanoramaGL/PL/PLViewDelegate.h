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

@class PLViewBase;

#import "PLStructs.h"
#import "PLEnums.h"

@protocol PLViewDelegate

@optional

- (BOOL)view:(PLViewBase *)plView shouldBeginTouching:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)view:(PLViewBase *)plView didBeginTouching:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)view:(PLViewBase *)plView shouldTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)view:(PLViewBase *)plView didTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)view:(PLViewBase *)plView shouldEndTouching:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)view:(PLViewBase *)plView didEndTouching:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL)view:(PLViewBase *)plView shouldRotate:(UIDeviceOrientation)orientation;
- (void)view:(PLViewBase *)plView didRotate:(UIDeviceOrientation)orientation;

- (BOOL)view:(PLViewBase *)plView shouldAccelerate:(UIAcceleration *)acceleration withAccelerometer:(UIAccelerometer *)accelerometer;
- (void)view:(PLViewBase *)plView didAccelerate:(UIAcceleration *)acceleration withAccelerometer:(UIAccelerometer *)accelerometer;

- (BOOL)view:(PLViewBase *)plView shouldBeginInertia:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didBeginInertia:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (BOOL)view:(PLViewBase *)plView shouldRunInertia:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didRunInertia:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didEndInertia:(CGPoint)starPoint endPoint:(CGPoint)endPoint;

- (BOOL)viewShouldReset:(PLViewBase *)plView;
- (void)viewDidReset:(PLViewBase *)plView;

- (BOOL)viewShouldBeginZooming:(PLViewBase *)plView;
- (void)view:(PLViewBase *)plView didBeginZooming:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (BOOL)view:(PLViewBase *)plView shouldRunZooming:(float)distance isZoomIn:(BOOL)isZoomIn isZoomOut:(BOOL)isZoomOut;
- (void)view:(PLViewBase *)plView didRunZooming:(float)distance isZoomIn:(BOOL)isZoomIn isZoomOut:(BOOL)isZoomOut;
- (void)view:(PLViewBase *)plView didEndZooming:(float)distance isZoomIn:(BOOL)isZoomIn isZoomOut:(BOOL)isZoomOut;

- (BOOL)view:(PLViewBase *)plView shouldBeginMoving:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didBeginMoving:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (BOOL)view:(PLViewBase *)plView shouldRunMoving:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didRunMoving:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didEndMoving:(CGPoint)starPoint endPoint:(CGPoint)endPoint;

- (BOOL)view:(PLViewBase *)plView shouldBeingScrolling:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didBeginScrolling:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (BOOL)view:(PLViewBase *)plView shouldScroll:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didScroll:(CGPoint)starPoint endPoint:(CGPoint)endPoint;
- (void)view:(PLViewBase *)plView didEndScrolling:(CGPoint)starPoint endPoint:(CGPoint)endPoint;

@end

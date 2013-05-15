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
#pragma mark utility consts

#define kFloatMinValue -1000000.0f //FLT_MIN
#define kFloatMaxValue  FLT_MAX
#define kPI				3.14159265358979323846f

#pragma mark -
#pragma mark buffer consts

#define kUseDepthBuffer 0

#pragma mark -
#pragma mark texture consts

#define kTextureMaxWidth	2048
#define kTextureMaxHeight	2048

#pragma mark -
#pragma mark cube consts

#define kCubeFrontFaceIndex		0
#define kCubeBackFaceIndex		1
#define kCubeLeftFaceIndex		2
#define kCubeRightFaceIndex		3
#define kCubeTopFaceIndex		4
#define kCubeBottomFaceIndex	5

#pragma mark -
#pragma mark sphere consts

#define kDefaultSphereDivs 30

#pragma mark -
#pragma mark cylinder consts

#define kDefaultCylinderDivs		60
#define kDefaultCylinderHeight		3.0f
#define kDefaultCylinderHeightCalc	YES

#pragma mark -
#pragma mark rotation consts

#define kDefaultRotateSensitivity		30.0f
#define kDefaultAnimationTimerInterval	1.0/45.0

#define kDefaultRotateMinRange -180.0f
#define kDefaultRotateMaxRange  180.0f

#define kDefaultYawMinRange -180.f
#define kDefaultYawMaxRange  180.f

#define kDefaultPitchMinRange -90.0f
#define kDefaultPitchMaxRange  90.0f

#pragma mark -
#pragma mark fov (field of view) consts

#define kDefaultFovSensitivity -1.0f

#define kFovMinValue -1.0f
#define kFovMaxValue  1.0f

#define kDefaultFovMinValue 0.0f
#define kDefaultFovMaxValue kFovMaxValue

#define kDefaultFovFactorMinValue 0.8f
#define kDefaultFovFactorMaxValue 1.20f

#define kFovFactorOffsetValue			1.0f
#define kFovFactorNegativeOffsetValue	(kFovFactorOffsetValue - kDefaultFovFactorMinValue)
#define kFovFactorPositiveOffsetValue	(kDefaultFovFactorMaxValue - kFovFactorOffsetValue)

#define kDefaultMinDistanceToEnableFov 8

#pragma mark -
#pragma mark inertia consts

#define kDefaultInertiaInterval 3

#pragma mark -
#pragma mark accelerometer consts

#define kDefaultAccelerometerSensitivity	7.0f
#define kDefaultAccelerometerInterval		1.0f/30.0f
#define kAccelerometerSensitivityMinValue	1.0f
#define kAccelerometerSensitivityMaxValue	10.0f
#define kAccelerometerMultiplyFactor		100.0f

#pragma mark -
#pragma mark scrolling consts

#define kDefaultMinDistanceToEnableScrolling 50

#pragma mark -
#pragma mark perspective consts

#define kPerspectiveValue	290.0f
#define kPerspectiveZNear	0.01f
#define kPerspectiveZFar	100.0f

#pragma mark -
#pragma mark scene-elements consts

#define kRatio 1.0f

#pragma mark -
#pragma mark shake consts

#define kShakeThreshold 100.0f
#define kShakeDiffTime	100

#pragma mark -
#pragma mark control consts

#define kZoomControlMinWidth			64
#define kZoomControlMinHeight			40
#define kZoomControlWidthPercentage		0.2
#define kZoomControlHeightPercentage	0.1
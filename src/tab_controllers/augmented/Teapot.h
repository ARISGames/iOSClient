/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#ifndef _VUFORIA_TEAPOT_OBJECT_H_
#define _VUFORIA_TEAPOT_OBJECT_H_


#define NUM_TEAPOT_OBJECT_VERTEX 4
#define NUM_TEAPOT_OBJECT_INDEX 6


static const float teapotVertices[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    -85, -85, 0,
    85, -85, 0,
    -85, 85, 0,
    85, 85, 0
};


static const float teapotVertices_MeatPacker[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    -85, -75.703125, 0,
    85, -75.703125, 0,
    -85, 75.703125, 0,
    85, 75.703125, 0
};


static const float teapotVertices_DryCleaner[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    -85, -97.484375, 0,
    85, -97.484375, 0,
    -85, 97.484375, 0,
    85, 97.484375, 0
};


static const float teapotVertices_Theater[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    -85, -51.53125, 0,
    85, -51.53125, 0,
    -85, 51.53125, 0,
    85, 51.53125, 0
};


static const float teapotVertices_Nurse[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    -85, -48.34375, 0,
    85, -48.34375, 0,
    -85, 48.34375, 0,
    85, 48.34375, 0
};

static const float teapotTexCoords[NUM_TEAPOT_OBJECT_VERTEX * 2] =
{
    0, 0,
    1, 0,
    0, 1,
    1, 1
};

static const float teapotNormals[NUM_TEAPOT_OBJECT_VERTEX * 3] =
{
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1
};

static const unsigned short teapotIndices[NUM_TEAPOT_OBJECT_INDEX] =
{
    0,1,2, 3,2,1
};


#endif // _VUFORIA_TEAPOT_OBJECT_H_

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
    -20, -20, 0,
    20, -20, 0,
    -20, 20, 0,
    20, 20, 0
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

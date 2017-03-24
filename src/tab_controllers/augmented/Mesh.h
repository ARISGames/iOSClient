/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#ifndef _VUFORIA_VMESH_H_ //apparently _VUFORIA_MESH_H_ is already defined somewhere else? so I set it to _VUFORIA_VMESH_H_
#define _VUFORIA_VMESH_H_

#define NUM_MESH_VERTEX 4
#define NUM_MESH_INDEX 6

static const float meshUnitPositions[NUM_MESH_VERTEX * 3] =
{
    -1,-1, 0,
     1,-1, 0,
    -1, 1, 0,
     1, 1, 0
};

static float meshPositions[NUM_MESH_VERTEX * 3] =
{
    -1,-1, 0,
     1,-1, 0,
    -1, 1, 0,
     1, 1, 0
};

static const float meshTexCoords[NUM_MESH_VERTEX * 2] =
{
    0, 0,
    1, 0,
    0, 1,
    1, 1
};

static const float meshNormals[NUM_MESH_VERTEX * 3] =
{
    0, 0, -1,
    0, 0, -1,
    0, 0, -1,
    0, 0, -1
};

static const unsigned short meshIndices[NUM_MESH_INDEX] =
{
    0,1,2, 3,2,1
};


#endif // _VUFORIA_VMESH_H_

/*===============================================================================
 Copyright (c) 2016 PTC Inc. All Rights Reserved.
 
 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <sys/time.h>

#import <Vuforia/Vuforia.h>
#import <Vuforia/State.h>
#import <Vuforia/Tool.h>
#import <Vuforia/Renderer.h>
#import <Vuforia/TrackableResult.h>
#import <Vuforia/VideoBackgroundConfig.h>

#import "AugmentedEAGLView.h"
#import "Texture.h"
#import "SampleApplicationUtils.h"
#import "SampleApplicationShaderUtils.h"
#import "Mesh.h"
#import "AppModel.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

//******************************************************************************
// *** OpenGL ES thread safety ***
//
// OpenGL ES on iOS is not thread safe.  We ensure thread safety by following
// this procedure:
// 1) Create the OpenGL ES context on the main thread.
// 2) Start the Vuforia camera, which causes Vuforia to locate our EAGLView and start
//    the render thread.
// 3) Vuforia calls our renderFrameVuforia method periodically on the render thread.
//    The first time this happens, the defaultFramebuffer does not exist, so it
//    is created with a call to createFramebuffer.  createFramebuffer is called
//    on the main thread in order to safely allocate the OpenGL ES storage,
//    which is shared with the drawable layer.  The render (background) thread
//    is blocked during the call to createFramebuffer, thus ensuring no
//    concurrent use of the OpenGL ES context.
//
//******************************************************************************


namespace
{
  // --- Data private to this unit ---
  long cur_trigger_id;
  BOOL is_video;
  UIImage *image;
  
  AVAudioPlayer *audio;
  AVURLAsset *avurlasset;
  AVAsset *avasset;

  // Model scale factor
  const float kObjectScaleNormal = 3.0f;
  GLuint textureID;
  
  float ar_video_fps;
}

@interface AugmentedEAGLView (PrivateMethods)

- (void)initShaders;
- (void)createFramebuffer;
- (void)deleteFramebuffer;
- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end

@implementation AugmentedEAGLView

@synthesize vapp = vapp;

// You must implement this method, which ensures the view's underlying layer is
// of type CAEAGLLayer
+ (Class)layerClass
{
  return [CAEAGLLayer class];
}

//------------------------------------------------------------------------------
#pragma mark - Lifecycle

- (id) initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app
{
  self = [super initWithFrame:frame];
  
  if(self)
  {
    vapp = app;
    // Enable retina mode if available on this device
    if(YES == [vapp isRetinaDisplay]) [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
  
    cur_trigger_id = 0;
    is_video = NO;
    
    // Load the initial augmentation texture
    augmentationTexture = [[Texture alloc] initWithImageFile:[NSString stringWithCString:"black256.png" encoding:NSASCIIStringEncoding]];
    
    // Create the OpenGL ES context
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // The EAGLContext must be set for each thread that wishes to use it.
    // Set it the first time this method is called (on the main thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    // Generate the OpenGL ES texture and upload the texture data for use
    // when rendering the augmentation
    glGenTextures(1, &textureID);
    [augmentationTexture setTextureID:textureID];
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [augmentationTexture width], [augmentationTexture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture pngData]);
    
    sampleAppRenderer = [[SampleAppRenderer alloc]initWithSampleAppRendererControl:self deviceMode:Vuforia::Device::MODE_AR stereo:false nearPlane:50.0 farPlane:5000.0];
    
    [self initShaders];
    
    // we initialize the rendering method of the SampleAppRenderer
    [sampleAppRenderer initRendering];
    
    ar_video_fps = 1000./64.;
  }
  
  return self;
}

- (CGSize)getCurrentARViewBoundsSize
{
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  CGSize viewSize = screenBounds.size;
  
  viewSize.width *= [UIScreen mainScreen].nativeScale;
  viewSize.height *= [UIScreen mainScreen].nativeScale;
  return viewSize;
}

- (void)dealloc
{
  [self deleteFramebuffer];
  
  // Tear down context
  if([EAGLContext currentContext] == context)
    [EAGLContext setCurrentContext:nil];
  
  augmentationTexture = nil;
  
  [audio stop];
}

- (void)finishOpenGLESCommands
{
  // Called in response to applicationWillResignActive.  The render loop has
  // been stopped, so we now make sure all OpenGL ES commands complete before
  // we (potentially) go into the background
  if(context)
  {
    [EAGLContext setCurrentContext:context];
    glFinish();
  }
}

- (void)freeOpenGLESResources
{
  // Called in response to applicationDidEnterBackground.  Free easily
  // recreated OpenGL ES resources
  [self deleteFramebuffer];
  glFinish();
}

- (void) updateRenderingPrimitives
{
  [sampleAppRenderer updateRenderingPrimitives];
}

- (void) stopAudio
{
  [audio stop];
}

//------------------------------------------------------------------------------
#pragma mark - UIGLViewProtocol methods

// Draw the current frame using OpenGL
//
// This method is called by Vuforia when it wishes to render the current frame to
// the screen.
//
// *** Vuforia will call this method periodically on a background thread ***
- (void)renderFrameVuforia
{
  if(!vapp.cameraIsStarted) return;
  [sampleAppRenderer renderFrameVuforia];
}

- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix
{
  [self setFramebuffer];
  
  // Clear colour and depth buffers
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  // Render video background and retrieve tracking state
  [sampleAppRenderer renderVideoBackground];
  
  glEnable(GL_DEPTH_TEST);
  // We must detect if background reflection is active and adjust the culling direction.
  // If the reflection is active, this means the pose matrix has been reflected as well,
  // therefore standard counter clockwise face culling will result in "inside out" models.
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);
  
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  
  long new_trigger_id = 0;
  //const Vuforia::Trackable& trackable = result->getTrackable();
  Vuforia::Matrix44F modelViewMatrix;
  // OpenGL 2
  Vuforia::Matrix44F modelViewProjection;
  for(int i = 0; i < state.getNumTrackableResults(); ++i)
  {
    // Get the trackable
    const Vuforia::TrackableResult* result = state.getTrackableResult(i);
    const Vuforia::Trackable& trackable = result->getTrackable();
    
    //const Vuforia::Trackable& trackable = result->getTrackable();
    modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
    
    // OpenGL 2
    SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
    SampleApplicationUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);
    
    SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
    
    glActiveTexture(GL_TEXTURE0);
  
    NSArray *vals;
  
    vals = [_MODEL_AR_TARGETS_.ar_targets allValues];
    long ar_target_id = -1;
    for(int i = 0; i < vals.count; i++)
    {
      ARTarget *target = vals[i];
      if(!strcmp(trackable.getName(), [target.name UTF8String]))
        ar_target_id = target.ar_target_id;
    }
  
    vals = _MODEL_TRIGGERS_.playerTriggers;
    for(int i = 0; i < vals.count; i++)
    {
      Trigger *trigger = vals[i];
      if([trigger.type isEqualToString:@"AR"] && trigger.ar_target_id == ar_target_id)
        new_trigger_id = trigger.trigger_id;
    }
    
  }
  
  
  if(new_trigger_id != cur_trigger_id)
  {
    float width  = 1;
    float height = 1;
    if(new_trigger_id == 0)
    {
      if(is_video) //old video
        [audio stop];
      [NSString stringWithCString:"black256.png" encoding:NSASCIIStringEncoding];
      is_video = NO;
    }
    else
    {
      Trigger *trigger = [_MODEL_TRIGGERS_ triggerForId:new_trigger_id];
      Media *media = [_MODEL_MEDIA_ mediaForId:trigger.icon_media_id];
      is_video = [media.type isEqualToString:@"VIDEO"];
      if(is_video)
      {
        //short names to cope with obj-c verbosity
        NSString *g = [NSString stringWithFormat:@"%ld/AR",media.game_id]; //game_id as string
        NSString *f = [[[[media.remoteURL absoluteString] componentsSeparatedByString:@"/"] lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //filename

        NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
        NSString *audioPath = [NSString stringWithFormat:@"%@/%@.m4a",newFolder,f];
        _ARIS_LOG_(@"AR AUDIO IS %@",audioPath);
        if([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) { _ARIS_LOG_(@"GR8"); }
        
        audio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        [audio setNumberOfLoops:-1];
        [audio play];
        
        avasset = [AVAsset assetWithURL:media.localURL];
        
        avurlasset = [AVURLAsset URLAssetWithURL:media.localURL options:nil];
        NSArray *tracks = [avurlasset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = [tracks objectAtIndex:0];
        CGSize mediaSize = track.naturalSize;
        width = mediaSize.width;
        height = mediaSize.height;
        
        NSString *fps_file = [NSString stringWithFormat:@"%@/%@_done.txt", newFolder, f];
        NSString *fps_str = [NSString stringWithContentsOfFile:fps_file encoding:NSUTF8StringEncoding error:NULL];
        NSArray *fps_lines = [fps_str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        float fps_num = [fps_lines[0] integerValue];
        float fps_den = [fps_lines[1] integerValue];
        ar_video_fps = fps_num / fps_den;
      }
      else
      {
        if(media.data) image = [UIImage imageWithData:media.data];
        else if(media.localURL) image = [UIImage imageWithContentsOfFile:media.localURL.path];
        
        [augmentationTexture loadUIImage:image];
        
        width  = image.size.width;
        height = image.size.height;
      }
    }
    height /= width;
    width = 1.;
    for(int i = 0; i < 4; i++)
    {
      int j = 0;
      int index = 0;
      #define POS_SCALE 85
      index = i*3+j; meshPositions[index] = meshUnitPositions[index]*width *POS_SCALE; j++; //x
      index = i*3+j; meshPositions[index] = meshUnitPositions[index]*height*POS_SCALE; j++; //y
      index = i*3+j; meshPositions[index] = meshUnitPositions[index]*0.    *POS_SCALE; j++; //z
    }
  }
  if(is_video)
  {
    if(![audio isPlaying]) [audio play];
    int frame = [audio currentTime] * ar_video_fps;
    
    NSString *filename;
    Trigger *trigger = [_MODEL_TRIGGERS_ triggerForId:new_trigger_id];
    Media *media = [_MODEL_MEDIA_ mediaForId:trigger.icon_media_id];
    
    //short names to cope with obj-c verbosity
    NSString *g = [NSString stringWithFormat:@"%ld/AR",_MODEL_GAME_.game_id]; //game_id as string
    NSString *f = [[[[media.remoteURL absoluteString] componentsSeparatedByString:@"/"] lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //filename

    NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
    filename = [NSString stringWithFormat:@"%@/%@_%d.png",newFolder,f,frame];
    
    [augmentationTexture loadAbsoImageNoResize:filename];
  }

  cur_trigger_id = new_trigger_id;

  glUseProgram(shaderProgramID);
  
  glVertexAttribPointer(vertexHandle,       3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)meshPositions); // square
  glVertexAttribPointer(normalHandle,       3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)meshNormals);
  glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)meshTexCoords);
  
  glEnableVertexAttribArray(vertexHandle);
  glEnableVertexAttribArray(normalHandle);
  glEnableVertexAttribArray(textureCoordHandle);

  glBindTexture(GL_TEXTURE_2D, augmentationTexture.textureID);
  glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, augmentationTexture.width, augmentationTexture.height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)augmentationTexture.pngData);
  glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
  glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
  
  glDrawElements(GL_TRIANGLES, NUM_MESH_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)meshIndices);
  
  glDisableVertexAttribArray(vertexHandle);
  glDisableVertexAttribArray(normalHandle);
  glDisableVertexAttribArray(textureCoordHandle);
  
  SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");

  
  
  
  glDisable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  
  [self presentFramebuffer];
}

- (void)configureVideoBackgroundWithViewWidth:(float)viewWidth andHeight:(float)viewHeight
{
  [sampleAppRenderer configureVideoBackgroundWithViewWidth:viewWidth andHeight:viewHeight];
}

//------------------------------------------------------------------------------
#pragma mark - OpenGL ES management

- (void)initShaders
{
  shaderProgramID = [SampleApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh"
                                                                 fragmentShaderFileName:@"Simple.fragsh"];
  
  if(0 < shaderProgramID)
  {
    vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
    normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
    textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
    mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
    texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
  }
  else
  {
    NSLog(@"Could not initialise augmentation shader");
  }
}

- (void) createFramebuffer
{
  if(context)
  {
    // Create default framebuffer object
    glGenFramebuffers(1, &defaultFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    
    // Create colour renderbuffer and allocate backing store
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    // Allocate the renderbuffer's storage (shared with the drawable object)
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    GLint framebufferWidth;
    GLint framebufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
    
    // Create the depth render buffer and allocate storage
    glGenRenderbuffers(1, &depthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
    
    // Attach colour and depth render buffers to the frame buffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    // Leave the colour render buffer bound so future rendering operations will act on it
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
  }
}

- (void) deleteFramebuffer
{
  if(context)
  {
    [EAGLContext setCurrentContext:context];
    
    if(defaultFramebuffer)
    {
      glDeleteFramebuffers(1, &defaultFramebuffer);
      defaultFramebuffer = 0;
    }
    
    if(colorRenderbuffer)
    {
      glDeleteRenderbuffers(1, &colorRenderbuffer);
      colorRenderbuffer = 0;
    }
    
    if(depthRenderbuffer)
    {
      glDeleteRenderbuffers(1, &depthRenderbuffer);
      depthRenderbuffer = 0;
    }
  }
}

- (void)setFramebuffer
{
  // The EAGLContext must be set for each thread that wishes to use it.  Set
  // it the first time this method is called (on the render thread)
  if(context != [EAGLContext currentContext])
  {
    [EAGLContext setCurrentContext:context];
  }
  
  if(!defaultFramebuffer)
  {
    // Perform on the main thread to ensure safe memory allocation for the
    // shared buffer.  Block until the operation is complete to prevent
    // simultaneous access to the OpenGL context
    [self performSelectorOnMainThread:@selector(createFramebuffer) withObject:self waitUntilDone:YES];
  }
  
  glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
}

- (BOOL)presentFramebuffer
{
  // setFramebuffer must have been called before presentFramebuffer, therefore
  // we know the context is valid and has been set for this (render) thread
  
  // Bind the colour render buffer and present it
  glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
  
  return [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (long) cur_trigger_id
{
    return cur_trigger_id;
}

@end

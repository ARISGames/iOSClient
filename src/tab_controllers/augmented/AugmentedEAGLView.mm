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
#import "Teapot.h"

#import <AVFoundation/AVFoundation.h>

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


namespace {
    // --- Data private to this unit ---
    
    int father_frame_number = 0;
    int nurse_frame_number = 0;
    
    // Model scale factor
    const float kObjectScaleNormal = 3.0f;

    GLuint textureID;
    
    AVAudioPlayer *audioBrother;
    AVAudioPlayer *audioTheater;
    
    NSString *arQRcode;
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

- (id)initWithFrame:(CGRect)frame appSession:(SampleApplicationSession *) app
{
    self = [super initWithFrame:frame];
    
    if (self) {
        vapp = app;
        // Enable retina mode if available on this device
        if (YES == [vapp isRetinaDisplay]) {
            [self setContentScaleFactor:[UIScreen mainScreen].nativeScale];
        }
        
        // Load the initial augmentation texture
        augmentationTexture = [[Texture alloc] initWithImageFile:[NSString stringWithCString:"brother_001.png.jpg" encoding:NSASCIIStringEncoding]];
        
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
        
        NSString *audioPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"brother.mp3"];
        audioBrother = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        [audioBrother setNumberOfLoops:-1];
        
        NSString *audioPath2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"theater.mp3"];
        audioTheater = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath2] error:nil];
        [audioTheater setNumberOfLoops:-1];
        
        arQRcode = nil;
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
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    augmentationTexture = nil;
    
    [audioBrother stop];
    [audioTheater stop];
}


- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  The render loop has
    // been stopped, so we now make sure all OpenGL ES commands complete before
    // we (potentially) go into the background
    if (context) {
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
    if (! vapp.cameraIsStarted) {
        return;
    }
    
    [sampleAppRenderer renderFrameVuforia];
}

- (void) renderFrameWithState:(const Vuforia::State&) state projectMatrix:(Vuforia::Matrix44F&) projectionMatrix {
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
    
    bool play_brother_audio = false;
    bool play_theater_audio = false;
    for (int i = 0; i < state.getNumTrackableResults(); ++i) {
        // Get the trackable
        const Vuforia::TrackableResult* result = state.getTrackableResult(i);
        const Vuforia::Trackable& trackable = result->getTrackable();
        
        //const Vuforia::Trackable& trackable = result->getTrackable();
        Vuforia::Matrix44F modelViewMatrix = Vuforia::Tool::convertPose2GLMatrix(result->getPose());
        
        // OpenGL 2
        Vuforia::Matrix44F modelViewProjection;
        
        SampleApplicationUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScaleNormal, &modelViewMatrix.data[0]);
        SampleApplicationUtils::scalePoseMatrix(kObjectScaleNormal, kObjectScaleNormal, kObjectScaleNormal, &modelViewMatrix.data[0]);
        
        SampleApplicationUtils::multiplyMatrix(&projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
        
        glUseProgram(shaderProgramID);
        
      //if (!strcmp(trackable.getName(), "PTP_MGG_TheaterKid_Trigger_01")) {
            //glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotVertices_Theater);
        //} else if (!strcmp(trackable.getName(), "PTP_MGG_Nurse")) {
            //glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotVertices_Nurse);
        //} else {
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotVertices); // square
        //}
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotNormals);
        glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)teapotTexCoords);
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        glActiveTexture(GL_TEXTURE0);
        
        // Load the frame into the texture
        char textureFilename[50];
      if (1){//!strcmp(trackable.getName(), "PTP_MGG_OlderBrother")) {
            play_brother_audio = true;
            int frame_number = floor([audioBrother currentTime] * 29.97);
            if (frame_number < 0) frame_number = 0;
            if (frame_number > 748) frame_number = 748;
            sprintf(textureFilename, "brother_%03d.png.jpg", frame_number + 1);
            arQRcode = @"AR_brother";
        }// else if (!strcmp(trackable.getName(), "PTP_MGG_TheaterKid_Trigger_01")) {
            //play_theater_audio = true;
            //int frame_number = floor(fmod([audioTheater currentTime], 16.32) * 29.97);
            //if (frame_number < 0) frame_number = 0;
            //if (frame_number > 487) frame_number = 487;
            //sprintf(textureFilename, "theater-%03d.png", frame_number + 1);
            //arQRcode = @"AR_theater";
        //} else if (!strcmp(trackable.getName(), "PTP_MGG_Father")) {
            //sprintf(textureFilename, "father_%03d.png.jpg", father_frame_number + 1);
            //father_frame_number++;
            //if (father_frame_number == 339) father_frame_number = 0;
            //arQRcode = @"AR_father";
        //} else if (!strcmp(trackable.getName(), "PTP_MGG_Nurse")) {
            //sprintf(textureFilename, "nurse-%03d.jpg", nurse_frame_number + 1);
            //nurse_frame_number++;
            //if (nurse_frame_number == 611) nurse_frame_number = 0;
            //arQRcode = @"AR_nurse";
        //}
        [augmentationTexture loadImage:[NSString stringWithCString:textureFilename encoding:NSASCIIStringEncoding]];

        glBindTexture(GL_TEXTURE_2D, augmentationTexture.textureID);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, [augmentationTexture width], [augmentationTexture height], GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[augmentationTexture pngData]);
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
        glUniform1i(texSampler2DHandle, 0 /*GL_TEXTURE0*/);
        
        glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)teapotIndices);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        SampleApplicationUtils::checkGlError("EAGLView renderFrameVuforia");
    }
    
    if (play_brother_audio) {
        if (![audioBrother isPlaying]) [audioBrother play];
    } else {
        [audioBrother pause];
    }
    
    if (play_theater_audio) {
        if (![audioTheater isPlaying]) [audioTheater play];
    } else {
        [audioTheater pause];
    }
    
    if (state.getNumTrackableResults() == 0) {
        arQRcode = nil;
    }
    
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    [self presentFramebuffer];
}

- (NSString *)arQRcode
{
    return arQRcode;
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
    
    if (0 < shaderProgramID) {
        vertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        normalHandle = glGetAttribLocation(shaderProgramID, "vertexNormal");
        textureCoordHandle = glGetAttribLocation(shaderProgramID, "vertexTexCoord");
        mvpMatrixHandle = glGetUniformLocation(shaderProgramID, "modelViewProjectionMatrix");
        texSampler2DHandle  = glGetUniformLocation(shaderProgramID,"texSampler2D");
    }
    else {
        NSLog(@"Could not initialise augmentation shader");
    }
}


- (void)createFramebuffer
{
    if (context) {
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


- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}


- (void)setFramebuffer
{
    // The EAGLContext must be set for each thread that wishes to use it.  Set
    // it the first time this method is called (on the render thread)
    if (context != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:context];
    }
    
    if (!defaultFramebuffer) {
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

- (void) stopAudio {
    [audioBrother stop];
    [audioTheater stop];
}

@end

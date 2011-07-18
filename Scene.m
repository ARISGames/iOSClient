//
//  Scene.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/18.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "Scene.h"


@implementation Scene

@synthesize text;
@synthesize isPc;
@synthesize imageMediaId;
@synthesize imageRect;
@synthesize zoomTime;
@synthesize foreSoundMediaId;	
@synthesize backSoundMediaId;
@synthesize exitToTabWithTitle,videoId,panoId;

- (id) initWithText:(NSString *)theText 
               isPc:(Boolean)isPcYorN 
       imageMediaId:(int)iMediaId 
          imageRect:(CGRect)rect 
           zoomTime:(float)seconds
          foreSoundMediaId:(int)fgMediaId 
       backSoundMediaId:(int)bgMediaId
   exitToTabWithTitle:(NSString*)tabTitle 
videoId:(int)vidId
panoramicId:(int)pId{
	
	if ((self = [super init])) {
        self.text = [[theText copy] retain];
        self.isPc = isPcYorN;
        self.imageMediaId = iMediaId;
        self.imageRect = rect;
        self.zoomTime = seconds;
        self.foreSoundMediaId = fgMediaId;	
        self.backSoundMediaId = bgMediaId;
        self.exitToTabWithTitle = tabTitle;
        self.videoId = vidId;
        self.panoId = pId;
	}
	return self;
}

- (void) dealloc {
	[text release];
	[super dealloc];
}
@end

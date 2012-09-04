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
@synthesize exitToTabWithTitle,videoId,panoId,webId,plaqueId,itemId,exitToType, mediaId;
@synthesize title, vibrate;

- (id) initWithText:(NSString *)theText 
               isPc:(Boolean)isPcYorN 
      shouldVibrate:(Boolean)shouldVibrate
          imageRect:(CGRect)rect 
           zoomTime:(float)seconds
   exitToTabWithTitle:(NSString*)tabTitle 
         exitToType:(NSString *)type videoId:(int)vidId panoramicId:(int)pId webpageId:(int)wId plaqueId:(int)nodeId itemId:(int)iId mediaId:(int)mId title: (NSString *)inputTitle{
	
	if ((self = [super init])) {
        self.text = [theText copy];
        self.isPc = isPcYorN;
        self.vibrate = shouldVibrate;
        self.imageMediaId = 0;
        self.imageRect = rect;
        self.zoomTime = seconds;
        self.exitToTabWithTitle = tabTitle;
        self.videoId = vidId;
        self.panoId = pId;
        self.webId = wId;
        self.plaqueId = nodeId;
        self.itemId = iId;
        self.mediaId = mId;
        self.exitToType = type;
        self.title = inputTitle;
	}
	return self;
}

@end

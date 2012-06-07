//
//  Scene.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/18.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>

enum soundConstants {
	kEmptySound = -1,
	kStopSound = -2
};


@interface Scene : NSObject {
	NSString*   text;
	Boolean		isPc;
	int			imageMediaId;
	CGRect		imageRect;
	float		zoomTime;
    NSString*   exitToTabWithTitle;
    NSString*   exitToType;
    int         videoId;
    int         panoId;
    int         webId;
    int         plaqueId;
    int         itemId;
    int         mediaId;
}

@property(nonatomic) NSString* text;
@property(readwrite) Boolean isPc;
@property(readwrite) int imageMediaId;
@property(readwrite) int panoId;
@property(readwrite) int videoId;
@property(readwrite) int webId;
@property(readwrite) int plaqueId;
@property(readwrite) int itemId;
@property(readwrite) int mediaId;


@property(readwrite) CGRect	imageRect;
@property(readwrite) float zoomTime;
@property(nonatomic) NSString* exitToTabWithTitle;
@property(nonatomic) NSString* exitToType;



- (id) initWithText:(NSString *)text 
               isPc:(Boolean)isPc 
          imageRect:(CGRect)imageRect 
           zoomTime:(float)seconds
   exitToTabWithTitle:(NSString*)tabTitle
         exitToType:(NSString*)type
videoId:(int)vidId
panoramicId:(int)pId
webpageId:(int)wId
plaqueId:(int)nodeId
itemId:(int)iId
mediaId:(int)mId;


@end

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
	Boolean		isPc;
	
	NSString	*text;
	int			characterId;
	CGRect		zoomRect;
	float		zoomTime;
	
	int			bgSound;
	int			fgSound;
}

@property(readonly) Boolean		isPc;
@property(readonly)	NSString	*text;
@property(readonly) int			characterId;
@property(readonly) CGRect		zoomRect;
@property(readonly) float		zoomTime;
@property(readonly) int			bgSound;
@property(readonly) int			fgSound;


- (id) initWithText:(NSString *)aText 
			andIsPc:(Boolean)isPcYorN
	   andCharacter:(int)aCharacterId 
			andZoom:(CGRect)aRect
		andZoomTime:(float)zoomSeconds
	  withForeSound:(int)aFgSound 
	   andBackSound:(int)aBgSound;

@end

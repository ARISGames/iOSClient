//
//  Scene.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/18.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import "Scene.h"


@implementation Scene
@synthesize isPc, text, characterId, zoomRect, fgSound, bgSound;

- (id) initWithText:(NSString *)aText andIsPc:(Boolean)isPcYorN
	   andCharacter:(int)aCharacterId andZoom:(CGRect)aRect 
	  withForeSound:(int)aFgSound andBackSound:(int)aBgSound

{
	if (self = [super init]) {
		isPc = isPcYorN;
		text = [[aText copy] retain];
		characterId = aCharacterId;
		zoomRect = aRect;
		fgSound = aFgSound;
		bgSound = aBgSound;
	}
	return self;
}

- (void) dealloc {
	[text release];
	[super dealloc];
}
@end

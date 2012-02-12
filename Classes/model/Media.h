//
//  Media.h
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kMediaTypeVideo;
extern NSString *const kMediaTypeImage;
extern NSString *const kMediaTypeAudio;

@interface Media : NSObject {
	NSInteger	uid;
	NSURL	*url;
	NSString	*type;
	
	//Image Specific Vars
	UIImage		*image; //cache of the image data	
}

@property(readonly) NSInteger	uid;
@property(readonly)	NSURL	*url;
@property(nonatomic, retain) NSString	*type;
@property(nonatomic, retain) UIImage	*image;


- (id) initWithId:(NSInteger)anId andUrl:(NSURL *)aUrl ofType:(NSString *)aType;

@end

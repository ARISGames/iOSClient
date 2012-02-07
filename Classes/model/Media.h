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
	NSString	*url;
	NSString	*type;
	
	//Image Specific Vars
	UIImage		*image; //cache of the image data	
}

@property(readonly) NSInteger	uid;
@property(readonly)	NSString	*url;
@property(readonly) NSString	*type;
@property(nonatomic, retain) UIImage	*image;


- (id) initWithId:(NSInteger)anId andUrlString:(NSString *)aUrl ofType:(NSString *)aType;

@end

//
//  Media.m
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Media.h"

NSString *const kMediaTypeVideo = @"Video";
NSString *const kMediaTypeImage = @"Image";
NSString *const kMediaTypeAudio = @"Audio";

@implementation Media
@synthesize uid, url, type, image;

- (id) initWithId:(NSInteger)anId andUrl:(NSURL *)aUrl ofType:(NSString *)aType {
	//assert(anId > 0 && @"Non-natural ID.");
	//assert(aUrl && [aUrl length] > 0 && @"Empty url string.");
	//assert(aType && [aType length] > 0 && "@Empty type.");
	
	if (self = [super init]) {
		uid = anId;
		url = [aUrl retain];
		type = [aType retain];
	}
	
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(didReceiveMemoryWarning) name:@"LowMemoryWarning" object:nil];

    
	return self;
}


- (void)didReceiveMemoryWarning {
    if (image) {
        NSLog(@"Media: Low Memory Warning - Throwing out Cached Media");
        [image release];
        image = nil;
    }
}


- (void)dealloc {
	[url release];
	[type release];
	[image release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

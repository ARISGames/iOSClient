//
//  NoteMedia.h
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NoteMedia : NSObject {
    NSString *text;
    int mediaId;
}

@property(nonatomic, retain) NSString *text;
@property(readwrite, assign) int mediaId;

@end

//
//  Quest.h
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Quest : NSObject {
	int questId;
	NSString *name;
	NSString *description;
    NSString *exitToTabName;
    int mediaId;
	int iconMediaId;
    int sortNum;
    BOOL isNullQuest;
}

@property(readwrite, assign) int questId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *description;
@property(copy, readwrite) NSString *exitToTabName;
@property(readwrite, assign) int mediaId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int sortNum;
@property(readwrite, assign) BOOL isNullQuest;

@end

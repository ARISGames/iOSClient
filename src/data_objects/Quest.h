//
//  Quest.h
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Quest : NSObject 
{
	int questId;
	NSString *name;
    
	NSString *desc;
    NSString *goFunction;
    int media_id;
	int icon_media_id;
    
    int sortNum;
    BOOL fullScreenNotification;
    BOOL isNullQuest; 
}

@property(readwrite, assign) int questId;
@property(copy, readwrite) NSString *name;

@property(copy, readwrite) NSString *desc;
@property(copy, readwrite) NSString *goFunction;
@property(readwrite, assign) int media_id;
@property(readwrite, assign) int icon_media_id;

@property(readwrite, assign) int sortNum;
@property(readwrite, assign) BOOL fullScreenNotification;
@property(readwrite, assign) BOOL isNullQuest;

@end

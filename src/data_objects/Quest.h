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
	NSString *qdescription;
    NSString *qdescriptionNotification; 
    NSString *goFunction;
    NSString *notifGoFunction; 
    int mediaId;
	int iconMediaId;
    int notificationMediaId;
    int sortNum;
    BOOL fullScreenNotification;
    BOOL showDismiss;
    BOOL isNullQuest; 
}

@property(readwrite, assign) int questId;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSString *qdescription;
@property(copy, readwrite) NSString *qdescriptionNotification;
@property(copy, readwrite) NSString *goFunction;
@property(copy, readwrite) NSString *notifGoFunction;
@property(readwrite, assign) int mediaId;
@property(readwrite, assign) int iconMediaId;
@property(readwrite, assign) int notificationMediaId;
@property(readwrite, assign) int sortNum;
@property(readwrite, assign) BOOL fullScreenNotification;
@property(readwrite, assign) BOOL showDismiss;
@property(readwrite, assign) BOOL isNullQuest;

@end

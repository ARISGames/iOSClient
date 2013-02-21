//
//  Quest.m
//  ARIS
//
//  Created by David J Gagnon on 9/3/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "Quest.h"


@implementation Quest

@synthesize questId;
@synthesize name, sortNum;
@synthesize qdescription;
@synthesize exitToTabName;
@synthesize mediaId;
@synthesize iconMediaId;
@synthesize fullScreenNotification;
@synthesize isNullQuest;

- (Quest *) init {
    if (self = [super init]) {
		sortNum = 0;
    }
    return self;	
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Quest- Id:%d\tName:%@",self.questId,self.name];
}

@end

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
@synthesize name;
@synthesize sortNum;
@synthesize desc;
@synthesize goFunction;
@synthesize media_id;
@synthesize icon_media_id;
@synthesize fullScreenNotification;
@synthesize isNullQuest;

- (Quest *) init
{
    if(self = [super init])
    {
		sortNum = 0;
    }
    return self;	
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Quest- Id:%d\tName:%@",self.questId,self.name];
}

@end

//
//  MNode.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/19/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame, MMedia, MNode, MNpc;

@interface MNode : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * opt2Text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSString * opt3Text;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * opt1Text;
@property (nonatomic, retain) NSString * requireAnswerString;
@property (nonatomic, retain) MNpc *npc;
@property (nonatomic, retain) MNode *opt3Node;
@property (nonatomic, retain) MNode *opt1Node;
@property (nonatomic, retain) MMedia *icon;
@property (nonatomic, retain) MNode *opt2Node;
@property (nonatomic, retain) MGame *game;
@property (nonatomic, retain) MMedia *media;
@property (nonatomic, retain) MNode *requireAnswerCorrectNode;
@property (nonatomic, retain) MNode *requireAnswerIncorrectNode;

@end

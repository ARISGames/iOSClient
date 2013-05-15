//
//  Node.h
//  ARIS
//
//  Created by David J Gagnon on 8/31/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface Node : NSObject <GameObjectProtocol>
{
	int      nodeId;
	NSString *name;
	NSString *text;
	int	     mediaId;
	int      iconMediaId;
}

@property(nonatomic, assign) int nodeId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, assign) int mediaId;
@property(nonatomic, assign) int iconMediaId;

@end

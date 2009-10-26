//
//  GameListParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameListParserDelegate : NSObject {
	NSMutableArray *gameList;
}

- (GameListParserDelegate*)initWithGameList:(NSMutableArray *)modelGameList;

@end

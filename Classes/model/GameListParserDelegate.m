//
//  GameListParserDelegate.m
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameListParserDelegate.h"
#import "Game.h";

@implementation GameListParserDelegate

- (GameListParserDelegate*)initWithGameList:(NSMutableArray *)modelGameList {
	self = [super init];
    if ( self ) {
       gameList = modelGameList;
		[gameList retain];
    }
	
    return self;
	
	
}


#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	if(qName) {
		elementName = qName;
	}
	
	if ([elementName isEqualToString:@"game"]) {
		//ok, new game
		Game *game = [[Game alloc] init];
		game.gameId = [[attributeDict objectForKey:@"id"] intValue];
		game.site = [attributeDict objectForKey:@"site"];
		game.name = [attributeDict objectForKey:@"name"];
		[gameList addObject:game];
		NSLog(@"GameListParser: Added Game '%@' with a site name of '%@'",game.name ,game.site );
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	//nada
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:gameList forKey:@"gameList"];
	NSLog(@"GameListParser: Finished Building the Game List");
	NSNotification *gameListNotification = [NSNotification notificationWithName:@"ReceivedGameList" object:self userInfo:dictionary];
	[[NSNotificationCenter defaultCenter] postNotification:gameListNotification];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	//nada
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	//nada
}

- (void)dealloc {
	[gameList release];
    [super dealloc];
}

@end

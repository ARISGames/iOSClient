//
//  LocationListParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 2/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModel.h"

@interface LocationListParserDelegate : NSObject {
	NSMutableArray *locationList;
	NSMutableArray *playerList;


}

- (LocationListParserDelegate*)initWithModel:(AppModel *)model;
@end

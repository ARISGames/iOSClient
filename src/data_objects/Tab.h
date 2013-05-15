//
//  Tab.h
//  ARIS
//
//  Created by Brian Thiel on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tab : NSObject {
    NSString *tabName;
    int tabIndex;
    int tabDetail1;
}

@property(nonatomic)NSString *tabName;
@property(readwrite,assign)int tabIndex;
@property(readwrite,assign)int tabDetail1;

@end

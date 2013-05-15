//
//  Logger.h
//  ARIS
//
//  Created by Jacob Hanshaw on 3/15/13.
//
//

#import <Foundation/Foundation.h>

#define DEBUGMODE 1

@interface Logger : NSObject {
    
}

+ (Logger *)sharedLogger;
- (void)logDebug:(NSString *) string;

@end

//
//  Logger.h
//  ARIS
//
//  Created by Jacob Hanshaw on 3/15/13.
//
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject {
    
}

+ (Logger *)sharedLogger;
- (void)logDebug:(NSString *) string;

@end

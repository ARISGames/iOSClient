//
//  Logger.m
//  ARIS
//
//  Created by Jacob Hanshaw on 3/15/13.
//
//

#import "Logger.h"

@implementation Logger

+ (id)sharedLogger
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)logDebug:(NSString *) string {
#if DEBUGMODE > 0
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    //Example indexes into array:
    //NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    
    NSLog(@"%@: %@ Debug: %@", [array objectAtIndex:3], [array objectAtIndex:4], string);
#endif
}


@end

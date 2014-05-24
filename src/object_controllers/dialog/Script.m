//
//  Script.m
//  ARIS
//
//  Created by Phil Dougherty on 3/28/13.
//
//

#import "Script.h"

@implementation Script

@synthesize exitToType;
@synthesize exitToTypeId;
@synthesize exitToTabTitle;
@synthesize hideLeaveConversationButton;
@synthesize hideLeaveConversationButtonSpecified;
@synthesize leaveConversationButtonTitle;
@synthesize defaultPcTitle;
@synthesize defaultPcMediaId;
@synthesize scriptElementArray;

-(id) init
{
    if(self = [super init])
    {
        exitToType     = nil;
        exitToTypeId   = 0;
        exitToTabTitle = nil;
        hideLeaveConversationButton          = NO;
        hideLeaveConversationButtonSpecified = NO;
        leaveConversationButtonTitle         = nil;
        defaultPcTitle                       = nil;
        defaultPcMediaId                     = 0; 
        scriptElementArray = [[NSMutableArray alloc] init];
        scriptElementIndex = -1;
    }
    return self;
}

- (ScriptElement *) nextScriptElement
{
    scriptElementIndex++;
    if(scriptElementArray.count > scriptElementIndex)
        return [scriptElementArray objectAtIndex:scriptElementIndex];
    else
        return nil;
}

@end

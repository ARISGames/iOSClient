//
//  DialogScript.m
//  ARIS
//
//  Created by Phil Dougherty on 3/28/13.
//
//

#import "DialogScript.h"

@implementation DialogScript

@synthesize exitToType;
@synthesize exitToTypeId;
@synthesize exitToTabTitle;
@synthesize hideLeaveConversationButton;
@synthesize hideLeaveConversationButtonSpecified;
@synthesize leaveConversationButtonTitle;
@synthesize hideAdjustTextAreaButton;
@synthesize adjustTextArea;
@synthesize sceneArray;

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
        hideAdjustTextAreaButton             = NO;
        adjustTextArea = nil;
        sceneArray = [[NSMutableArray alloc] init];
        sceneIndex = -1;
    }
    return self;
}

- (Scene *) nextScene
{
    sceneIndex++;
    if([sceneArray count] > sceneIndex)
        return [sceneArray objectAtIndex:sceneIndex];
    else
        return nil;
}

@end

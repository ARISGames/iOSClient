//
//  Script.h
//  ARIS
//
//  Created by Phil Dougherty on 3/28/13.
//
//

#import <Foundation/Foundation.h>
#import "ScriptElement.h"

@interface Script : NSObject
{
    NSString *exitToType;
    int       exitToTypeId;
    NSString *exitToTabTitle;
    
    BOOL hideLeaveConversationButton;
    BOOL hideLeaveConversationButtonSpecified;
    NSString *leaveConversationButtonTitle;
    NSString *defaultPcTitle;
    BOOL hideAdjustTextAreaButton;
    NSString *adjustTextArea; //Note- possible both in script AND scriptElement
    
    NSMutableArray *scriptElementArray;
    int scriptElementIndex;
}

@property (nonatomic, strong) NSString *exitToType;
@property (nonatomic, assign) int       exitToTypeId;
@property (nonatomic, strong) NSString *exitToTabTitle;

@property (nonatomic, assign) BOOL hideLeaveConversationButton;
@property (nonatomic, assign) BOOL hideLeaveConversationButtonSpecified;
@property (nonatomic, strong) NSString *leaveConversationButtonTitle;
@property (nonatomic, strong) NSString *defaultPcTitle;
@property (nonatomic, assign) BOOL hideAdjustTextAreaButton;
@property (nonatomic, strong) NSString *adjustTextArea;

@property (nonatomic, strong) NSMutableArray *scriptElementArray;

- (ScriptElement *) nextScriptElement;

@end

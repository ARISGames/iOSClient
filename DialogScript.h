//
//  DialogScript.h
//  ARIS
//
//  Created by Phil Dougherty on 3/28/13.
//
//

#import <Foundation/Foundation.h>
#import "Scene.h"

@interface DialogScript : NSObject
{
    NSString *exitToType;
    int       exitToTypeId;
    NSString *exitToTabTitle;
    
    BOOL hideLeaveConversationButton;
    BOOL hideLeaveConversationButtonSpecified;
    NSString *leaveConversationButtonTitle;
    BOOL hideAdjustTextAreaButton;
    NSString *adjustTextArea; //Note- possible both in script AND scene
    
    NSMutableArray *sceneArray;
    int sceneIndex;
}

@property (nonatomic,strong) NSString *exitToType;
@property (nonatomic,assign) int       exitToTypeId;
@property (nonatomic,strong) NSString *exitToTabTitle;

@property (nonatomic,assign) BOOL hideLeaveConversationButton;
@property (nonatomic,assign) BOOL hideLeaveConversationButtonSpecified;
@property (nonatomic,strong) NSString *leaveConversationButtonTitle;
@property (nonatomic,assign) BOOL hideAdjustTextAreaButton;
@property (nonatomic,strong) NSString *adjustTextArea;

@property (nonatomic,strong) NSMutableArray *sceneArray;

- (Scene *) nextScene;

@end

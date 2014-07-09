//
//  DialogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Dialog.h"
#import "DialogCharacter.h"
#import "DialogScript.h"

@interface DialogsModel : NSObject

- (Dialog *) dialogForId:(int)dialog_id;
- (DialogCharacter *) characterForId:(int)dialog_character_id;
- (DialogScript *) scriptForId:(int)dialog_script_id;
- (void) requestDialogs;
- (void) clearGameData;
- (void) requestPlayerOptionsForDialogId:(int)dialog_id scriptId:(int)dialog_script_id;

@end

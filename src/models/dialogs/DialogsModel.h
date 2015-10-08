//
//  DialogsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Dialog.h"
#import "DialogCharacter.h"
#import "DialogScript.h"
#import "DialogOption.h"

@interface DialogsModel : ARISModel

- (Dialog *) dialogForId:(long)dialog_id;
- (DialogCharacter *) characterForId:(long)dialog_character_id;
- (DialogScript *) scriptForId:(long)dialog_script_id;
- (DialogOption *) optionForId:(long)dialog_option_id;
- (void) requestDialogs;
- (void) requestPlayerOptionsForDialogId:(long)dialog_id scriptId:(long)dialog_script_id;

@end


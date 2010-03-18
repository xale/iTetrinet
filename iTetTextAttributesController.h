//
//  iTetTextAttributesController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetTextAttributesController : NSObject <NSUserInterfaceValidations>
{
	IBOutlet NSTextField* partylineMessageField;
}

- (IBAction)changeTextColor:(id)sender;

@end

//
//  iTetTextAttributesController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import <Cocoa/Cocoa.h>

@class iTetAppController;

@interface iTetTextAttributesController : NSObject <NSUserInterfaceValidations>
{
	IBOutlet NSTextField* partylineMessageField;
	IBOutlet NSTextView* partylineChatView;
}

- (IBAction)changeTextColor:(id)sender;

- (NSAttributedString*)formattedMessageFromData:(NSData*)messageData;
- (NSData*)dataFromFormattedMessage:(NSAttributedString*)message
				withAttributedRange:(NSRange)rangeWithAttributes;

@end

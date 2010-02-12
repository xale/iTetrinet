//
//  iTetTextAttributesController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import <Cocoa/Cocoa.h>

@class iTetAppController;

typedef enum
{
	noColor =			0,
	blackTextColor =		4,
	whiteTextColor =		24,
	grayTextColor =		6,
	silverTextColor =		15,
	redTextColor =		20,
	yellowTextColor =		25,
	limeTextColor =		14,
	greenTextColor =		12,
	oliveTextColor =		18,
	tealTextColor =		23,
	cyanTextColor =		3,
	blueTextColor =		5,
	darkBlueTextColor =	17,
	purpleTextColor =		19,
	maroonTextColor =		16,
	magentaTextColor =	8
} iTetTextColorCode;

NSColor* iTetTextColorForCode(iTetTextColorCode code);
iTetTextColorCode iTetCodeForTextColor(NSColor* color);

typedef enum
{
	italicText =	22,
	underlineText =	31,
	boldText =		2,
	boldItalicText =	30 // Not part of the spec, just for our use; never sent over the line
} iTetTextAttributeCode;

#define ITET_HIGHEST_ATTR_CODE	31

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

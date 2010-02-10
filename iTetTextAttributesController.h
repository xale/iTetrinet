//
//  iTetTextAttributesController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import <Cocoa/Cocoa.h>

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
	italicText =	11,
	underlineText =	21,
	boldText =		31
} iTetTextAttributeCode;

@interface iTetTextAttributesController : NSObject <NSUserInterfaceValidations>
{
	IBOutlet NSTextField* partylineMessageField;
}

- (IBAction)changeTextColor:(id)sender;

@end

//
//  iTetKeyNamePair.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetEscapeKeyPlaceholderString;
extern NSString* const iTetSpacebarPlaceholderString;
extern NSString* const iTetTabKeyPlaceholderString;
extern NSString* const iTetReturnKeyPlaceholderString;
extern NSString* const iTetEnterKeyPlaceholderString;
extern NSString* const iTetDeleteKeyPlaceholderString;

#define iTetLeftArrowKeyPlaceholderString		[NSString stringWithFormat:@"%C", 0x2190]
#define iTetRightArrowKeyPlaceholderString	[NSString stringWithFormat:@"%C", 0x2192]
#define iTetUpArrowKeyPlaceholderString		[NSString stringWithFormat:@"%C", 0x2191]
#define iTetDownArrowKeyPlaceholderString		[NSString stringWithFormat:@"%C", 0x2193]

extern NSString* const iTetUnknownModifierPlaceholderString;
extern NSString* const iTetShiftKeyPlaceholderString;
extern NSString* const iTetControlKeyPlaceholderString;
extern NSString* const iTetAltOptionKeyPlaceholderString;

#define iTetCommandKeyPlaceholderString [NSString stringWithFormat:@" %C  %C ", 0xF8FF, 0x2318]
// The above should render as the unicode Apple logo followed by the unicode cloverleaf

@interface iTetKeyNamePair : NSObject <NSCoding, NSCopying>
{
	int keyCode;
	NSString* keyName;
}

+ (id)keyNamePairFromKeyEvent:(NSEvent*)event;
+ (id)keyNamePairForKeyCode:(int)code
			     name:(NSString*)name;

- (id)initWithKeyEvent:(NSEvent*)event;
- (id)initWithKeyCode:(int)code
		     name:(NSString*)name;

- (NSString*)keyNameForEvent:(NSEvent*)event;
- (NSString*)modifierNameForEvent:(NSEvent*)event;

@property (readonly) int keyCode;
@property (readonly) NSString* keyName;

@end

//
//  iTetTextAttributesController.m
//  iTetrinet
//
//  Created by Alex Heinz on 2/7/10.
//

#import "iTetTextAttributesController.h"
#import "NSMutableData+SingleByte.h"
#import "iTetAttributeRangePair.h"
#import "NSColor+Comparisons.h"

#define iTetSilverTextColor	[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]
#define iTetGreenTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0]
#define iTetOliveTextColor	[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.0 alpha:1.0]
#define iTetTealTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0]
#define iTetDarkBlueTextColor	[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0]
#define iTetMaroonTextColor	[NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]

NSColor* iTetTextColorForCode(iTetTextColorCode code)
{
	switch (code)
	{
		case blackTextColor:
			return [NSColor blackColor];
			
		case whiteTextColor:
			return [NSColor whiteColor];
			
		case grayTextColor:
			return [NSColor grayColor];
			
		case silverTextColor:
			return iTetSilverTextColor;
			
		case redTextColor:
			return [NSColor redColor];
			
		case yellowTextColor:
			return [NSColor yellowColor];
			
		case limeTextColor:
			return [NSColor greenColor];
			
		case greenTextColor:
			return iTetGreenTextColor;
			
		case oliveTextColor:
			return iTetOliveTextColor;
			
		case tealTextColor:
			return iTetTealTextColor;
			
		case cyanTextColor:
			return [NSColor cyanColor];
			
		case blueTextColor:
			return [NSColor blueColor];
			
		case darkBlueTextColor:
			return iTetDarkBlueTextColor;
			
		case purpleTextColor:
			return [NSColor purpleColor];
			
		case maroonTextColor:
			return iTetMaroonTextColor;
			
		case magentaTextColor:
			return [NSColor magentaColor];
			
		default:
			break;
	}
	
	return nil;
}

iTetTextColorCode iTetCodeForTextColor(NSColor* color)
{
	if ([color hasSameRGBValuesAsColor:[NSColor blackColor]])
		return blackTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor whiteColor]])
		return whiteTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor grayColor]])
		return grayTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetSilverTextColor])
		return silverTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor redColor]])
		return redTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor yellowColor]])
		return yellowTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor greenColor]])
		return limeTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetGreenTextColor])
		return greenTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetOliveTextColor])
		return oliveTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetTealTextColor])
		return tealTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor cyanColor]])
		return cyanTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor blueColor]])
		return blueTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetDarkBlueTextColor])
		return darkBlueTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor purpleColor]])
		return purpleTextColor;
	
	if ([color hasSameRGBValuesAsColor:iTetMaroonTextColor])
		return maroonTextColor;
	
	if ([color hasSameRGBValuesAsColor:[NSColor magentaColor]])
		return magentaTextColor;
	
	return noColor;
}

@implementation iTetTextAttributesController

#pragma mark -
#pragma mark Interface Actions

- (IBAction)changeTextColor:(id)sender
{
	NSTextView* editor = (NSTextView*)[partylineMessageField currentEditor];
	
	// Determine the text color to use
	NSColor* textColor = iTetTextColorForCode([sender tag]);
	
	// Determine if there is text selected
	NSRange selection = [editor selectedRange];
	if (selection.length > 0)
	{
		// Change the text color of the selection
		[editor setTextColor:textColor
				   range:selection];
	}
	else
	{
		// Set the color of the text being typed
		// Get the current typing attributes
		NSMutableDictionary* attrDict = [[editor typingAttributes] mutableCopy];
		
		// Change the text color
		[attrDict setObject:textColor
				 forKey:NSForegroundColorAttributeName];
		[editor setTypingAttributes:attrDict];
		
		[attrDict release];
	}
}

#pragma mark -
#pragma mark Interface Validations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
	// Color change actions are available if the message field has keyboard focus
	if ([item action] == @selector(changeTextColor:))
		return ([partylineMessageField currentEditor] != nil);
	
	return YES;
}

#pragma mark -
#pragma mark Message Formatting

- (NSAttributedString*)formattedMessageFromData:(NSData*)messageData
{
	// Create a mutable attributed string to apply attributes to
	NSString* baseString = [NSString stringWithCString:[messageData bytes]
								encoding:NSASCIIStringEncoding];
	NSMutableAttributedString* formattedString = [[[NSMutableAttributedString alloc] initWithString:baseString] autorelease];
	
	// Create bold and italic versions of the default chat view font
	NSFont* boldFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
										toHaveTrait:NSBoldFontMask];
	NSFont* italicFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
										  toHaveTrait:NSItalicFontMask];
	// FIXME: not implemented; needs a special case
	NSFont* boldItalicFont = [[NSFontManager sharedFontManager] convertFont:[partylineChatView font]
											toHaveTrait:(NSBoldFontMask | NSItalicFontMask)];
	
	// Scan the message for formatting information
	const uint8_t* rawData = (uint8_t*)[messageData bytes];
	NSMutableArray* openAttributes = [NSMutableArray array];
	for (NSUInteger index = 0; index < [messageData length]; index++)
	{
		// Check if this byte is a non-printing character
		uint8_t byte = rawData[index];
		if (byte > ITET_HIGHEST_ATTR_CODE)
			continue;
		
		// Determine if this character maps to a text attribute
		// FIXME: this should be done _after_ we determine if the tag is already open
		NSDictionary* attribute = nil;
		switch (byte)
		{
			case boldText:
				// Bold
				attribute = [NSDictionary dictionaryWithObject:boldFont
										    forKey:NSFontAttributeName];
				break;
				
			case italicText:
				// Italic
				attribute = [NSDictionary dictionaryWithObject:italicFont
										    forKey:NSFontAttributeName];
				break;
				
			case underlineText:
				// Underline
				attribute = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(NSUnderlineStyleSingle | NSUnderlinePatternSolid)]
										    forKey:NSUnderlineStyleAttributeName];
				break;
				
			default:
			{
				// Colored text
				NSColor* textColor = iTetTextColorForCode((iTetTextColorCode)byte);
				if (textColor != nil)
				{
					attribute = [NSDictionary dictionaryWithObject:textColor
											    forKey:NSForegroundColorAttributeName];
				}
				break;
			}
		}
		
		// If the character does map to an attribute, apply that attribute to a range of the string
		if (attribute != nil)
		{
			// Check whether there is already an "open" attribute of this type (i.e., this is a "closing" tag)
			NSArray* filteredArray = [openAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"attributeType == %d", byte]];
			if ([filteredArray count] > 0)
			{
				// "Close" the range of this attribute at the character before this one
				iTetAttributeRangePair* attributeAndRange = [filteredArray objectAtIndex:0];
				[attributeAndRange setLastIndexInRange:(index - 1)];
				
				// Add this attribute to the string
				[formattedString addAttributes:[attributeAndRange attributeValue]
								 range:[attributeAndRange range]];
				
				// Remove from the list of open attributes
				[openAttributes removeObject:attributeAndRange];
			}
			else
			{
				// Add this attribute to the list of "open" attributes
				[openAttributes addObject:[iTetAttributeRangePair pairWithAttributeType:byte
															value:attribute
												    beginningAtLocation:index]];
			}
		}
	}
	
	return formattedString;
}

- (NSData*)dataFromFormattedMessage:(NSAttributedString*)message
		    withAttributedRange:(NSRange)rangeWithAttributes
{
	// Create the raw ASCII version of the message
	NSMutableData* messageData = [NSMutableData dataWithData:[[message string] dataUsingEncoding:NSASCIIStringEncoding
													allowLossyConversion:YES]];
	NSUInteger bytesAdded = 0;
	
	// Search the messages for attributes
	NSUInteger index = rangeWithAttributes.location;
	NSDictionary* attributes;
	NSRange attrRange;
	NSMutableArray* openTags = [NSMutableArray array];
	iTetTextColorCode color;
	NSFontTraitMask fontTraits;
	while (index < (rangeWithAttributes.location + rangeWithAttributes.length))
	{
		// Find the attributes and their extent at this point in the message
		attributes = [message attributesAtIndex:index
					longestEffectiveRange:&attrRange
							  inRange:rangeWithAttributes];
		
		// Check for specific attributes that interest us
		// Text color
		color = iTetCodeForTextColor([attributes objectForKey:NSForegroundColorAttributeName]);
		if (color != blackTextColor)
		{
			// Add color codes to the outgoing message data
			// Open tag
			[messageData insertByte:(uint8_t)color
					    atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:color]];
		}
		
		// Underline
		if ([[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] != NSUnderlineStyleNone)
		{
			// Add underline code to message
			// Open tag
			[messageData insertByte:(uint8_t)underlineText
					    atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:underlineText]];
		}
		
		fontTraits = [[NSFontManager sharedFontManager] traitsOfFont:[attributes objectForKey:NSFontAttributeName]];
		
		// Bold
		if (fontTraits & NSBoldFontMask)
		{
			// Add bold code to message
			// Open tag
			[messageData insertByte:(uint8_t)boldText
					    atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:boldText]];
		}
		
		// Italics
		if (fontTraits & NSItalicFontMask)
		{
			// Add italics code to message
			// Open tag
			[messageData insertByte:(uint8_t)italicText
					    atIndex:(attrRange.location + bytesAdded)];
			bytesAdded++;
			
			// Add to list of open tags
			[openTags addObject:[NSNumber numberWithInt:italicText]];
		}
		
		// Close all open tags (in reverse order) before moving to next attribute range
		for (NSNumber* tag in [openTags reverseObjectEnumerator])
		{
			// Close the tag
			[messageData insertByte:(uint8_t)[tag intValue]
					    atIndex:(attrRange.location + attrRange.length + bytesAdded)];
			bytesAdded++;
		}
		
		// Clear the list of open tags
		openTags = [NSMutableArray array];
		
		// Advance the index to the end of this attribute range
		index = (attrRange.location + attrRange.length);
	}
	
	// Return the formatted data
	return [NSData dataWithData:messageData];
}

@end

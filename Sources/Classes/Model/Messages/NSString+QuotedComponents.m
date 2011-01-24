//
//  NSString+QuotedComponents.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/30/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "NSString+QuotedComponents.h"

@implementation NSString (QuotedComponents)

- (NSArray*)quotedComponentsSeparatedByString:(NSString*)sep
								  stripQuotes:(BOOL)strip
{
	NSParameterAssert([sep rangeOfString:@"\""].location == NSNotFound);
	
	// Split contents into space-separated components
	NSArray* tokens = [self componentsSeparatedByString:sep];
	
	// Re-join quoted tokens
	NSMutableArray* components = [NSMutableArray array];
	NSUInteger openQuote, closeQuote;
	for (openQuote = 0; openQuote < [tokens count]; openQuote++)
	{
		// Check if this token is the first token in a range comprising a quoted component
		if ([[tokens objectAtIndex:openQuote] rangeOfString:@"\"" options:NSAnchoredSearch].location != NSNotFound)
		{
			// Search for the last token in the range
			for (closeQuote = openQuote; closeQuote < [tokens count]; closeQuote++)
			{
				// Check if this token is the last in the range
				if ([[tokens objectAtIndex:closeQuote] rangeOfString:@"\"" options:(NSBackwardsSearch | NSAnchoredSearch)].location	!= NSNotFound)
				{
					// Join tokens in the range with spaces
					NSRange quotedTokenRange = NSMakeRange(openQuote, ((closeQuote - openQuote) + 1));
					NSString* quotedComponent = [[tokens subarrayWithRange:quotedTokenRange] componentsJoinedByString:sep];
					
					// If requested, strip quotes
					if (strip)
					{
						quotedComponent = [quotedComponent stringByReplacingOccurrencesOfString:@"\""
																					 withString:@""];
					}
					
					// Add to list of components
					[components addObject:quotedComponent];
					
					// Skip over joined tokens
					openQuote = closeQuote;
					break;
				}
			}
			
			// If we have run off the end of the list of tokens, this is a malformed string
			if (closeQuote == [tokens count])
				return nil;
		}
		else
		{
			// This token stands alone as a component
			[components addObject:[tokens objectAtIndex:openQuote]];
		}
	}
	
	return [NSArray arrayWithArray:components];
}

@end

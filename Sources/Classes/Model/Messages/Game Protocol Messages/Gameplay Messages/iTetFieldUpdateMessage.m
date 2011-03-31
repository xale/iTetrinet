//
//  iTetFieldUpdateMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/31/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetFieldUpdateMessage.h"


// Define message tag here
NSString* const iTetFieldUpdateMessageTag =	@"";

@implementation iTetFieldUpdateMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	if (!(self = [super initWithMessageTokens:tokens]))
		return nil;
	
	// Treat the second token as the player number
	playerNumber = [[tokens objectAtIndex:1] integerValue];
	
	// Treat the third token (if any) as the fieldstring
	if ([tokens count] > 2)
		fieldstring = [[tokens objectAtIndex:2] copy];
	
	return self;
}

+ (id)messageWithPlayerNumber:(NSInteger)number
				  fieldstring:(NSString*)string
{
	return [[[self alloc] initWithPlayerNumber:number
								   fieldstring:string] autorelease];
}

- (id)initWithPlayerNumber:(NSInteger)number
			   fieldstring:(NSString*)string
{
	if (!(self = [super init]))
		return nil;
	
	playerNumber = number;
	fieldstring = [string copy];
	
	return self;
}

- (void)dealloc
{
	[fieldstring release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	if ([self fieldstring] != nil)
		return [NSString stringWithFormat:@"%@ %ld %@", iTetFieldUpdateMessageTag, (long)[self playerNumber], [self fieldstring]];
	
	return [NSString stringWithFormat:@"%@ %ld", iTetFieldUpdateMessageTag, (long)[self playerNumber]];
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNumber;
@synthesize fieldstring;

@end

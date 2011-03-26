//
//  iTetClientInfoResponseMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetClientInfoResponseMessage.h"

NSString* const iTetClientInfoResponseMessageTag =	@"clientinfo";

@implementation iTetClientInfoResponseMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Treat the second and third tokens as the client name and version, respectively
	clientName = [[tokens objectAtIndex:1] copy];
	clientVersion = [[tokens objectAtIndex:2] copy];
	
	return self;
}

+ (id)messageWithClientName:(NSString*)name
					version:(NSString*)version
{
	return [[[self alloc] initWithClientName:name
									 version:version] autorelease];
}

- (id)initWithClientName:(NSString*)name
				 version:(NSString*)version
{
	NSParameterAssert([name rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound);
	NSParameterAssert([version rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound);
	
	clientName = [name copy];
	clientVersion = [version copy];
	
	return self;
}

- (void)dealloc
{
	[clientName release];
	[clientVersion release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	return [NSString stringWithFormat:@"%@ %@ %@", iTetClientInfoResponseMessageTag, [self clientName], [self clientVersion]];
}

#pragma mark -
#pragma mark Accessors

@synthesize clientName;
@synthesize clientVersion;

@end

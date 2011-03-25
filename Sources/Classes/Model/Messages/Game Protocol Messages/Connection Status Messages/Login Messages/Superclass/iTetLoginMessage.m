//
//  iTetLoginMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/21/11.
//  Copyright (c) 2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetLoginMessage.h"

#import "NSString+MessageData.h"

@implementation iTetLoginMessage

- (id)initWithMessageTokens:(NSArray*)tokens
{
	// Abstract class; throw an exception on instantiation
	if ([self isMemberOfClass:[iTetLoginMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	playerNickname = [[tokens objectAtIndex:1] copy];
	protocolVersion = [[tokens objectAtIndex:2] copy];
	
	return self;
}

+ (id)messageWithPlayerNickname:(NSString*)nickname
				protocolVersion:(NSString*)version
			  destinationServer:(NSString*)destinationAddress
{
	return [[[self alloc] initWithPlayerNickname:nickname
								 protocolVersion:version
							   destinationServer:destinationAddress] autorelease];
}

- (id)initWithPlayerNickname:(NSString*)nickname
			 protocolVersion:(NSString*)version
		   destinationServer:(NSString*)destinationAddress
{
	// Abstract class; throw an exception on instantiation
	if ([self isMemberOfClass:[iTetLoginMessage class]])
	{
		[self doesNotRecognizeSelector:_cmd];
		[self release];
		return nil;
	}
	
	NSParameterAssert([nickname rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound);
	
	playerNickname = [nickname copy];
	protocolVersion = [version copy];
	serverAddress = [destinationAddress copy];
	
	return self;
}

- (void)dealloc
{
	[playerNickname release];
	[protocolVersion release];
	[serverAddress release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Message Contents

- (NSString*)messageContents
{
	// Create the "standard form" of the message ("<message tag> <nickname> <version>")
	NSString* message = [NSString stringWithFormat:@"%@ %@ %@", [self messageTag], [self playerNickname], [self protocolVersion]];
	
	// Split the server's IP address into integer components
	NSArray* ipComponents = [[self serverAddress] componentsSeparatedByString:@"."];
	NSInteger ip[4];
	for (NSUInteger componentIndex = 0; componentIndex < 4; componentIndex++)
		ip[componentIndex] = [[ipComponents objectAtIndex:componentIndex] integerValue];
	
	// Create the "hash" of the IP address
	NSString* ipHash = [NSString stringWithFormat:@"%d", (54*ip[0]) + (41*ip[1]) + (29*ip[2]) + (17*ip[3])];
	
	// Create an "encoded" version of the message, starting with a random two-digit hexadecimal value in the range [0, 255)
	uint8_t x = random() % 255;
	NSMutableString* encodedMessage = [NSMutableString stringWithFormat:@"%02X", x];
	
	// Create a "hash" of each byte in the original message and append it as a hexadecimal value to the end of the encoded string
	NSData* originalMessageData = [message messageData];
	const uint8_t* rawData = [originalMessageData bytes];
	for (NSUInteger byteIndex = 0; byteIndex < [originalMessageData length]; byteIndex++)
	{
		// Modular-add value of current character
		x = ((x + rawData[byteIndex]) % 255);
		
		// XOR with a character of the IP address hash
		x ^= [ipHash characterAtIndex:(byteIndex % [ipHash length])];
		
		// Append the hexadecimal value to the output string
		[encodedMessage appendFormat:@"%02X", x];
	}
	
	// Return the encoded message
	return encodedMessage;
}

- (NSString*)messageTag
{
	// Abstract method; throw exception on invocation
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark Accessors

@synthesize playerNickname;
@synthesize protocolVersion;
@synthesize serverAddress;

@end

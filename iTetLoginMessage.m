//
//  iTetLoginMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import "iTetLoginMessage.h"
#import "NSString+MessageData.h"

@implementation iTetLoginMessage

+ (id)messageWithProtocol:(iTetProtocolType)gameProtocol
				 nickname:(NSString*)playerNickname
				  address:(NSString*)ipv4ServerAddress
{
	return [[[self alloc] initWithProtocol:gameProtocol
								  nickname:playerNickname
								   address:ipv4ServerAddress] autorelease];
}

- (id)initWithProtocol:(iTetProtocolType)gameProtocol
			  nickname:(NSString*)playerNickname
			   address:(NSString*)ipv4ServerAddress
{
	messageType = loginMessage;
	
	protocol = gameProtocol;
	nickname = [playerNickname copy];
	address = [ipv4ServerAddress copy];
	
	return self;
}

- (void)dealloc
{
	[nickname release];
	[address release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const TetrinetProtocolConnectionFormat =	@"tetrisstart %@ 1.13";
NSString* const TetrifastProtocolConnectionFormat =	@"tetrifaster %@ 1.13";

- (NSData*)rawMessageData
{
	// Determine the message format, which consists of: <protocol string> <player nickname> <version number>
	NSData* messageData;
	switch ([self protocol])
	{
		case tetrinetProtocol:
			messageData = [[NSString stringWithFormat:TetrinetProtocolConnectionFormat, [self nickname]] messageData];
			break;
		case tetrifastProtocol:
			messageData = [[NSString stringWithFormat:TetrifastProtocolConnectionFormat, [self nickname]] messageData];
			break;
		default:
			NSLog(@"WARNING: attempt to construct raw LoginMessage using invalid protocol");
			return nil;
	}
	
	// Split the server's IP address into integer components
	NSArray* ipComponents = [[self address] componentsSeparatedByString:@"."];
	NSInteger ip[4];
	NSUInteger i;
	for (i = 0; i < 4; i++)
		ip[i] = [[ipComponents objectAtIndex:i] integerValue];
	
	// Create the "hash" of the IP address
	NSString* ipHash = [NSString stringWithFormat:@"%d", (54*ip[0]) + (41*ip[1]) + (29*ip[2]) + (17*ip[3])];
	
	// Create an "encoded" version of the message, starting with a random two-digit hexadecimal value in the range [0, 255)
	uint8_t x = random() % 255;
	NSMutableString* encodedMessage = [NSMutableString stringWithFormat:@"%02X", x];
	
	// Create a "hash" of each character in the message and append it as a hexadecimal value to the end of the encoded string
	const uint8_t* rawData = [messageData bytes];
	for (i = 0; i < [messageData length]; i++)
	{
		// Modular-add value of current character
		x = ((x + rawData[i]) % 255);
		
		// XOR with a character of the IP address hash
		x ^= [ipHash characterAtIndex:(i % [ipHash length])];
		
		// Append the hexadecimal value to the output string
		[encodedMessage appendFormat:@"%02X", x];
	}
	
	// Convert the encoded message to a data object before returning
	return [encodedMessage messageData];
}

#pragma mark -
#pragma mark Accessors

@synthesize protocol;
@synthesize nickname;
@synthesize address;

@end

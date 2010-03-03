//
//  iTetLoginMessage.m
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetLoginMessage.h"

@implementation iTetLoginMessage

+ (id)loginMessageWithProtocol:(iTetProtocolType)gameProtocol
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
	nickname = [playerNickname retain];
	address = [ipv4ServerAddress retain];
	
	return self;
}

#pragma mark -
#pragma mark iTetOutgoingMessage Protocol Methods

NSString* const TetrinetProtocolConnectionFormat =	@"tetrisstart %@ 1.13";
NSString* const TetrifastProtocolConnectionFormat =	@"tetrifaster %@ 1.13";

- (NSData*)rawMessageData
{
	// Determine the message format, which consists of: <protocol string> <player nickname> <version number>
	NSString* rawMessage;
	switch ([self protocol])
	{
		case tetrinetProtocol:
			rawMessage = [NSString stringWithFormat:TetrinetProtocolConnectionFormat, [self nickname]];
			break;
		case tetrifastProtocol:
			rawMessage = [NSString stringWithFormat:TetrifastProtocolConnectionFormat, [self nickname]];
			break;
		default:
			NSLog(@"Warning: attempt to construct raw LoginMessage using invalid protocol");
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
	NSInteger x = random() % 255;
	NSMutableString* encodedMessage = [NSMutableString stringWithFormat:@"%02X", x];
	
	// Create a "hash" of each character in the message and append it as a hexadecimal value to the end of the encoded string
	for (i = 0; i < [rawMessage length]; i++)
	{
		// Modular-add value of current character
		x = ((x + [rawMessage characterAtIndex:i]) % 255);
		
		// XOR with a character of the IP address hash
		x ^= [ipHash characterAtIndex:(i % [ipHash length])];
		
		// Append the hexadecimal value to the output string
		[encodedMessage appendFormat:@"%02X", x];
	}
	
	// Convert the encoded message to a data object before returning
	return [encodedMessage dataUsingEncoding:NSASCIIStringEncoding
						allowLossyConversion:YES];
}

#pragma mark -
#pragma mark Accessors

@synthesize protocol;
@synthesize nickname;
@synthesize address;

@end

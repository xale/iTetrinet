//
//  iTetNetworkController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/11/09.
//

#import "iTetNetworkController.h"
#import "iTetAppController.h"
#import "iTetTextAttributesController.h"
#import "iTetServerInfo.h"
#import "Queue.h"
#import "NSMutableData+SingleByte.h"

NSString* const iTetNetworkErrorDomain = @"iTetNetworkError";
#define iTetNetworkPort	(31457)
#define iTetNetworkTerminatorCharacter (0xFF)

@implementation iTetNetworkController

- (id)initWithDelegate:(id)theDelegate
{
	delegate = theDelegate; // Weak reference, not retained
	
	connected = NO;
	
	partialRead = [[NSMutableData alloc] init];
	writeQueue = [[Queue alloc] init];
	
	return self;
}

- (void)dealloc
{
	// Disconnect
	[self disconnect];
	
	[partialRead release];
	[writeQueue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Connecting

- (void)connectToServer:(iTetServerInfo*)server
{
	// Create an NSHost instance using the host name
	currentServer = [server retain];
	currentConnection = [[NSHost hostWithName:[server address]] retain];
	
	// Connect input and output streams to the host
	[NSStream getStreamsToHost:currentConnection
						  port:iTetNetworkPort
				   inputStream:&readStream
				  outputStream:&writeStream];
	
	// Retain and configure the new streams
	[readStream retain];
	[writeStream retain];
	[readStream setDelegate:self];
	[writeStream setDelegate:self];
	[readStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						  forMode:NSDefaultRunLoopMode];
	[writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
	
	// Open the streams
	[readStream open];
	[writeStream open];
	
	// Create and enqueue the initialization message
	[self initializeConnection];
}

#define TetrinetFormat	@"tetrisstart %@ 1.13"
#define TetrifastFormat	@"tetrifaster %@ 1.13"

- (void)initializeConnection
{
	// Generate the base string format, which consists of:
	// <protocol string> <player nickname> <version number>
	NSString* connectString;
	if ([currentServer protocol] == tetrinetProtocol)
		connectString = [NSString stringWithFormat:TetrinetFormat, [currentServer nickname]];
	else
		connectString = [NSString stringWithFormat:TetrifastFormat, [currentServer nickname]];
	
	// Find the server's IPv4 address
	NSString* address;
	for (address in [currentConnection addresses])
	{
		// FIXME: very fragile/hacky
		if ([address rangeOfString:@"."].location != NSNotFound)
			break;
	}
	
	// Split the server's IP address into integer components
	NSArray* ipComponents = [address componentsSeparatedByString:@"."];
	NSInteger ip[4];
	NSUInteger i;
	for (i = 0; i < 4; i++)
		ip[i] = [[ipComponents objectAtIndex:i] integerValue];
	
	// Create the "hash" of the IP address
	NSString* ipHash = [NSString stringWithFormat:@"%d", (54*ip[0]) + (41*ip[1]) + (29*ip[2]) + (17*ip[3])];
	
	// Start with a random salt, and use it to create the initialization request
	NSInteger x = random() % 255;
	NSMutableString* encodedString = [NSMutableString stringWithFormat:@"%02X", x];
	
	// For each character in the connection request, create the two-character
	// hexadecimal "hash" and append it to the string
	for (i = 0; i < [connectString length]; i++)
	{
		// Modular-add value of current character
		x = ((x + [connectString characterAtIndex:i]) % 255);
		
		// XOR with a character of the IP address hash
		x ^= [ipHash characterAtIndex:(i % [ipHash length])];
		
		// Append the hexadecimal value to the output string
		[encodedString appendFormat:@"%02X", x];
	}
	
	// Send the initialization request to the server
	[self sendMessage:encodedString];
}

#pragma mark -
#pragma mark Disconnecting

- (void)disconnect
{
	// If we are already disconnected, ignore
	if (![self connected])
		return;
	
	// Close and free the streams
	[readStream close];
	[writeStream close];
	[readStream removeFromRunLoop:[NSRunLoop currentRunLoop]
						  forMode:NSDefaultRunLoopMode];
	[writeStream removeFromRunLoop:[NSRunLoop currentRunLoop]
						   forMode:NSDefaultRunLoopMode];
	[readStream release];
	[writeStream release];
	readStream = nil;
	writeStream = nil;
	
	// Free the current server (since we are no longer connected)
	[currentServer release];
	currentServer = nil;
	[currentConnection release];
	currentConnection = nil;
	
	// Empty the write queue
	[writeQueue removeAllObjects];
	
	// Change connection state
	[self setConnected:NO];
}

#pragma mark -
#pragma mark Stream Events

- (void)stream:(NSStream*)stream
   handleEvent:(NSStreamEvent)event
{
	// Determine the events that occurred
	// Connection Opened
	if (event & NSStreamEventOpenCompleted)
	{
		[self setConnected:YES];
	}
	// Data to read
	if (event & NSStreamEventHasBytesAvailable)
	{
		[self attemptRead];
	}
	// Space to write
	if (event & NSStreamEventHasSpaceAvailable)
	{
		[self attemptWrite];
	}
	// Error
	if (event & NSStreamEventErrorOccurred)
	{
		[self handleError:stream];
	}
	// End-of-stream
	if (event & NSStreamEventEndEncountered)
	{
		[self disconnect];
	}
}

#pragma mark -
#pragma mark Reads/Writes

#define iTetNetworkBufferSize	1024

- (void)attemptRead
{	
	// Read data from the stream into a buffer
	uint8_t buffer[iTetNetworkBufferSize + 1];
	NSUInteger bytesRead = 0;
	bytesRead = [readStream read:buffer
					   maxLength:iTetNetworkBufferSize];
	
	// Check that data was read
	if (bytesRead <= 0)
	{
		NSLog(@"WARNING: no bytes read on BytesAvailable event");
		return;
	}
	
	buffer[bytesRead] = 0; // NULL terminator
	
	// Loop through the data, looking for terminator characters
	NSUInteger index, lastTerminator = 0;
	for (index = 0; index < bytesRead; index++)
	{
		if (buffer[index] == (uint8_t)iTetNetworkTerminatorCharacter)
		{
			// Append the subdata up to the terminator to the last partial buffer
			// (probably empty, but may contain leftover data from the last read)
			[partialRead appendBytes:(buffer + lastTerminator)
							  length:(index - lastTerminator)];
			
			// Append a NULL terminator for the end of the string
			[partialRead appendByte:0];
			
			// Relay the message to the delegate
			if ([delegate respondsToSelector:@selector(messageReceived:)])
				[delegate messageReceived:[[partialRead copy] autorelease]];
			
			// Clear the partial read buffer
			[partialRead setLength:0];
			
			// Skip over the terminator character
			index++;
			lastTerminator = index;
		}
	}
	
	// If there was a partial message in the data read, store it for later
	if (buffer[bytesRead - 1] != (uint8_t)iTetNetworkTerminatorCharacter)
	{
		[partialRead appendBytes:(buffer + lastTerminator)
						  length:(bytesRead - lastTerminator)];
	}
	
	// If this read didn't get all the bytes from the stream, read again
	if ([readStream hasBytesAvailable])
		[self attemptRead];
}

- (void)sendMessage:(NSString*)message
{
	// Send the message
	[self sendMessageData:[message dataUsingEncoding:NSASCIIStringEncoding
								allowLossyConversion:YES]];
}

NSString* const iTetClientInfoFormat = @"clientinfo %@ %@";

- (void)sendClientInfo
{
	// Retrieve the application name and version
	NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// Send the client info to the server
	[self sendMessage:[NSString stringWithFormat:iTetClientInfoFormat, appName, version]];
}

- (void)sendMessageData:(NSData*)messageData
{
	// FIXME: debug logging
	NSMutableString* debugString = [NSMutableString string];
	char byte;
	for (NSUInteger i = 0; i < [messageData length]; i++)
	{
		byte = ((char*)[messageData bytes])[i];
		if (byte > 31)
			[debugString appendFormat:@"%c", byte];
		else
			[debugString appendFormat:@"<%02d>", byte];
	}
	NSLog(@"DEBUG: enqueueing outgoing message: %@", debugString);
	
	// Make the data mutable
	NSMutableData* data = [NSMutableData dataWithData:messageData];
	
	// Append the "message terminator" byte
	[data appendByte:((uint8_t)iTetNetworkTerminatorCharacter)];
	
	// Add the data to the outgoing queue
	[writeQueue enqueueObject:data];
	
	// Attempt to send the message immediately
	[self attemptWrite];
}

- (void)attemptWrite
{	
	// Check if the stream is open for writing
	if (![writeStream hasSpaceAvailable])
		return;
	
	NSMutableData* data = nil;
	const uint8_t* dataRaw = NULL;
	size_t dataSize = 0;
	NSUInteger bytesWritten = 0;
	
	// Loop through data objects in the queue until we run out
	// (or the stream stops accepting bytes; see if-statement below)
	while ([writeQueue count] > 0)
	{
		data = [writeQueue firstObject];
		
		// Get the raw data
		dataRaw = [data bytes];
		dataSize = [data length];
		
		// Attempt to write the bytes to the stream
		bytesWritten = [writeStream write:dataRaw
								maxLength:dataSize];
		
		// Check that the whole data object was written
		if (bytesWritten < dataSize)
		{
			// Replace the data in the queue with the unwritten portion
			[data replaceBytesInRange:NSMakeRange(0, [data length])
							withBytes:(dataRaw + bytesWritten)
							   length:(dataSize - bytesWritten)];
			
			// Stop attempting to send data
			break;
		}
		
		// If the entire message was sent, remove it from the queue
		[writeQueue dequeueFirstObject];
	}
}

#pragma mark -
#pragma mark Errors

- (void)handleError:(NSStream*)stream
{	
	// Relay the error to the delegate
	if ([delegate respondsToSelector:@selector(connectionError:)])
		[delegate connectionError:[stream streamError]];
}

#pragma mark -
#pragma mark Accessors

@synthesize currentServer;

- (void)setConnected:(BOOL)connectionOpen
{
	// Inform the delegate when the connection opens or closes
	if (!connected && connectionOpen)
	{
		// Connection opened
		if ([delegate respondsToSelector:@selector(connectionOpened)])
			[delegate connectionOpened];
		
		connected = YES;
	}
	else if (connected && !connectionOpen)
	{
		// Connection closed
		if ([delegate respondsToSelector:@selector(connectionClosed)])
			[delegate connectionClosed];
		
		connected = NO;
	}
}
@synthesize connected;

@end

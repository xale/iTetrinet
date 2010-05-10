//
//  iTetPlayer.m
//  iTetrinet
//
//  Created by Alex Heinz on 6/17/09.
//

#import "iTetPlayer.h"

@implementation iTetPlayer

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	[self release];
	return nil;
}

+ (id)playerWithNickname:(NSString*)nick
				  number:(NSInteger)number
				teamName:(NSString*)team
{
	return [[[self alloc] initWithNickname:nick
									number:number
								  teamName:team] autorelease];
}
- (id)initWithNickname:(NSString*)nick
				number:(NSInteger)number
			  teamName:(NSString*)team
{
	nickname = [nick copy];
	playerNumber = number;
	teamName = [team copy];
	
	field = [[iTetField alloc] initWithRandomContents];
	
	return self;
}

+ (id)playerWithNickname:(NSString*)nick
				  number:(NSInteger)number
{
	return [[[self alloc] initWithNickname:nick
									number:number] autorelease];
}
- (id)initWithNickname:(NSString*)nick
				number:(NSInteger)number
{
	return [self initWithNickname:nick
						   number:number
						 teamName:[NSString string]];
}

#define iTetUnnamedPlayerPlaceholderName	NSLocalizedStringFromTable(@"Unnamed Player", @"Players", @"Name given to a player with no explicitly-defined name; should be used only extremely rarely, if at all")

+ (id)playerWithNumber:(NSInteger)number
{
	return [[[self alloc] initWithNumber:number] autorelease];
}
- (id)initWithNumber:(NSInteger)number
{
	return [self initWithNickname:iTetUnnamedPlayerPlaceholderName
						   number:number];
}

- (void)dealloc
{
	[nickname release];
	[teamName release];
	[field release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Comparators

- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[self class]])
	{
		iTetPlayer* otherPlayer = (iTetPlayer*)object;
		return ([self playerNumber] == [otherPlayer playerNumber]);
	}
	
	return NO;
}

#pragma mark -
#pragma mark Accessors

- (BOOL)isLocalPlayer
{
	return NO;
}

- (BOOL)isServerPlayer
{
	return NO;
}

@synthesize nickname;
@synthesize playerNumber;
@synthesize teamName;
@synthesize playing;
@synthesize field;
@synthesize level;

@end

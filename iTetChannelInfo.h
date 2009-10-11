//
//  iTetChannelInfo.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/23/09.
//

#import <Cocoa/Cocoa.h>


@interface iTetChannelInfo : NSObject
{
	NSString* channelName;
	int currentPlayers;
	int maxPlayers;
	int channelState;
	NSString* description;
}

@property (readwrite, copy) NSString* channelName;
@property (readwrite, assign) int currentPlayers;
@property (readwrite, assign) int maxPlayers;
@property (readwrite, assign) int channelState;
@property (readwrite, copy) NSString* description;

@end

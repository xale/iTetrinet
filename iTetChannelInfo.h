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
	NSInteger currentPlayers;
	NSInteger maxPlayers;
	NSInteger channelState;
	NSString* description;
}

@property (readwrite, copy) NSString* channelName;
@property (readwrite, assign) NSInteger currentPlayers;
@property (readwrite, assign) NSInteger maxPlayers;
@property (readwrite, assign) NSInteger channelState;
@property (readwrite, copy) NSString* description;

@end

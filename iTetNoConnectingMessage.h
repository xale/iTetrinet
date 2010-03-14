//
//  iTetNoConnectingMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import "iTetMessage.h"

@interface iTetNoConnectingMessage : iTetMessage <iTetIncomingMessage>
{
	NSString* reason;
}

@property (readonly) NSString* reason;

@end

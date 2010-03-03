//
//  iTetWinlistMessage.h
//  iTetrinet
//
//  Created by Alex Heinz on 3/3/10.
//

#import <Cocoa/Cocoa.h>
#import "iTetMessage.h"

@interface iTetWinlistMessage : iTetMessage <iTetIncomingMessage>
{
	NSArray* winlistTokens;
}

@property (readonly) NSArray* winlistTokens;

@end

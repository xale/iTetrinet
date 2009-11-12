//
//  iTetKeyNamePair.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/12/09.
//

#import <Cocoa/Cocoa.h>

@interface iTetKeyNamePair : NSObject <NSCoding>
{
	int keyCode;
	NSString* keyName;
}

+ (id)keyNamePairFromKeyEvent:(NSEvent*)event;
+ (id)keyNamePairForKeyCode:(int)code
			     name:(NSString*)name;

- (id)initWithKeyEvent:(NSEvent*)event;
- (id)initWithKeyCode:(int)code
		     name:(NSString*)name;

- (NSString*)keyNameForEvent:(NSEvent*)event;
- (NSString*)modifierNameForEvent:(NSEvent*)event;

@property (readonly) int keyCode;
@property (readonly) NSString* keyName;

@end

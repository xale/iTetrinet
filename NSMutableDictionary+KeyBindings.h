//
//  NSMutableDictionary+KeyBindings.h
//  iTetrinet
//
//  Created by Alex Heinz on 11/5/09.
//

#import <Cocoa/Cocoa.h>

@class iTetKeyNamePair;

typedef enum
{
	movePieceLeft,
	movePieceRight,
	rotatePieceClockwise,
	rotatePieceCounterclockwise,
	movePieceDown,
	dropPiece,
	gameChat,
	noAction
} iTetGameAction;

extern NSString* const iTetKeyConfigurationNameKey;

@interface NSMutableDictionary (KeyBindings)

+ (NSMutableArray*)defaultKeyConfigurations;

- (void)setAction:(iTetGameAction)action
	     forKey:(iTetKeyNamePair*)key;
- (iTetGameAction)actionForKey:(iTetKeyNamePair*)key;

@property (readwrite, retain) NSString* configurationName;

@end

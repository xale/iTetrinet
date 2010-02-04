//
//  iTetSpecialsView.h
//  iTetrinet
//
//  Created by Alex Heinz on 6/5/09.
//
// A ThemedView subclass that draws the local player's list of specials.

#import <Cocoa/Cocoa.h>
#import "iTetThemedView.h"

@interface iTetSpecialsView : iTetThemedView
{
	NSArray* specials;
	
	NSInteger capacity;
}

@property (readwrite, copy) NSArray* specials;
@property (readwrite, assign) NSInteger capacity;

@end

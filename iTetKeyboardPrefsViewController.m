//
//  iTetKeyboardPrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetKeyboardPrefsViewController.h"
#import "iTetPreferencesController.h"

@implementation iTetKeyboardPrefsViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super initWithNibName:@"KeyboardPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:@"Keyboard Controls"];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

@end

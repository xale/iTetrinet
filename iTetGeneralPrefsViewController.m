//
//  iTetGeneralPrefsViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/4/09.
//

#import "iTetGeneralPrefsViewController.h"
#import "iTetPreferencesController.h"

@implementation iTetGeneralPrefsViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super initWithNibName:@"GeneralPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:@"Preferences"];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

@end

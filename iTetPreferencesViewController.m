//
//  iTetPreferencesViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 11/23/09.
//

#import "iTetPreferencesViewController.h"

@implementation iTetPreferencesViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

#pragma mark -
#pragma mark Accessors

- (iTetPreferencesController*)prefs
{
	return PREFS;
}

@end

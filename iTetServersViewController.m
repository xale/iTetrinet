//
//  iTetServersViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/5/09.
//

#import "iTetServersViewController.h"
#import "iTetPreferencesController.h"
#import "iTetServerInfo.h"

@implementation iTetServersViewController

+ (id)viewController
{
	return [[[self alloc] init] autorelease];
}

- (id)init
{
	if (![super initWithNibName:@"ServersPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:@"Servers List"];
	
	return self;
}

#pragma mark -
#pragma mark Accessors

- (iTetPreferencesController*)preferencesController
{
	return [iTetPreferencesController preferencesController];
}

- (NSArray*)valuesForProtocolPopUpCell
{
	return [NSArray arrayWithObjects:
		  @"Tetrinet",
		  @"Tetrifast",
		  nil];
}

@end

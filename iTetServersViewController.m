//
//  iTetServersViewController.m
//  iTetrinet
//
//  Created by Alex Heinz on 7/5/09.
//

#import "iTetServersViewController.h"
#import "iTetServerInfo.h"

#define iTetServersPreferencesViewName	NSLocalizedStringFromTable(@"Servers List", @"Preferences", @"Title of the 'servers' preferences pane")

@implementation iTetServersViewController

- (id)init
{
	if (![super initWithNibName:@"ServersPrefsView" bundle:nil])
		return nil;
	
	[self setTitle:iTetServersPreferencesViewName];
	
	return self;
}

#pragma mark -
#pragma mark Interface Actions

- (IBAction)createServer:(id)sender
{
	// Try to end any editing currently taking place
	NSWindow* window = [serversTableView window];
	if (![window makeFirstResponder:window])
		return;
	
	// Create a new server info object, and add it to the content array
	iTetServerInfo* server = [[serversArrayController newObject] autorelease];
	[serversArrayController addObject:server];
	
	// Ensure that the sort order of the table view is preserved
	[serversArrayController rearrangeObjects];
	
	// Find the index of the new server info object in the sorted array
	NSUInteger row = [[serversArrayController arrangedObjects] indexOfObject:server];
	
	// Begin editing the new server info object
	[serversTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
				  byExtendingSelection:NO];
	[serversTableView editColumn:0
							 row:row
					   withEvent:nil
						  select:YES];
}

#pragma mark -
#pragma mark Accessors

- (NSArray*)valuesForProtocolPopUpCell
{
	return [NSArray arrayWithObjects:@"Tetrinet", @"Tetrifast", nil];
}

@end

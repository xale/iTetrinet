//
//  IPSContextMenuTableView.m
//  iTetrinet
//
//  Created by Alex Heinz on 4/15/10.
//

#import "IPSContextMenuTableView.h"

@implementation IPSContextMenuTableView

// Code for this method adapted from: http://www.cocoadev.com/index.pl?RightClickSelectInTableView
- (NSMenu*)menuForEvent:(NSEvent*)event
{
	// Determine where the user clicked
    NSPoint mousePoint = [self convertPoint:[event locationInWindow]
								   fromView:nil];
	
	// Determine if the user clicked on a row
    NSInteger row = [self rowAtPoint:mousePoint];
    if (row >= 0)
    {
		// If a row was clicked, select it, and ask the delegate for a context menu
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
		  byExtendingSelection:NO];
		if ([[self delegate] respondsToSelector:@selector(tableView:menuForEvent:)])
		{
			NSMenu* delegateMenu = [[self delegate] tableView:self
												 menuForEvent:event];
			if (delegateMenu != nil)
				return delegateMenu;
		}
    }
    else
    {
		// If the user has not clicked a row, deleselect the rows and don't ask for a menu
		[self deselectAll:self];
    }
	
	// If the delegate could not supply (or was not asked for) a menu, return the default
	return [super menuForEvent:event];
}

@end

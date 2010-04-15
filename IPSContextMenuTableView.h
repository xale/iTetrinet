//
//  IPSContextMenuTableView.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/15/10.
//

#import <Cocoa/Cocoa.h>

@interface IPSContextMenuTableView : NSTableView

- (NSMenu*)menuForEvent:(NSEvent*)event;

@end

@interface NSObject (IPSContextMenuTableViewDelegate)

- (NSMenu*)tableView:(IPSContextMenuTableView*)tableView
		menuForEvent:(NSEvent*)event;

@end

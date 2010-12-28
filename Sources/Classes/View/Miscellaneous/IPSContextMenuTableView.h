//
//  IPSContextMenuTableView.h
//  iTetrinet
//
//  Created by Alex Heinz on 4/15/10.
//  Copyright (c) 2010 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface IPSContextMenuTableView : NSTableView

- (NSMenu*)menuForEvent:(NSEvent*)event;

@end

@interface NSObject (IPSContextMenuTableViewDelegate)

- (NSMenu*)tableView:(IPSContextMenuTableView*)tableView
		menuForEvent:(NSEvent*)event;

@end

//
//  iTetWinlistViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

@interface iTetWinlistViewController : NSObject
{
	NSArray* winlist;
}

- (void)parseWinlist:(NSArray*)winlistTokens;

@property (readwrite, retain) NSArray* winlist;

@end

//
//  iTetWinlistViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetWinlistViewController : NSObject
{
	NSArray* winlist;
}

- (void)parseWinlist:(NSArray*)winlistTokens;

@property (readwrite, retain) NSArray* winlist;

@end

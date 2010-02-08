//
//  iTetWinlistViewController.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetWinlistViewController : NSObject
{
	NSArray* playersWinlist;
	NSArray* teamsWinlist;
}

- (void)parseWinlist:(NSArray*)winlistTokens;

@property (readwrite, retain) NSArray* playersWinlist;
@property (readwrite, retain) NSArray* teamsWinlist;

@end

//
//  iTetWinlistEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetWinlistEntry : NSObject
{
	NSString* entryName;
	NSInteger entryScore;
	BOOL teamEntry;
}

+ (id)playerEntryWithName:(NSString*)name
					score:(NSInteger)score;
+ (id)teamEntryWithName:(NSString*)name
				  score:(NSInteger)score;
- (id)initWithName:(NSString*)name
			 score:(NSInteger)score
			isTeam:(BOOL)isTeam;

@property (readonly) NSString* entryName;
@property (readonly) NSInteger entryScore;
@property (readonly, getter=isTeamEntry) BOOL teamEntry;

@end

//
//  iTetWinlistEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//

#import <Cocoa/Cocoa.h>

@interface iTetWinlistEntry : NSObject
{
	NSString* name;
	NSInteger score;
	BOOL team;
}

+ (id)playerEntryWithName:(NSString*)entryName
					score:(NSInteger)entryScore;
+ (id)teamEntryWithName:(NSString*)entryName
				  score:(NSInteger)entryScore;
- (id)initWithName:(NSString*)entryName
			 score:(NSInteger)entryScore
			isTeam:(BOOL)isTeam;

@property (readonly) NSString* name;
@property (readonly) NSInteger score;
@property (readonly, getter=isTeam) BOOL team;

@end

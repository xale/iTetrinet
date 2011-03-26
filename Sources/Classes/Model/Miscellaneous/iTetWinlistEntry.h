//
//  iTetWinlistEntry.h
//  iTetrinet
//
//  Created by Alex Heinz on 2/8/10.
//  Copyright (c) 2010-2011 Alex Heinz (xale@acm.jhu.edu)
//  This is free software, presented under the MIT License
//  See the included license.txt for more information
//

#import <Cocoa/Cocoa.h>

extern NSString* const iTetPlayerWinlistEntryTag;
extern NSString* const iTetTeamWinlistEntryTag;

@interface iTetWinlistEntry : NSObject
{
	NSString* entryName;
	NSInteger entryScore;
	BOOL teamEntry;
}

+ (id)entryWithWinlistMessageToken:(NSString*)token;
+ (id)playerEntryWithName:(NSString*)name
					score:(NSInteger)score;
+ (id)teamEntryWithName:(NSString*)name
				  score:(NSInteger)score;
- (id)initWithName:(NSString*)name
			 score:(NSInteger)score
			isTeam:(BOOL)isTeam;

- (NSString*)messageToken;

@property (readonly) NSString* entryName;
@property (readonly) NSInteger entryScore;
@property (readonly, getter=isTeamEntry) BOOL teamEntry;

@end

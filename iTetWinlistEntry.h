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
}

+ (id)entryWithName:(NSString*)entryName
		  score:(NSInteger)entryScore;
- (id)initWithName:(NSString*)entryName
		 score:(NSInteger)entryScore;

@property (readonly) NSString* name;
@property (readonly) NSInteger score;

@end
